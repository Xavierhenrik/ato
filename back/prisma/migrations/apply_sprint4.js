/**
 * Sprint 4 — Aplicar índices no SimuladoQuestion
 * 
 * Pré-requisito: npm install pg  (na pasta back/ ou globalmente)
 * Execução:      cd lcf/back && node prisma/migrations/apply_sprint4.js
 */
const { Client } = require('pg');

const SQL = `
CREATE INDEX IF NOT EXISTS "simulado_questions_is_correct_idx"
  ON "simulado_questions"("is_correct");

CREATE INDEX IF NOT EXISTS "simulado_questions_answered_at_idx"
  ON "simulado_questions"("answered_at");

CREATE INDEX IF NOT EXISTS "simulado_questions_attempt_id_is_correct_idx"
  ON "simulado_questions"("attempt_id", "is_correct");
`;

const VERIFY_SQL = `
SELECT indexname
FROM pg_indexes
WHERE tablename = 'simulado_questions'
  AND indexname IN (
    'simulado_questions_is_correct_idx',
    'simulado_questions_answered_at_idx',
    'simulado_questions_attempt_id_is_correct_idx'
  )
ORDER BY indexname;
`;

const DATABASES = [
  {
    label: 'STAGING',
    url: 'postgresql://postgres.zmwufyrpcdlmihjcsajh:do6qCilQoPsPHb1f@aws-1-us-west-2.pooler.supabase.com:5432/postgres',
  },
  {
    label: 'LIVE (produção)',
    url: 'postgresql://postgres.fovfrflxwksgyvnxvgst:wIIRwdzAUjEkhO0x@aws-1-us-west-2.pooler.supabase.com:5432/postgres',
  },
];

async function applyMigration({ label, url }) {
  const client = new Client({ connectionString: url, ssl: { rejectUnauthorized: false } });
  console.log(`\n=== ${label} ===`);
  try {
    await client.connect();
    console.log('Conectado.');
    await client.query(SQL);
    console.log('Migration aplicada.');
    const { rows } = await client.query(VERIFY_SQL);
    console.log(`Índices confirmados (${rows.length}/3):`);
    rows.forEach(r => console.log(`  OK  ${r.indexname}`));
    if (rows.length === 3) {
      console.log('SUCESSO — todos os 3 índices estão no banco.');
    } else {
      console.warn('AVISO — índices esperados não encontrados!');
    }
  } catch (err) {
    console.error('ERRO:', err.message);
  } finally {
    await client.end();
  }
}

(async () => {
  for (const db of DATABASES) {
    await applyMigration(db);
  }
})();
