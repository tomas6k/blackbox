# Blackbox

A new Flutter project.

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.

## Supabase transaction notifier

Use `scripts/invoke_transaction_notifier.sh` to trigger the Supabase Edge function manually.  
Exports required:

```bash
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="..."
export FUNCTION_SECRET="..." # matches FUNCTION_SECRET secret on Supabase
scripts/invoke_transaction_notifier.sh 5
```
