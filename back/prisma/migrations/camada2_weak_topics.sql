-- Camada 2 — Análise de perfil Sonnet
-- Adiciona weak_topics e analyzed_at em study_plans para persistir o ranking de tópicos do Sonnet.

ALTER TABLE study_plans
  ADD COLUMN IF NOT EXISTS weak_topics  jsonb,
  ADD COLUMN IF NOT EXISTS analyzed_at  timestamptz;
