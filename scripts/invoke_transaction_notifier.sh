#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${SUPABASE_URL:-}" ]]; then
  echo "Missing SUPABASE_URL environment variable" >&2
  exit 1
fi

if [[ -z "${SUPABASE_SERVICE_ROLE_KEY:-}" ]]; then
  echo "Missing SUPABASE_SERVICE_ROLE_KEY environment variable" >&2
  exit 1
fi

if [[ -z "${FUNCTION_SECRET:-}" ]]; then
  echo "Missing FUNCTION_SECRET environment variable" >&2
  exit 1
fi

BATCH_SIZE="${1:-20}"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to build the request payload. Install jq and retry." >&2
  exit 1
fi

payload=$(jq -n --argjson size "$BATCH_SIZE" '{batchSize: $size}')

curl \
  --fail \
  --silent \
  --show-error \
  --request POST \
  --url "${SUPABASE_URL}/functions/v1/transaction-notifier" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  --header "x-function-secret: ${FUNCTION_SECRET}" \
  --data "${payload}"
