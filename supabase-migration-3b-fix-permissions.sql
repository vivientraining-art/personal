-- =====================================================================
--  Migration 3b — Correctif de permissions (coaching individuel)
--  À exécuter dans Supabase → SQL Editor → New query → Run
--  (après supabase-migration-3-coaching-individuel.sql)
--
--  Si l'ajout d'un client (ou d'une séance / série) renvoie une erreur
--  du type « permission denied for table coaching_clients », c'est que
--  les privilèges par défaut du projet Supabase ne se sont pas
--  appliqués automatiquement aux nouvelles tables créées par la
--  migration 3. Ce script les accorde explicitement au rôle
--  "authenticated".
--
--  Ce correctif ne touche PAS à la sécurité : les règles RLS
--  installées par la migration 3 (coach_id = auth.uid() et
--  public.is_coach()) continuent de s'appliquer et restent la seule
--  protection réelle des données — ce script autorise seulement le
--  rôle à accéder à la table, sans contourner ces règles.
-- =====================================================================

grant select, insert, update, delete
  on public.coaching_clients, public.coaching_sessions, public.strength_sets
  to authenticated;

grant usage, select
  on sequence public.coaching_clients_id_seq,
             public.coaching_sessions_id_seq,
             public.strength_sets_id_seq
  to authenticated;
