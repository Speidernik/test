-- ─────────────────────────────────────────────────────────────────────────────
-- Todo App — Supabase schema
--
-- Run this in your Supabase project under SQL Editor → New query.
-- After running, copy your project URL and anon key into:
--   lib/core/config/app_config.dart
-- ─────────────────────────────────────────────────────────────────────────────

-- ── Tables ────────────────────────────────────────────────────────────────────

create table if not exists public.lists (
  id          uuid        primary key default gen_random_uuid(),
  name        text        not null,
  owner_id    uuid        references auth.users (id) on delete cascade not null,
  share_code  text        unique not null
                          default upper(substr(md5(random()::text), 1, 6)),
  created_at  timestamptz not null default now()
);

create table if not exists public.list_members (
  list_id  uuid references public.lists (id) on delete cascade,
  user_id  uuid references auth.users (id)   on delete cascade,
  primary key (list_id, user_id)
);

create table if not exists public.todos (
  id           text        primary key,
  list_id      uuid        references public.lists (id) on delete cascade not null,
  title        text        not null,
  description  text        not null default '',
  is_completed boolean     not null default false,
  priority     int         not null default 1,   -- 0=low 1=medium 2=high
  category     int,                               -- matches TodoCategory enum index
  due_date     timestamptz,
  reminder     timestamptz,                       -- exact date+time for local notification
  subtasks     text        not null default '[]', -- JSON array of Subtask objects
  created_by   uuid        references auth.users (id) on delete set null,
  updated_by   uuid        references auth.users (id) on delete set null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- Keep updated_at current automatically
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists todos_updated_at on public.todos;
create trigger todos_updated_at
  before update on public.todos
  for each row execute procedure public.set_updated_at();

-- ── Row Level Security ────────────────────────────────────────────────────────

alter table public.lists        enable row level security;
alter table public.list_members enable row level security;
alter table public.todos        enable row level security;

-- Lists: visible to members only
create policy "Members can view their lists"
  on public.lists for select
  using (
    id in (
      select list_id from public.list_members where user_id = auth.uid()
    )
  );

-- Lists: owner can insert / update / delete
create policy "Owner can manage their lists"
  on public.lists for all
  using (owner_id = auth.uid());

-- list_members: members can view membership rows for their lists
create policy "Members can view memberships"
  on public.list_members for select
  using (
    list_id in (
      select list_id from public.list_members where user_id = auth.uid()
    )
  );

-- list_members: any authenticated user can join (insert themselves)
create policy "Users can join lists"
  on public.list_members for insert
  with check (user_id = auth.uid());

-- Todos: full CRUD for list members
create policy "Members can manage todos"
  on public.todos for all
  using (
    list_id in (
      select list_id from public.list_members where user_id = auth.uid()
    )
  );

-- ── Realtime ──────────────────────────────────────────────────────────────────

-- Enable realtime for the todos table so collaborators see live updates.
alter publication supabase_realtime add table public.todos;
