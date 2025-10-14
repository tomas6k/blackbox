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
    token_locale text;
    amount_value numeric;
    amount_text text;
    currency_symbol text;
    notification_title text;
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

    -- try to reuse the latest locale stored with the token
    select locale
    into token_locale
    from public.user_push_tokens upt
    where upt.user_id = target_user
      and upt.enabled = true
      and upt.locale is not null
    order by upt.updated_at desc
    limit 1;

    amount_value := coalesce(new.transaction_value, new.transaction_amount, 0);

    if token_locale ilike 'fr%' then
        notification_title := 'Merci pour la Blackbox 🙏';
        amount_text := to_char(abs(amount_value), 'FM999 999 990,00');
    else
        notification_title := 'Thanks for the Blackbox 🙏';
        amount_text := to_char(abs(amount_value), 'FM999,999,990.00');
    end if;

    currency_symbol := '€';
    transaction_label := coalesce(new.transaction_name, 'Transaction');
    notification_body := format('%s → -%s %s', transaction_label, amount_text, currency_symbol);

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
                    'locale', token_locale,
                    'currency_symbol', currency_symbol
                )
            )
        )
    );

    return new;
end;
$$;
