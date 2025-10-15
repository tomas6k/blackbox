set check_function_bodies = off;

update public.transaction_notification_jobs
set payload = jsonb_set(
  payload,
  '{body}',
  to_jsonb(
    format(
      '%s → - %s €',
      coalesce(payload -> 'data' ->> 'transaction_name', 'Transaction'),
      to_char(
        coalesce(
          (payload -> 'data' ->> 'computed_amount')::numeric,
          abs((payload -> 'data' ->> 'transaction_value')::numeric),
          abs((payload -> 'data' ->> 'penalty_value')::numeric)
        ),
        'FM999 999 990,00'
      )
    )
  )
)
where payload -> 'data' ? 'computed_amount';
