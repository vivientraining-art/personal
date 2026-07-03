-- =====================================================================
--  Migration 6 — Temps de repos entre les séries
--  À exécuter dans Supabase → SQL Editor → New query → Run
--  (après les migrations précédentes).
--
--  Ajoute une colonne pour enregistrer le temps de repos écoulé
--  depuis la série précédente (null pour la toute première série
--  d'une séance). Aucun nouveau droit à accorder : les permissions
--  déjà données sur strength_sets (migration 3b) couvrent aussi les
--  colonnes ajoutées ensuite.
-- =====================================================================

alter table public.strength_sets add column if not exists repos_s integer check (repos_s >= 0);
