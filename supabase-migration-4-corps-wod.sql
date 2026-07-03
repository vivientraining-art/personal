-- =====================================================================
--  Migration 4 — Âge/taille, composition corporelle, conditionnement
--  À exécuter dans Supabase → SQL Editor → New query → Run
--  (après supabase-migration-3-coaching-individuel.sql et 3b).
--
--  Ajoute :
--    • âge et taille sur la fiche client (peu changeants)
--    • poids & composition corporelle, suivis dans le temps
--    • séances de conditionnement AMRAP / EMOM / FOR TIME, avec les
--      exercices effectués, les répétitions et le temps réalisé
-- =====================================================================

-- ------------------------------------------------------------------
-- 1) Âge et taille sur la fiche client
-- ------------------------------------------------------------------
alter table public.coaching_clients add column if not exists age integer check (age between 5 and 110);
alter table public.coaching_clients add column if not exists taille_cm numeric check (taille_cm between 50 and 250);

-- ------------------------------------------------------------------
-- 2) Poids & composition corporelle (suivi dans le temps)
-- ------------------------------------------------------------------
create table if not exists public.body_metrics (
  id                   bigint generated always as identity primary key,
  client_id            bigint not null references public.coaching_clients (id) on delete cascade,
  coach_id             uuid not null references auth.users (id) on delete cascade,
  poids_kg             numeric check (poids_kg > 0),
  masse_grasse_pct     numeric check (masse_grasse_pct between 0 and 80),
  masse_musculaire_kg  numeric check (masse_musculaire_kg > 0),
  notes                text,
  recorded_at          timestamptz not null default now()
);
create index if not exists body_metrics_client_idx on public.body_metrics (client_id, recorded_at desc);

-- ------------------------------------------------------------------
-- 3) Conditionnement — AMRAP / EMOM / FOR TIME
--    exercises : [{ "exercice": "Burpees", "reps": 10 }, ...]
--    result_rounds/result_reps : répétitions réalisées (AMRAP/EMOM)
--    result_time_s : temps réalisé en secondes (FOR TIME notamment)
-- ------------------------------------------------------------------
create table if not exists public.wod_entries (
  id             bigint generated always as identity primary key,
  client_id      bigint not null references public.coaching_clients (id) on delete cascade,
  session_id     bigint references public.coaching_sessions (id) on delete cascade,
  coach_id       uuid not null references auth.users (id) on delete cascade,
  type           text not null check (type in ('amrap', 'emom', 'for_time')),
  cap_minutes    integer check (cap_minutes > 0),
  exercises      jsonb not null default '[]'::jsonb,
  result_rounds  integer check (result_rounds >= 0),
  result_reps    integer check (result_reps >= 0),
  result_time_s  integer check (result_time_s >= 0),
  notes          text,
  recorded_at    timestamptz not null default now()
);
create index if not exists wod_entries_client_idx on public.wod_entries (client_id, recorded_at desc);
create index if not exists wod_entries_session_idx on public.wod_entries (session_id);

-- ------------------------------------------------------------------
-- 4) Row Level Security — même principe que la migration 3
--    (coach propriétaire uniquement, via public.is_coach())
-- ------------------------------------------------------------------
alter table public.body_metrics enable row level security;
alter table public.wod_entries  enable row level security;

drop policy if exists "body_metrics_all" on public.body_metrics;
create policy "body_metrics_all" on public.body_metrics
  for all using (coach_id = auth.uid() and public.is_coach())
  with check (coach_id = auth.uid() and public.is_coach());

drop policy if exists "wod_entries_all" on public.wod_entries;
create policy "wod_entries_all" on public.wod_entries
  for all using (coach_id = auth.uid() and public.is_coach())
  with check (coach_id = auth.uid() and public.is_coach());

-- ------------------------------------------------------------------
-- 5) Permissions explicites (voir migration 3b — évite l'erreur
--    « permission denied for table » rencontrée sur les tables
--    précédentes : les privilèges par défaut du projet ne
--    s'appliquent pas toujours automatiquement).
-- ------------------------------------------------------------------
grant select, insert, update, delete on public.body_metrics, public.wod_entries to authenticated;
grant usage, select on sequence public.body_metrics_id_seq, public.wod_entries_id_seq to authenticated;
