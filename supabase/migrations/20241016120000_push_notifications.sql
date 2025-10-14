-- Push notification infrastructure for transaction events
set check_function_bodies = off;

create extension if not exists http with schema extensions;

create table if not exists public.user_push_tokens (
    id uuid default gen_random_uuid() primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    token text not null,
    platform text check (platform in ('ios', 'android', 'web', 'unknown')) default 'unknown'::text,
    locale text,
    enabled boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (token)
);

create index if not exists user_push_tokens_user_id_idx on public.user_push_tokens (user_id);

alter table public.user_push_tokens enable row level security;

create policy "Users can view own push tokens"
    on public.user_push_tokens
    for select
    using (auth.uid() = user_id);

create policy "Users can upsert own push tokens"
    on public.user_push_tokens
    for insert
    with check (auth.uid() = user_id);

create policy "Users can update own push tokens"
    on public.user_push_tokens
    for update
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

create policy "Users can delete own push tokens"
    on public.user_push_tokens
    for delete
    using (auth.uid() = user_id);

create or replace function public.set_user_push_tokens_updated_at()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

drop trigger if exists user_push_tokens_set_updated_at on public.user_push_tokens;

create trigger user_push_tokens_set_updated_at
before update on public.user_push_tokens
for each row execute function public.set_user_push_tokens_updated_at();

create type public.transaction_notification_status as enum (
    'pending',
    'processing',
    'sent',
    'no_tokens',
    'retry',
    'failed'
);

create table if not exists public.transaction_notification_jobs (
    id bigserial primary key,
    transaction_id uuid not null references public.transactions(id) on delete cascade,
    user_id uuid not null references auth.users(id) on delete cascade,
    payload jsonb not null,
    status public.transaction_notification_status not null default 'pending',
    attempts integer not null default 0,
    error text,
    next_attempt_at timestamptz not null default now(),
    created_at timestamptz not null default now(),
    processing_started_at timestamptz,
    processed_at timestamptz
);

create index if not exists transaction_notification_jobs_status_idx
    on public.transaction_notification_jobs (status, next_attempt_at);

alter table public.transaction_notification_jobs enable row level security;

create or replace function public.queue_transaction_notification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
    has_tokens boolean;
    notification_title text;
    notification_body text;
    amount_text text;
begin
    if new.transaction_to is null then
        return new;
    end if;

    select exists(
        select 1
        from public.user_push_tokens upt
        where upt.user_id = new.transaction_to
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
        new.transaction_to,
        jsonb_build_object(
            'transaction_id', new.id,
            'user_id', new.transaction_to,
            'title', notification_title,
            'body', notification_body,
            'data', jsonb_strip_nulls(
                jsonb_build_object(
                    'transaction_id', new.id,
                    'saison_id', new.saison_id,
                    'transaction_value', new.transaction_value,
                    'transaction_amount', new.transaction_amount,
                    'transaction_name', new.transaction_name
                )
            )
        )
    );

    return new;
end;
$$;

drop trigger if exists transactions_enqueue_notification on public.transactions;

create trigger transactions_enqueue_notification
after insert on public.transactions
for each row execute function public.queue_transaction_notification();

create or replace function public.dequeue_transaction_notification_jobs(batch_size integer default 10)
returns setof public.transaction_notification_jobs
language plpgsql
security definer
set search_path = public
as $$
begin
    return query
    with candidates as (
        select id
        from public.transaction_notification_jobs
        where status in ('pending', 'retry')
          and next_attempt_at <= now()
        order by next_attempt_at, id
        limit coalesce(batch_size, 10)
        for update skip locked
    ),
    updated as (
        update public.transaction_notification_jobs j
        set status = 'processing',
            attempts = attempts + 1,
            processing_started_at = now()
        where j.id in (select id from candidates)
        returning j.*
    )
    select * from updated;
end;
$$;

grant execute on function public.dequeue_transaction_notification_jobs(integer) to service_role;

comment on function public.dequeue_transaction_notification_jobs(integer)
    is 'Fetches a batch of pending notification jobs and marks them as processing.';

