-- Cashbook: database setup for Supabase
-- Paste this whole file into Supabase > SQL Editor > New query, then click "Run".
-- It is safe to run more than once.

-- 1. Entries (one row per income or expense)
create table if not exists public.entries (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  type        text not null check (type in ('in', 'out')),
  amount      numeric(14,2) not null check (amount > 0),
  category    text not null,
  date        date not null,
  method      text not null default '',
  note        text not null default '',
  created_at  timestamptz not null default now()
);
create index if not exists entries_user_date_idx on public.entries (user_id, date);

-- 2. Settings (one row per user: currency)
create table if not exists public.settings (
  user_id     uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  currency    text not null default 'INR',
  updated_at  timestamptz not null default now()
);

-- 3. Privacy: every signed-in person can only see and change their own rows
alter table public.entries  enable row level security;
alter table public.settings enable row level security;

drop policy if exists "Own entries: read"   on public.entries;
drop policy if exists "Own entries: add"    on public.entries;
drop policy if exists "Own entries: change" on public.entries;
drop policy if exists "Own entries: remove" on public.entries;
create policy "Own entries: read"   on public.entries for select to authenticated using ((select auth.uid()) = user_id);
create policy "Own entries: add"    on public.entries for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Own entries: change" on public.entries for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "Own entries: remove" on public.entries for delete to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "Own settings: read"   on public.settings;
drop policy if exists "Own settings: add"    on public.settings;
drop policy if exists "Own settings: change" on public.settings;
create policy "Own settings: read"   on public.settings for select to authenticated using ((select auth.uid()) = user_id);
create policy "Own settings: add"    on public.settings for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "Own settings: change" on public.settings for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

-- 4. Let signed-in users reach these tables through the API (signed-out visitors get nothing)
revoke all on public.entries, public.settings from anon;
grant select, insert, update, delete on public.entries  to authenticated;
grant select, insert, update         on public.settings to authenticated;
