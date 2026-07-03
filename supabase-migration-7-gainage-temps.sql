-- =====================================================================
--  Migration 7 — Exercices chronométrés (gainage, etc.)
--  À exécuter dans Supabase → SQL Editor → New query → Run
--  (après les migrations précédentes).
--
--  Certains exercices (gainage, gainage latéral...) se mesurent en
--  durée tenue, pas en répétitions ni en charge. Cette migration
--  assouplit les colonnes concernées et ajoute une durée en secondes.
--  Les entrées "classiques" (charge × reps) ne changent pas.
-- =====================================================================

alter table public.strength_sets alter column kg drop not null;
alter table public.strength_sets alter column reps drop not null;
alter table public.strength_sets alter column tonnage drop not null;
alter table public.strength_sets alter column e1rm drop not null;

alter table public.strength_sets add column if not exists duree_s integer check (duree_s > 0);

alter table public.strength_sets drop constraint if exists strength_sets_reps_or_duree_check;
alter table public.strength_sets add constraint strength_sets_reps_or_duree_check
  check (reps is not null or duree_s is not null);
