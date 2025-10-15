import { disableTokens, fetchTokens, updateJob } from './jobs.ts';
import { prepareNotification } from './notification.ts';
import { FcmDispatcher } from './sender.ts';
import type { BatchSummary, NotificationJob } from './types.ts';
import { isoInMinutes, isoNow, truncateError } from './utils.ts';

type ProcessorConfig = {
  dispatcher: FcmDispatcher;
  maxAttempts: number;
  retryIntervalMinutes: number;
};

type JobOutcome = 'sent' | 'no_tokens' | 'failed';

export class NotificationProcessor {
  constructor(private readonly config: ProcessorConfig) {}

  async processBatch(jobs: NotificationJob[]): Promise<BatchSummary> {
    const summary: BatchSummary = {
      processed: jobs.length,
      sent: 0,
      noTokens: 0,
      failed: 0,
    };

    for (const job of jobs) {
      const outcome = await this.processJob(job);

      if (outcome === 'sent') {
        summary.sent += 1;
      } else if (outcome === 'no_tokens') {
        summary.noTokens += 1;
      } else {
        summary.failed += 1;
      }
    }

    return summary;
  }

  private async processJob(job: NotificationJob): Promise<JobOutcome> {
    try {
      const tokens = await fetchTokens(job.user_id);
      if (tokens.length === 0) {
        const updated = await updateJob(job.id, {
          status: 'no_tokens',
          error: null,
          processed_at: isoNow(),
        });
        if (!updated) {
          console.error('Failed to persist no_tokens status for job', job.id);
        }
        return 'no_tokens';
      }

      const notification = prepareNotification(job.payload);
      const dispatchResult = await this.config.dispatcher.send(
        tokens,
        notification,
      );

      if (dispatchResult.invalidTokens.length > 0) {
        await disableTokens(dispatchResult.invalidTokens);
      }

      if (!dispatchResult.ok) {
        const nextStatus = job.attempts >= this.config.maxAttempts
          ? 'failed'
          : 'retry';
        const updated = await updateJob(job.id, {
          status: nextStatus,
          error: truncateError(dispatchResult.error),
          next_attempt_at: nextStatus === 'retry'
            ? isoInMinutes(this.config.retryIntervalMinutes)
            : null,
          processed_at: nextStatus === 'failed' ? isoNow() : undefined,
        });
        if (!updated) {
          console.error('Failed to persist retry/failure status for job', job.id);
        }
        return 'failed';
      }

      const updated = await updateJob(job.id, {
        status: 'sent',
        error: null,
        processed_at: isoNow(),
        payload: {
          ...job.payload,
          title: notification.title,
          body: notification.body,
          data: notification.data,
        },
      });
      if (!updated) {
        console.error('Failed to persist sent status for job', job.id);
      }
      return 'sent';
    } catch (error) {
      console.error('Unexpected error while processing job', job.id, error);
      const nextStatus = job.attempts >= this.config.maxAttempts
        ? 'failed'
        : 'retry';
      const updated = await updateJob(job.id, {
        status: nextStatus,
        error: truncateError(error),
        next_attempt_at: nextStatus === 'retry'
          ? isoInMinutes(this.config.retryIntervalMinutes)
          : null,
        processed_at: nextStatus === 'failed' ? isoNow() : undefined,
      });
      if (!updated) {
        console.error('Failed to persist fallback status for job', job.id);
      }
      return 'failed';
    }
  }
}
