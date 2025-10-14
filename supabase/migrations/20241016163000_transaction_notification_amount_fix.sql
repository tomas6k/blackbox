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
    penalty_value numeric;
    penalty_name text;
    amount_value numeric;
    amount_text text;
    notification_title text := 'Merci pour la Blackbox 🙏';
    notification_body text;
    transaction_label text;
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

    select p.penalitie_value, p.penalitie_name
    into penalty_value, penalty_name
    from public.penalties p
    where p.id = new.penalitie_id
    limit 1;

    amount_value := case
        when new.transaction_value is not null then abs(new.transaction_value)
        when penalty_value is not null then abs(penalty_value * coalesce(nullif(new.transaction_amount, 0), 1))
        else abs(coalesce(new.transaction_amount, 0))
    end;

    amount_text := to_char(amount_value, 'FM999 999 990,00');
    transaction_label := coalesce(new.transaction_name, penalty_name, 'Transaction');
    notification_body := format('%s → - %s €', transaction_label, amount_text);

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
                    'transaction_to', new.transaction_to,
                    'locale', 'fr-FR',
                    'currency_symbol', '€',
                    'penalty_value', penalty_value,
                    'computed_amount', amount_value
                )
            )
        )
    );

    return new;
end;
$$;
