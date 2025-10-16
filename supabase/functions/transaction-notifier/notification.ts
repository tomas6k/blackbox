import type {
  NotificationJobPayload,
  PreparedNotification,
} from './types.ts';

const DEFAULT_TITLE = 'Merci pour la Blackbox 🙏';
const DEFAULT_LABEL = 'Transaction';

export function prepareNotification(payload: NotificationJobPayload): PreparedNotification {
  const sanitizedData = sanitizeData({
    ...(payload.data ?? {}),
    transaction_id: payload.transaction_id,
    user_id: payload.user_id,
    saison_id: payload.saison_id,
  });

  const amount = resolveAmount(payload);
  const label = resolveLabel(payload);
  const formattedAmount = formatEuro(Math.abs(amount ?? 0));

  const title =
    typeof payload.title === 'string' && payload.title.trim().length > 0
      ? payload.title
      : DEFAULT_TITLE;

  const body = `${label} → - ${formattedAmount} €`;

  return {
    title,
    body,
    data: sanitizedData,
    android: {
      notification: {
        sound: 'notification',
        channelId: 'blackbox_notifications',
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'notification.caf',
        },
      },
    },
  };
}

function resolveAmount(payload: NotificationJobPayload): number | null {
  const data = payload.data ?? {};
  const candidates = [
    payload.transaction_value,
    payload.transaction_amount,
    (data as Record<string, unknown>)['computed_amount'],
    (data as Record<string, unknown>)['penalty_value'],
    (data as Record<string, unknown>)['transaction_value'],
    (data as Record<string, unknown>)['transaction_amount'],
  ];

  for (const value of candidates) {
    const normalized = coerceNumber(value);
    if (normalized !== null) {
      return normalized;
    }
  }
  return null;
}

function resolveLabel(payload: NotificationJobPayload): string {
  const data = payload.data ?? {};
  const candidates = [
    payload.transaction_name,
    (data as Record<string, unknown>)['transaction_name'],
  ];

  for (const candidate of candidates) {
    if (typeof candidate === 'string') {
      const trimmed = candidate.trim();
      if (trimmed.length > 0) {
        return trimmed;
      }
    }
  }

  return DEFAULT_LABEL;
}

function coerceNumber(value: unknown): number | null {
  if (value === undefined || value === null) {
    return null;
  }

  if (typeof value === 'number' && Number.isFinite(value)) {
    return Math.abs(value);
  }

  if (typeof value === 'string') {
    const normalized = value.replace(',', '.');
    const parsed = parseFloat(normalized);
    if (!Number.isNaN(parsed) && Number.isFinite(parsed)) {
      return Math.abs(parsed);
    }
  }

  return null;
}

function sanitizeData(source: Record<string, unknown>): Record<string, string> {
  const result: Record<string, string> = {};
  for (const [key, raw] of Object.entries(source)) {
    if (raw === undefined || raw === null) {
      continue;
    }
    if (typeof raw === 'object') {
      try {
        result[key] = JSON.stringify(raw);
      } catch {
        result[key] = '[unserializable]';
      }
    } else {
      result[key] = String(raw);
    }
  }
  return result;
}

function formatEuro(value: number): string {
  return new Intl.NumberFormat('fr-FR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(value);
}

