set check_function_bodies = off;

with formatted as (
  select
    id,
    format(
      '%s → - %s €',
      coalesce(payload -> 'data' ->> 'transaction_name', 'Transaction'),
      replace(
        to_char(
          coalesce(
            (payload -> 'data' ->> 'computed_amount')::numeric,
            abs((payload -> 'data' ->> 'transaction_value')::numeric),
            abs((payload -> 'data' ->> 'penalty_value')::numeric)
          ),
          'FM9999990.00'
        ),
        '.',
        ','
      )
    ) as body_text
  from public.transaction_notification_jobs
  where payload -> 'data' ? 'computed_amount'
)
update public.transaction_notification_jobs j
set payload = jsonb_set(j.payload, '{body}', to_jsonb(f.body_text))
from formatted f
where f.id = j.id;
