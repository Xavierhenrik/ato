-- Sprint 4 — Índices na tabela simulado_questions
-- Índices adicionados ao model SimuladoQuestion para otimizar queries de resultados de simulado.

CREATE INDEX IF NOT EXISTS "simulado_questions_is_correct_idx"
  ON "simulado_questions"("is_correct");

CREATE INDEX IF NOT EXISTS "simulado_questions_answered_at_idx"
  ON "simulado_questions"("answered_at");

CREATE INDEX IF NOT EXISTS "simulado_questions_attempt_id_is_correct_idx"
  ON "simulado_questions"("attempt_id", "is_correct");
