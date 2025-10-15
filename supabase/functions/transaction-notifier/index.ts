import 'jsr:@supabase/functions-js/edge-runtime.d.ts';

import { serve } from 'https://deno.land/std/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.1';

type NotificationJob = {
  id: number;
  user_id: string;
  transaction_id: string;
  payload: {
    transaction_id?: string;
    user_id?: string;
    title?: string;
    body?: string;
    data?: Record<string, unknown>;
  };
  attempts: number;
};

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const fcmServerKey = Deno.env.get('FCM_SERVER_KEY') ?? '';
const functionSecret = Deno.env.get('FUNCTION_SECRET') ?? '';
const fcmServiceAccountRaw = Deno.env.get('FCM_SERVICE_ACCOUNT') ?? '';

if (!supabaseUrl || !serviceRoleKey) {
  throw new Error('Missing Supabase configuration');
}

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

const MAX_ATTEMPTS = 5;
const RETRY_INTERVAL_MINUTES = 10;

type FcmServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

let fcmServiceAccount: FcmServiceAccount | null = null;
let cachedAccessToken:
  | { token: string; expiresAt: number }
  | null = null;

if (fcmServiceAccountRaw) {
  try {
    fcmServiceAccount = JSON.parse(fcmServiceAccountRaw) as FcmServiceAccount;
  } catch (error) {
    console.error('Unable to parse FCM_SERVICE_ACCOUNT JSON', error);
  }
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }

  if (functionSecret) {
    const authHeader = req.headers.get('authorization') ?? '';
    if (authHeader !== `Bearer ${functionSecret}`) {
      return new Response('Unauthorized', { status: 401 });
    }
  }

  const requestBody = await req.json().catch(() => ({}));
  const batchSize =
    typeof requestBody.batchSize === 'number' && requestBody.batchSize > 0
      ? Math.min(requestBody.batchSize, 50)
      : 20;

  const jobsResponse = await supabase.rpc('dequeue_transaction_notification_jobs', {
    batch_size: batchSize,
  });

  if (jobsResponse.error) {
    console.error('Failed to dequeue jobs', jobsResponse.error);
    return new Response('Failed to dequeue jobs', { status: 500 });
  }

  const jobs = (jobsResponse.data ?? []) as NotificationJob[];
  if (jobs.length === 0) {
    return jsonResponse({
      processed: 0,
      sent: 0,
      noTokens: 0,
      failed: 0,
      message: 'No pending jobs',
    });
  }

  const summary = {
    processed: jobs.length,
    sent: 0,
    noTokens: 0,
    failed: 0,
  };

  for (const job of jobs) {
    try {
      const tokens = await fetchTokens(job.user_id);
      if (tokens.length === 0) {
        await markJob(job.id, {
          status: 'no_tokens',
          error: null,
          processed_at: new Date().toISOString(),
        });
        summary.noTokens += 1;
        continue;
      }

      const fcmResult = await dispatchFcmMessage(tokens, job.payload);
      if (!fcmResult.ok) {
        const nextStatus = job.attempts >= MAX_ATTEMPTS ? 'failed' : 'retry';
        await markJob(job.id, {
          status: nextStatus,
          error: truncateError(fcmResult.error),
          next_attempt_at:
            nextStatus === 'retry'
              ? new Date(Date.now() + RETRY_INTERVAL_MINUTES * 60 * 1000).toISOString()
              : null,
          processed_at: nextStatus === 'failed' ? new Date().toISOString() : null,
        });
        summary.failed += 1;
        continue;
      }

      if (fcmResult.invalidTokens.length > 0) {
        await disableTokens(fcmResult.invalidTokens);
      }

      await markJob(
        job.id,
        {
          status: 'sent',
          error: null,
          processed_at: new Date().toISOString(),
        },
        {
          ...payload,
          body: notification.body,
        },
      );
      summary.sent += 1;
    } catch (error) {
      console.error('Unexpected error while processing job', job.id, error);
      const nextStatus = job.attempts >= MAX_ATTEMPTS ? 'failed' : 'retry';
      await markJob(job.id, {
        status: nextStatus,
        error: truncateError(String(error)),
        next_attempt_at:
          nextStatus === 'retry'
            ? new Date(Date.now() + RETRY_INTERVAL_MINUTES * 60 * 1000).toISOString()
            : null,
        processed_at: nextStatus === 'failed' ? new Date().toISOString() : null,
      });
      summary.failed += 1;
    }
  }

  return jsonResponse(summary);
});

