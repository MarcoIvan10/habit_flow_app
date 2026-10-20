-- ============================================================================
-- HabitFlow Mobile - Esquema PostgreSQL y Políticas RLS para Supabase
-- ============================================================================

-- 1. Tabla de Hábitos
create table if not exists public.habits (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null check (char_length(trim(name)) between 2 and 60),
  category text not null default 'Salud',
  icon text not null default '💧',
  color text not null default 'indigo',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Tabla de Registros Diarios (Check-ins)
create table if not exists public.habit_logs (
  id uuid default gen_random_uuid() primary key,
  habit_id uuid references public.habits(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  completed_date date not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(habit_id, completed_date)
);

-- 3. Índices de rendimiento para consultas frecuentes
create index if not exists idx_habits_user_created
  on public.habits(user_id, created_at);

create index if not exists idx_habit_logs_user_date
  on public.habit_logs(user_id, completed_date);

-- 4. Seguridad a Nivel de Fila (Row Level Security - RLS)
alter table public.habits enable row level security;
alter table public.habit_logs enable row level security;

drop policy if exists "Acceso total a hábitos propios" on public.habits;
create policy "Acceso total a hábitos propios"
  on public.habits for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "Acceso total a registros propios" on public.habit_logs;
create policy "Acceso total a registros propios"
  on public.habit_logs for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

