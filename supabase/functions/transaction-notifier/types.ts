export type NotificationJobPayload = {
  transaction_id?: string;
  user_id?: string;
  title?: string;
  body?: string;
  data?: Record<string, unknown>;
  transaction_value?: number | string | null;
  transaction_amount?: number | string | null;
  transaction_name?: string | null;
  note?: string | null;
  saison_id?: string | null;
  [key: string]: unknown;
};

export type NotificationJobStatus =
  | 'pending'
  | 'processing'
  | 'sent'
  | 'no_tokens'
  | 'retry'
  | 'failed';

export type NotificationJob = {
  id: number;
  user_id: string;
  transaction_id: string;
  payload: NotificationJobPayload;
  attempts: number;
  status: NotificationJobStatus;
};

export type JobUpdate = {
  status: Exclude<NotificationJobStatus, 'pending'>;
  error?: string | null;
  processed_at?: string | null;
  next_attempt_at?: string | null;
  payload?: NotificationJobPayload;
};

export type PreparedNotification = {
  title: string;
  body: string;
  data: Record<string, string>;
  android?: {
    notification?: {
      sound?: string;
      channelId?: string;
    };
  };
  apns?: {
    payload?: {
      aps?: {
        sound?: string;
      };
    };
  };
};

export type DispatchResult = {
  ok: boolean;
  error: string | null;
  invalidTokens: string[];
};

export type BatchSummary = {
  processed: number;
  sent: number;
  noTokens: number;
  failed: number;
};

export type FcmServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};