async function fetchTokens(userId: string): Promise<string[]> {
  const { data, error } = await supabase
    .from('user_push_tokens')
    .select('token')
    .eq('user_id', userId)
    .eq('enabled', true);

  if (error) {
    console.error('Failed to fetch tokens', error);
    return [];
  }

  return (data ?? []).map((row) => row.token as string).filter(Boolean);
}

async function disableTokens(tokens: string[]) {
  const { error } = await supabase
    .from('user_push_tokens')
    .update({
      enabled: false,
      updated_at: new Date().toISOString(),
    })
    .in('token', tokens);

  if (error) {
    console.error('Failed to disable invalid tokens', error);
  }
}

async function markJob(
  jobId: number,
  values: {
    status: 'sent' | 'no_tokens' | 'retry' | 'failed';
    error: string | null;
    processed_at?: string | null;
    next_attempt_at?: string | null;
  },
  payloadOverride?: NotificationJob['payload'],
) {
  const payload: Record<string, unknown> = {
    status: values.status,
    error: values.error,
  };
  if (values.processed_at !== undefined) {
    payload.processed_at = values.processed_at;
  }
  if (values.next_attempt_at !== undefined) {
    payload.next_attempt_at = values.next_attempt_at;
  }
  if (payloadOverride) {
    payload.payload = payloadOverride;
  }

  const { error } = await supabase
    .from('transaction_notification_jobs')
    .update(payload)
    .eq('id', jobId);

  if (error) {
    console.error('Failed to update job status', jobId, error);
  }
}

async function dispatchFcmMessage(
  tokens: string[],
  payload: NotificationJob['payload'],
) {
  if (!fcmServerKey) {
    if (!fcmServiceAccount) {
      console.error('Neither FCM_SERVER_KEY nor FCM_SERVICE_ACCOUNT is configured.');
      return {
        ok: false,
        error: 'FCM credentials missing',
        invalidTokens: [] as string[],
      };
    }
  }

  const notification = prepareNotification(payload);

  if (fcmServiceAccount) {
    return await dispatchFcmMessagesV1(tokens, notification);
  }

  return await dispatchFcmLegacy(tokens, notification);
}

function truncateError(message: string | null, max = 500) {
  if (!message) {
    return null;
  }
  return message.length > max ? `${message.slice(0, max)}…` : message;
}

function jsonResponse(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function prepareNotification(payload: NotificationJob['payload']): PreparedNotification {
  const data = sanitizeData(stripInternalData(payload.data ?? {}));

  const amountCandidate = (payload.data ?? ({} as Record<string, unknown>)) as Record<string, unknown>;
  const amountSources = [
    amountCandidate['computed_amount'],
    amountCandidate['penalty_value'],
    amountCandidate['transaction_value'],
    amountCandidate['transaction_amount'],
  ];

  let amount = Number.NaN;
  for (const source of amountSources) {
    if (source === undefined || source === null || source === '') {
      continue;
    }
    const numeric = typeof source === 'number' ? source : parseFloat(String(source).replace(',', '.'));
    if (!Number.isNaN(numeric) && Number.isFinite(numeric)) {
      amount = Math.abs(numeric);
      break;
    }
  }

  const labelRaw = (payload.data as Record<string, unknown> | undefined)?.['transaction_name'];
  const label = typeof labelRaw === 'string' && labelRaw.trim().length > 0 ? labelRaw : 'Transaction';
  const normalizedAmount = !Number.isNaN(amount) && Number.isFinite(amount)
    ? amount
    : 0;
  const formattedAmount = formatEuro(Math.abs(normalizedAmount));

  const body = `${label} → - ${formattedAmount} €`;

  const title = payload.title ?? 'Merci pour la Blackbox 🙏';

  return {
    title,
    body,
    data,
  };
}

function formatEuro(value: number): string {
  return new Intl.NumberFormat('fr-FR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(value);
}

type PreparedNotification = {
  title: string;
  body: string;
  data: Record<string, string>;
};

async function dispatchFcmLegacy(
  tokens: string[],
  notification: PreparedNotification,
) {
  if (!fcmServerKey) {
    return {
      ok: false,
      error: 'Missing legacy FCM server key',
      invalidTokens: [] as string[],
    };
  }

  const notificationBody = {
    registration_ids: tokens,
    notification: {
      title: notification.title,
      body: notification.body,
    },
    data: notification.data,
  };

  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `key=${fcmServerKey}`,
    },
    body: JSON.stringify(notificationBody),
  });

  if (!response.ok) {
    const text = await response.text();
    console.error('FCM legacy request failed', response.status, text);
    return {
      ok: false,
      error: text || `HTTP ${response.status}`,
      invalidTokens: [] as string[],
    };
  }

  const result = await response.json().catch(() => ({}));
  const invalidTokens: string[] = [];
  if (Array.isArray(result.results)) {
    result.results.forEach((entry: { error?: string }, index: number) => {
      const errorCode = entry?.error;
      if (
        errorCode === 'NotRegistered' ||
        errorCode === 'InvalidRegistration' ||
        errorCode === 'MismatchSenderId'
      ) {
        invalidTokens.push(tokens[index]);
      }
    });
  }

  return { ok: true, error: null, invalidTokens };
}

