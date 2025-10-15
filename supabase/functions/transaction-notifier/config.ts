import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.1';

import type { FcmServiceAccount } from './types.ts';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

if (!supabaseUrl || !serviceRoleKey) {
  throw new Error('Missing Supabase configuration');
}

export const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

const functionSecret = (Deno.env.get('FUNCTION_SECRET') ?? '').trim() || null;
const fcmServerKey = (Deno.env.get('FCM_SERVER_KEY') ?? '').trim() || null;

let fcmServiceAccount: FcmServiceAccount | null = null;
const fcmServiceAccountRaw = Deno.env.get('FCM_SERVICE_ACCOUNT');
if (fcmServiceAccountRaw) {
  try {
    const parsed = JSON.parse(fcmServiceAccountRaw) as Record<string, unknown>;
    if (
      typeof parsed === 'object' &&
      parsed !== null &&
      typeof parsed['project_id'] === 'string' &&
      typeof parsed['client_email'] === 'string' &&
      typeof parsed['private_key'] === 'string'
    ) {
      fcmServiceAccount = {
        project_id: parsed['project_id'],
        client_email: parsed['client_email'],
        private_key: parsed['private_key'],
      };
    } else {
      console.error('Invalid shape for FCM_SERVICE_ACCOUNT');
    }
  } catch (error) {
    console.error('Unable to parse FCM_SERVICE_ACCOUNT JSON', error);
  }
}

export const runtimeConfig = {
  functionSecret,
  fcmServerKey,
  fcmServiceAccount,
  maxAttempts: 5,
  retryIntervalMinutes: 10,
} as const;

