-- ============================================================================
-- HabitFlow Mobile - PostgreSQL Schema, Constraints, and OWASP RLS Policies
-- ============================================================================

-- 1. Habits Table
create table if not exists public.habits (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null check (char_length(trim(name)) between 2 and 60),
  category text not null default 'Salud' check (
    category in ('Salud', 'Deporte', 'Mente', 'Productividad', 'Finanzas')
  ),
  icon text not null default '💧' check (char_length(icon) between 1 and 16),
  color text not null default 'indigo' check (
    color in ('indigo', 'emerald', 'amber', 'rose', 'cyan', 'purple')
  ),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Daily Check-in Logs Table
create table if not exists public.habit_logs (
  id uuid default gen_random_uuid() primary key,
  habit_id uuid references public.habits(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  completed_date date not null check (completed_date <= (current_date + 1)),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(habit_id, completed_date)
);

-- 3. Performance Indexes
create index if not exists idx_habits_user_created
  on public.habits(user_id, created_at);

create index if not exists idx_habit_logs_user_date
  on public.habit_logs(user_id, completed_date);

create index if not exists idx_habit_logs_habit_id
  on public.habit_logs(habit_id);

-- 4. Row Level Security (OWASP A01 Broken Access Control & Anti-IDOR)
alter table public.habits enable row level security;
alter table public.habit_logs enable row level security;

drop policy if exists "Acceso total a hábitos propios" on public.habits;
drop policy if exists "Users can manage their own habits" on public.habits;
create policy "Users can manage their own habits"
  on public.habits for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Acceso total a registros propios" on public.habit_logs;
drop policy if exists "Users can manage logs for their own habits" on public.habit_logs;
create policy "Users can manage logs for their own habits"
  on public.habit_logs for all
  using (
    auth.uid() = user_id
    and exists (
      select 1
      from public.habits h
      where h.id = habit_logs.habit_id
        and h.user_id = auth.uid()
    )
  )
  with check (
    auth.uid() = user_id
    and exists (
      select 1
      from public.habits h
      where h.id = habit_logs.habit_id
        and h.user_id = auth.uid()
    )
  );
