export function isoNow(): string {
  return new Date().toISOString();
}

export function isoInMinutes(minutes: number): string {
  const ms = minutes * 60 * 1000;
  return new Date(Date.now() + ms).toISOString();
}

export function truncateError(message: unknown, max = 500): string | null {
  if (message === null || message === undefined) {
    return null;
  }

  const text =
    message instanceof Error
      ? message.message
      : typeof message === 'string'
      ? message
      : (() => {
          try {
            return JSON.stringify(message);
          } catch {
            return String(message);
          }
        })();

  if (text.length <= max) {
    return text;
  }
  return `${text.slice(0, max)}…`;
}

export function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

export function normalizeBatchSize(
  value: unknown,
  opts: { defaultValue: number; min: number; max: number },
): number {
  if (typeof value === 'number' && Number.isFinite(value)) {
    const rounded = Math.trunc(value);
    if (rounded >= opts.min) {
      return Math.min(rounded, opts.max);
    }
  }
  return opts.defaultValue;
}

