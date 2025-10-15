import 'jsr:@supabase/functions-js@2.5.0/edge-runtime.d.ts';

import { serve } from 'https://deno.land/std/http/server.ts';

import { runtimeConfig } from './config.ts';
import { dequeueJobs } from './jobs.ts';
import { NotificationProcessor } from './processor.ts';
import { FcmDispatcher } from './sender.ts';
import type { BatchSummary } from './types.ts';
import { jsonResponse, normalizeBatchSize } from './utils.ts';

const dispatcher = new FcmDispatcher({
  legacyKey: runtimeConfig.fcmServerKey,
  serviceAccount: runtimeConfig.fcmServiceAccount,
});

const processor = new NotificationProcessor({
  dispatcher,
  maxAttempts: runtimeConfig.maxAttempts,
  retryIntervalMinutes: runtimeConfig.retryIntervalMinutes,
});

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }

  const allowedSecrets = runtimeConfig.functionSecret
    ? runtimeConfig.functionSecret
        .split(',')
        .map((value) => value.trim())
        .filter((value) => value.length > 0)
    : [];

  const userAgent = req.headers.get('user-agent') ?? '';
  const isPgNetRequest = userAgent.startsWith('pg_net/');

  if (allowedSecrets.length > 0 && !isPgNetRequest) {
    const headerSecret = req.headers.get('x-function-secret')?.trim() ?? null;
    const bearer = req.headers.get('authorization');
    const bearerSecret =
      bearer?.startsWith('Bearer ')
        ? bearer.slice('Bearer '.length).trim()
        : null;

    const providedSecret = [headerSecret, bearerSecret].filter(Boolean) as string[];
    const isAuthorized = providedSecret.some((candidate) =>
      allowedSecrets.includes(candidate),
    );

    if (!isAuthorized) {
      return new Response('Unauthorized', { status: 401 });
    }
  }

  const requestBody = await readRequestBody(req);
  const batchSize = normalizeBatchSize(
    requestBody?.batchSize,
    { defaultValue: 20, min: 1, max: 50 },
  );

  let jobs: Awaited<ReturnType<typeof dequeueJobs>>;
  try {
    jobs = await dequeueJobs(batchSize);
  } catch (error) {
    console.error('Failed to dequeue jobs', error);
    return jsonResponse(
      { processed: 0, sent: 0, noTokens: 0, failed: 0, error: 'Failed to dequeue jobs' },
      500,
    );
  }

  if (jobs.length === 0) {
    return jsonResponse({
      processed: 0,
      sent: 0,
      noTokens: 0,
      failed: 0,
      message: 'No pending jobs',
    });
  }

  const summary: BatchSummary = await processor.processBatch(jobs);
  return jsonResponse(summary);
});

async function readRequestBody(
  req: Request,
): Promise<Record<string, unknown>> {
  try {
    const body = await req.json();
    if (body && typeof body === 'object') {
      return body as Record<string, unknown>;
    }
  } catch {
    // Ignore invalid JSON – fall back to empty payload.
  }
  return {};
}
