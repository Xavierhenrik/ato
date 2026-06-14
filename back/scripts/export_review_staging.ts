/**
 * export_review_staging.ts — Passo 1/2
 *
 * Exporta questões type:review do staging para review_questions_export.json.
 *
 * Uso:
 *   dotenv -e .env.staging -- npx tsx scripts/export_review_staging.ts
 */

import { PrismaClient, Prisma } from '@prisma/client';
import { writeFileSync } from 'fs';

function txUrl(raw: string) {
  return raw.replace(':5432/', ':6543/').replace(/\?.*$/, '') + '?pgbouncer=true&connection_limit=1';
}

async function main() {
  const raw = process.env.DATABASE_URL;
  if (!raw) { console.error('DATABASE_URL não definida.'); process.exit(1); }

  const prisma = new PrismaClient({ datasources: { db: { url: txUrl(raw) } } });

  console.log('Exportando questões type:review do staging...');
  const rows = await prisma.$queryRaw<object[]>(Prisma.sql`
    SELECT id, external_id, statement, options, correct_answer, explanation,
           subject, topic, law_code, board, year, phase, difficulty, is_pro,
           type, source, topic_id, status, created_at
    FROM questions
    WHERE type = 'review'
    ORDER BY created_at
  `);

  await prisma.$disconnect();

  const outFile = 'scripts/review_questions_export.json';
  writeFileSync(outFile, JSON.stringify(rows, null, 0));
  console.log(`✓ ${rows.length} questões exportadas → ${outFile}`);
}

main().catch(err => { console.error('ERROR:', (err as Error).message); process.exit(1); });
