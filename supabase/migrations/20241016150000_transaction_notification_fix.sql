-- Adjust transaction notification trigger to map transaction_to to auth user_id via user_teams.
set check_function_bodies = off;

create or replace function public.queue_transaction_notification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    target_user uuid;
    has_tokens boolean;
    notification_title text;
    notification_body text;
    amount_text text;
begin
    if new.transaction_to is null then
        return new;
    end if;

    select ut.user_id into target_user
    from public.user_teams ut
    where ut.id = new.transaction_to
    limit 1;

    if target_user is null then
        target_user := new.transaction_to;
    end if;

    if target_user is null then
        return new;
    end if;

    select exists(
        select 1
        from public.user_push_tokens upt
        where upt.user_id = target_user
          and upt.enabled = true
    ) into has_tokens;

    if not has_tokens then
        return new;
    end if;

    amount_text := coalesce(
        nullif(to_char(new.transaction_value, 'FM9999990.00'), ''),
        nullif(to_char(new.transaction_amount, 'FM9999990.00'), ''),
        '0'
    );

    notification_title := coalesce(new.transaction_name, 'Nouvelle transaction');
    notification_body := coalesce(
        nullif(new.note, ''),
        format('Montant: %s', amount_text)
    );

    insert into public.transaction_notification_jobs (transaction_id, user_id, payload)
    values (
        new.id,
        target_user,
        jsonb_build_object(
            'transaction_id', new.id,
            'user_id', target_user,
            'title', notification_title,
            'body', notification_body,
            'data', jsonb_strip_nulls(
                jsonb_build_object(
                    'transaction_id', new.id,
                    'saison_id', new.saison_id,
                    'transaction_value', new.transaction_value,
                    'transaction_amount', new.transaction_amount,
                    'transaction_name', new.transaction_name,
                    'transaction_to', new.transaction_to
                )
            )
        )
    );

    return new;
end;
$$;
