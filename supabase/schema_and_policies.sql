-- SCHEMA & POLICIES for CRM Grátis
-- Run this in Supabase SQL Editor

-- Enable extensions
create extension if not exists "uuid-ossp";
create extension if not exists pgcrypto;

-- Profiles (optional, basic)
create table if not exists public.profiles (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null unique,
  full_name text,
  created_at timestamptz default now()
);

-- Clients
create table if not exists public.clients (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null,
  name text not null,
  email text,
  phone text,
  notes text,
  created_at timestamptz default now()
);

-- Deals (pipeline)
create type if not exists deal_stage as enum ('novo', 'negociacao', 'fechado');
create table if not exists public.deals (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null,
  client_id uuid references public.clients(id) on delete set null,
  title text not null,
  value numeric(12,2) default 0,
  stage deal_stage not null default 'novo',
  created_at timestamptz default now()
);

-- Tasks
create type if not exists task_status as enum ('pendente', 'concluida');
create table if not exists public.tasks (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null,
  client_id uuid references public.clients(id) on delete set null,
  deal_id uuid references public.deals(id) on delete set null,
  title text not null,
  status task_status not null default 'pendente',
  due_date date,
  created_at timestamptz default now()
);

-- RLS
alter table public.profiles enable row level security;
alter table public.clients enable row level security;
alter table public.deals enable row level security;
alter table public.tasks enable row level security;

-- Policies
create policy "profiles_select_own" on public.profiles
for select using (auth.uid() = user_id);
create policy "profiles_insert_own" on public.profiles
for insert with check (auth.uid() = user_id);
create policy "profiles_update_own" on public.profiles
for update using (auth.uid() = user_id);

create policy "clients_select_own" on public.clients
for select using (auth.uid() = user_id);
create policy "clients_insert_own" on public.clients
for insert with check (auth.uid() = user_id);
create policy "clients_update_own" on public.clients
for update using (auth.uid() = user_id);
create policy "clients_delete_own" on public.clients
for delete using (auth.uid() = user_id);

create policy "deals_select_own" on public.deals
for select using (auth.uid() = user_id);
create policy "deals_insert_own" on public.deals
for insert with check (auth.uid() = user_id);
create policy "deals_update_own" on public.deals
for update using (auth.uid() = user_id);
create policy "deals_delete_own" on public.deals
for delete using (auth.uid() = user_id);

create policy "tasks_select_own" on public.tasks
for select using (auth.uid() = user_id);
create policy "tasks_insert_own" on public.tasks
for insert with check (auth.uid() = user_id);
create policy "tasks_update_own" on public.tasks
for update using (auth.uid() = user_id);
create policy "tasks_delete_own" on public.tasks
for delete using (auth.uid() = user_id);

-- Helpful indexes
create index if not exists idx_clients_user on public.clients(user_id, created_at desc);
create index if not exists idx_deals_user_stage on public.deals(user_id, stage, created_at desc);
create index if not exists idx_tasks_user_status on public.tasks(user_id, status, due_date, created_at desc);