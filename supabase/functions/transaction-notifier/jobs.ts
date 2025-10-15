import { supabase } from './config.ts';
import type { JobUpdate, NotificationJob } from './types.ts';

export async function dequeueJobs(batchSize: number): Promise<NotificationJob[]> {
  const { data, error } = await supabase.rpc(
    'dequeue_transaction_notification_jobs',
    { batch_size: batchSize },
  );

  if (error) {
    throw new Error(`Failed to dequeue jobs: ${error.message}`);
  }

  const rows = Array.isArray(data) ? data : [];
  return rows.map(normalizeJob);
}

export async function fetchTokens(userId: string): Promise<string[]> {
  const { data, error } = await supabase
    .from('user_push_tokens')
    .select('token')
    .eq('user_id', userId)
    .eq('enabled', true);

  if (error) {
    throw new Error(`Failed to fetch tokens: ${error.message}`);
  }

  return (data ?? [])
    .map((row) => row?.token as string)
    .filter((token): token is string => Boolean(token));
}

export async function disableTokens(tokens: string[]): Promise<void> {
  if (tokens.length === 0) {
    return;
  }

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

export async function updateJob(jobId: number, update: JobUpdate): Promise<boolean> {
  const payload: Record<string, unknown> = {
    status: update.status,
  };

  if (update.error !== undefined) {
    payload.error = update.error;
  }
  if (update.processed_at !== undefined) {
    payload.processed_at = update.processed_at;
  }
  if (update.next_attempt_at !== undefined) {
    payload.next_attempt_at = update.next_attempt_at;
  }
  if (update.payload !== undefined) {
    payload.payload = update.payload;
  }

  const { error } = await supabase
    .from('transaction_notification_jobs')
    .update(payload)
    .eq('id', jobId);

  if (error) {
    console.error('Failed to update job status', jobId, error);
    return false;
  }

  return true;
}

function normalizeJob(row: Record<string, unknown>): NotificationJob {
  const rawPayload = row['payload'];
  const payload =
    rawPayload && typeof rawPayload === 'object'
      ? (rawPayload as Record<string, unknown>)
      : {};
  return {
    id: row['id'] as number,
    user_id: row['user_id'] as string,
    transaction_id: row['transaction_id'] as string,
    payload: payload as NotificationJob['payload'],
    attempts: typeof row['attempts'] === 'number'
      ? row['attempts'] as number
      : Number(row['attempts'] ?? 0),
    status: (row['status'] as NotificationJob['status']) ?? 'pending',
  };
}