async function dispatchFcmMessagesV1(
  tokens: string[],
  notification: PreparedNotification,
) {
  if (!fcmServiceAccount) {
    return {
      ok: false,
      error: 'Missing FCM service account',
      invalidTokens: [] as string[],
    };
  }

  const projectId = fcmServiceAccount.project_id;
  const accessToken = await getAccessToken();
  if (!accessToken) {
    return {
      ok: false,
      error: 'Unable to obtain FCM access token',
      invalidTokens: [] as string[],
    };
  }

  const invalidTokens: string[] = [];
  let errors: string[] = [];

  for (const registrationToken of tokens) {
    const messagePayload = {
      message: {
        token: registrationToken,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data,
      },
    };

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify(messagePayload),
      },
    );

    if (!response.ok) {
      const text = await response.text();
      console.error(
        'FCM v1 request failed',
        response.status,
        text,
      );
      errors.push(text || `HTTP ${response.status}`);

      if (response.status === 404 || response.status === 400) {
        invalidTokens.push(registrationToken);
      }
      continue;
    }
  }

  if (errors.length > 0 && invalidTokens.length === tokens.length) {
    return {
      ok: false,
      error: errors.join('; '),
      invalidTokens,
    };
  }

  return {
    ok: errors.length === 0,
    error: errors.length ? errors.join('; ') : null,
    invalidTokens,
  };
}

async function getAccessToken(): Promise<string | null> {
  if (!fcmServiceAccount) {
    return null;
  }

  const now = Math.floor(Date.now() / 1000);
  if (cachedAccessToken && cachedAccessToken.expiresAt - 60 > now) {
    return cachedAccessToken.token;
  }

  const assertion = await createJwtAssertion(
    fcmServiceAccount.client_email,
    fcmServiceAccount.private_key,
  );

  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });

  if (!tokenResponse.ok) {
    const text = await tokenResponse.text();
    console.error('Failed to obtain FCM access token', tokenResponse.status, text);
    return null;
  }

  const { access_token, expires_in } = await tokenResponse.json();
  const expiresAt = now + Number(expires_in ?? 3600);

  cachedAccessToken = {
    token: access_token as string,
    expiresAt,
  };
  return access_token as string;
}

async function createJwtAssertion(clientEmail: string, privateKeyPem: string) {
  const header = {
    alg: 'RS256',
    typ: 'JWT',
  };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: clientEmail,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  };

  const encoder = new TextEncoder();
  const base64url = (input: string | Uint8Array) =>
    btoa(
      String.fromCharCode(
        ...(
          input instanceof Uint8Array ? input : encoder.encode(input)
        ),
      ),
    ).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

  const body = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(payload))}`;
  const privateKey = await importPrivateKey(privateKeyPem);
  const signature = await crypto.subtle.sign(
    { name: 'RSASSA-PKCS1-v1_5' },
    privateKey,
    encoder.encode(body),
  );
  const jwt = `${body}.${base64url(new Uint8Array(signature))}`;
  return jwt;
}

async function importPrivateKey(pem: string) {
  const cleaned = pem
    .replaceAll('-----BEGIN PRIVATE KEY-----', '')
    .replaceAll('-----END PRIVATE KEY-----', '')
    .replace(/\s+/g, '');
  const raw = Uint8Array.from(atob(cleaned), (c) => c.charCodeAt(0));
  return await crypto.subtle.importKey(
    'pkcs8',
    raw.buffer,
    {
      name: 'RSASSA-PKCS1-v1_5',
      hash: 'SHA-256',
    },
    false,
    ['sign'],
  );
}


function sanitizeData(value: Record<string, unknown>): Record<string, string> {
  const result: Record<string, string> = {};
  for (const [key, raw] of Object.entries(value)) {
    if (raw === undefined || raw === null) {
      continue;
    }
    if (typeof raw === 'object') {
      result[key] = JSON.stringify(raw);
    } else {
      result[key] = String(raw);
    }
  }
  return result;
}

function stripInternalData(value: Record<string, unknown>): Record<string, unknown> {
  const result: Record<string, unknown> = { ...value };
  delete result.computed_amount;
  delete result.penalty_value;
  return result;
}
