-- =====================================================================
--  Migration 5 — Cardio
--  À exécuter dans Supabase → SQL Editor → New query → Run
--  (après les migrations 3, 3b et 4).
--
--  Ajoute le suivi cardio (course, vélo, rameur…) au sein d'une
--  séance, à côté du renforcement musculaire et du conditionnement.
-- =====================================================================

create table if not exists public.cardio_entries (
  id           bigint generated always as identity primary key,
  client_id    bigint not null references public.coaching_clients (id) on delete cascade,
  session_id   bigint references public.coaching_sessions (id) on delete cascade,
  coach_id     uuid not null references auth.users (id) on delete cascade,
  type         text not null,
  duree_min    numeric not null check (duree_min > 0),
  distance_km  numeric check (distance_km > 0),
  fc_moy       integer check (fc_moy between 40 and 230),
  calories     integer check (calories >= 0),
  recorded_at  timestamptz not null default now()
);
create index if not exists cardio_entries_client_idx on public.cardio_entries (client_id, recorded_at desc);
create index if not exists cardio_entries_session_idx on public.cardio_entries (session_id);

alter table public.cardio_entries enable row level security;

drop policy if exists "cardio_entries_all" on public.cardio_entries;
create policy "cardio_entries_all" on public.cardio_entries
  for all using (coach_id = auth.uid() and public.is_coach())
  with check (coach_id = auth.uid() and public.is_coach());

-- Permissions explicites (voir migration 3b) — évite "permission denied".
grant select, insert, update, delete on public.cardio_entries to authenticated;
grant usage, select on sequence public.cardio_entries_id_seq to authenticated;
