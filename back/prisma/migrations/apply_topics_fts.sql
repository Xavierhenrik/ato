-- Índice BM25 para KB estática de tópicos (KbService)
-- Executar via psql no Supabase — não via Prisma (tsvector é Unsupported no schema).
--
-- Verificar se já existe antes de rodar:
--   SELECT COUNT(*) FROM topics WHERE content_tsv IS NOT NULL;
-- Se retornar 0, executar este script.

-- 1. Adiciona coluna (idempotente)
ALTER TABLE topics ADD COLUMN IF NOT EXISTS content_tsv tsvector;

-- 2. Popula com title + content (content = resumo didático gerado pelo ETL Sabiá-4)
UPDATE topics
SET content_tsv = to_tsvector('portuguese_unaccent', coalesce(title, '') || ' ' || coalesce(content, ''))
WHERE content IS NOT NULL;

-- 3. Trigger para manter sincronizado em upserts futuros
CREATE OR REPLACE FUNCTION topics_tsvector_update() RETURNS trigger AS $$
BEGIN
  NEW.content_tsv := to_tsvector(
    'portuguese_unaccent',
    coalesce(NEW.title, '') || ' ' || coalesce(NEW.content, '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS topics_tsv_upd ON topics;
CREATE TRIGGER topics_tsv_upd
BEFORE INSERT OR UPDATE ON topics
FOR EACH ROW EXECUTE FUNCTION topics_tsvector_update();

-- 4. Índice GIN para buscas rápidas
CREATE INDEX IF NOT EXISTS idx_topics_fts ON topics USING gin(content_tsv);

-- Verificação:
-- SELECT COUNT(*) FROM topics WHERE content_tsv IS NOT NULL;  -- deve retornar ~1883
