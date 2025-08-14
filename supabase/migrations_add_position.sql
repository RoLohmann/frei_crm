-- Migration: add position ordering to deals
alter table if exists public.deals
  add column if not exists position int not null default 0;

-- optional: create an index to help ordering/lookups by user+stage+position
create index if not exists idx_deals_user_stage_position
  on public.deals(user_id, stage, position);

-- backfill example (set deterministic order by created_at for existing rows)
-- update public.deals d set position = sub.rn - 1
-- from (
--   select id, row_number() over (partition by user_id, stage order by created_at asc) as rn
--   from public.deals
-- ) sub
-- where sub.id = d.id;