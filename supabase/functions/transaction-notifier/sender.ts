import type {
  DispatchResult,
  FcmServiceAccount,
  PreparedNotification,
} from './types.ts';

type AccessTokenCache = {
  token: string;
  expiresAt: number;
};

export class FcmDispatcher {
  private cachedAccessToken: AccessTokenCache | null = null;

  constructor(
    private readonly options: {
      legacyKey: string | null;
      serviceAccount: FcmServiceAccount | null;
    },
  ) {}

  async send(
    tokens: string[],
    notification: PreparedNotification,
  ): Promise<DispatchResult> {
    if (!this.options.legacyKey && !this.options.serviceAccount) {
      return {
        ok: false,
        error: 'FCM credentials missing',
        invalidTokens: [],
      };
    }

    if (this.options.serviceAccount) {
      return await this.sendWithV1(tokens, notification);
    }

    return await this.sendLegacy(tokens, notification);
  }

  private async sendLegacy(
    tokens: string[],
    notification: PreparedNotification,
  ): Promise<DispatchResult> {
    if (!this.options.legacyKey) {
      return {
        ok: false,
        error: 'Missing legacy FCM server key',
        invalidTokens: [],
      };
    }

    const body = {
      registration_ids: tokens,
      notification: {
        title: notification.title,
        body: notification.body,
        sound: 'notification.wav',
      },
      data: notification.data,
    };

    const response = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `key=${this.options.legacyKey}`,
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const text = await safeReadText(response);
      console.error('FCM legacy request failed', response.status, text);
      return {
        ok: false,
        error: text || `HTTP ${response.status}`,
        invalidTokens: [],
      };
    }

    const result = await response.json().catch(() => ({}));
    const invalidTokens: string[] = [];
    if (Array.isArray(result?.results)) {
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

    return {
      ok: true,
      error: null,
      invalidTokens,
    };
  }

  private async sendWithV1(
    tokens: string[],
    notification: PreparedNotification,
  ): Promise<DispatchResult> {
    const serviceAccount = this.options.serviceAccount;
    if (!serviceAccount) {
      return {
        ok: false,
        error: 'Missing FCM service account',
        invalidTokens: [],
      };
    }

    const accessToken = await this.getAccessToken(serviceAccount);
    if (!accessToken) {
      return {
        ok: false,
        error: 'Unable to obtain FCM access token',
        invalidTokens: [],
      };
    }

    const invalidTokens: string[] = [];
    const errors: string[] = [];

    for (const registrationToken of tokens) {
      const messagePayload: Record<string, unknown> = {
        message: {
          token: registrationToken,
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: notification.data,
        },
      };

      if (notification.android) {
        (messagePayload.message as Record<string, unknown>).android = notification.android;
      }

      if (notification.apns) {
        (messagePayload.message as Record<string, unknown>).apns = notification.apns;
      }

      const response = await fetch(
        `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
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
        const text = await safeReadText(response);
        console.error('FCM v1 request failed', response.status, text);
        errors.push(text || `HTTP ${response.status}`);

        if (response.status === 404 || response.status === 400) {
          invalidTokens.push(registrationToken);
        }
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

  private async getAccessToken(
    serviceAccount: FcmServiceAccount,
  ): Promise<string | null> {
    const now = Math.floor(Date.now() / 1000);
    if (
      this.cachedAccessToken &&
      this.cachedAccessToken.expiresAt - 60 > now
    ) {
      return this.cachedAccessToken.token;
    }

    const assertion = await this.createJwtAssertion(serviceAccount);

    const response = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion,
      }),
    });

    if (!response.ok) {
      const text = await safeReadText(response);
      console.error('Failed to obtain FCM access token', response.status, text);
      return null;
    }

    const { access_token, expires_in } = await response.json();
    const token = String(access_token ?? '');
    const expiresAt = now + Number(expires_in ?? 3600);

    this.cachedAccessToken = {
      token,
      expiresAt,
    };

    return token;
  }

  private async createJwtAssertion(
    serviceAccount: FcmServiceAccount,
  ): Promise<string> {
    const header = {
      alg: 'RS256',
      typ: 'JWT',
    };

    const now = Math.floor(Date.now() / 1000);
    const payload = {
      iss: serviceAccount.client_email,
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
    const privateKey = await importPrivateKey(serviceAccount.private_key);
    const signature = await crypto.subtle.sign(
      { name: 'RSASSA-PKCS1-v1_5' },
      privateKey,
      encoder.encode(body),
    );

    return `${body}.${base64url(new Uint8Array(signature))}`;
  }
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

async function safeReadText(response: Response): Promise<string> {
  try {
    return await response.text();
  } catch {
    return '';
  }
}

