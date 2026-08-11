-- Supabase Dashboard > SQL Editor에서 한 번 실행하세요.

create table if not exists public.photos (
  id uuid primary key,
  title text not null,
  original_name text not null,
  file_path text not null,
  lat double precision not null,
  lng double precision not null,
  created_at timestamptz not null default now()
);

create table if not exists public.map_zones (
  id integer primary key check (id = 1),
  features jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.photos enable row level security;
alter table public.map_zones enable row level security;

drop policy if exists "Public photo access" on public.photos;
drop policy if exists "Public zone access" on public.map_zones;
create policy "Public photo access" on public.photos for all using (true) with check (true);
create policy "Public zone access" on public.map_zones for all using (true) with check (true);

insert into storage.buckets (id, name, public)
values ('photo-files', 'photo-files', true)
on conflict (id) do update set public = true;

drop policy if exists "Public photo file access" on storage.objects;
create policy "Public photo file access" on storage.objects for all
using (bucket_id = 'photo-files')
with check (bucket_id = 'photo-files');
