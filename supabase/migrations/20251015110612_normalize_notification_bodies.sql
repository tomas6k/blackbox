set check_function_bodies = off;

update public.transaction_notification_jobs
set payload = jsonb_set(
  payload,
  '{body}',
  to_jsonb(
    format(
      '%s → - %s €',
      coalesce(payload -> 'data' ->> 'transaction_name', 'Transaction'),
      replace(
        to_char(abs((payload -> 'data' ->> 'transaction_value')::numeric), 'FM9999990.00'),
        '.',
        ','
      )
    )
  )
)
where payload -> 'data' ->> 'transaction_value' is not null;
