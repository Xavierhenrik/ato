/**
 * import_review_live.ts — Passo 2/2
 *
 * Importa questões de review_questions_export.json para o live (upsert por id).
 *
 * Uso:
 *   npx tsx scripts/import_review_live.ts   # usa .env (live)
 */

import { PrismaClient } from '@prisma/client';
import { readFileSync } from 'fs';

function txUrl(raw: string) {
  return raw.replace(':5432/', ':6543/').replace(/\?.*$/, '') + '?pgbouncer=true&connection_limit=1';
}

const BATCH = 100;

interface QRow {
  id: string; external_id: string | null; statement: string;
  options: object; correct_answer: string; explanation: string | null;
  subject: string; topic: string | null; law_code: string | null;
  board: string | null; year: number | null; phase: string | null;
  difficulty: string | null; is_pro: boolean; type: string; source: string;
  topic_id: string | null; status: string; created_at: string;
}

async function main() {
  const raw = process.env.DATABASE_URL;
  if (!raw) { console.error('DATABASE_URL não definida.'); process.exit(1); }

  const rows: QRow[] = JSON.parse(readFileSync('scripts/review_questions_export.json', 'utf8'));
  console.log(`Importando ${rows.length} questões para o live...`);

  const prisma = new PrismaClient({ datasources: { db: { url: txUrl(raw) } } });

  let inserted = 0;
  let skipped  = 0;

  for (let i = 0; i < rows.length; i += BATCH) {
    const batch = rows.slice(i, i + BATCH);

    for (const q of batch) {
      try {
        const optJson = JSON.stringify(q.options);
        const createdAt = new Date(q.created_at);
        await prisma.$executeRaw`
          INSERT INTO questions (
            id, external_id, statement, options, correct_answer, explanation,
            subject, topic, law_code, board, year, phase, difficulty, is_pro,
            type, source, topic_id, status, created_at
          ) VALUES (
            ${q.id}::uuid, ${q.external_id}, ${q.statement}, ${optJson}::jsonb,
            ${q.correct_answer}, ${q.explanation}, ${q.subject}, ${q.topic},
            ${q.law_code}, ${q.board}, ${q.year}::integer, ${q.phase}, ${q.difficulty},
            ${q.is_pro}, ${q.type}, ${q.source},
            ${q.topic_id ? q.topic_id + '::uuid' : null},
            ${q.status}, ${createdAt}
          )
          ON CONFLICT (id) DO NOTHING
        `;
        inserted++;
      } catch {
        skipped++;
      }
    }

    const done = Math.min(i + BATCH, rows.length);
    process.stdout.write(`\r  ${done}/${rows.length} (skip: ${skipped})`);
  }

  console.log(`\n✓ Inseridas: ${inserted} | Conflitos/skip: ${skipped}`);

  const [cnt] = await prisma.$queryRaw<{ count: bigint }[]>`
    SELECT COUNT(*) AS count FROM questions WHERE type = 'review' AND status = 'active'
  `;
  console.log(`  Live: ${cnt.count} questões review ativas`);

  await prisma.$disconnect();
}

main().catch(err => { console.error('ERROR:', (err as Error).message); process.exit(1); });
