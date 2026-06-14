/**
 * import_review_live_fast.ts
 *
 * Importa questões de review_questions_export.json para o live
 * via createMany (bulk INSERT) — muito mais rápido que individual.
 *
 * Uso:
 *   npx tsx scripts/import_review_live_fast.ts   # usa .env (live)
 */

import { PrismaClient } from '@prisma/client';
import { readFileSync } from 'fs';

function txUrl(raw: string) {
  return raw.replace(':5432/', ':6543/').replace(/\?.*$/, '') + '?pgbouncer=true&connection_limit=1';
}

const BATCH = 200;

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
  console.log(`Total a importar: ${rows.length} questões`);

  const prisma = new PrismaClient({ datasources: { db: { url: txUrl(raw) } } });

  let inserted = 0;

  for (let i = 0; i < rows.length; i += BATCH) {
    const batch = rows.slice(i, i + BATCH);

    try {
      const result = await prisma.question.createMany({
        data: batch.map(q => ({
          id: q.id,
          externalId: q.external_id,
          statement: q.statement,
          options: q.options as object,
          correctAnswer: q.correct_answer,
          explanation: q.explanation,
          subject: q.subject,
          topic: q.topic,
          lawCode: q.law_code,
          board: q.board,
          year: q.year,
          phase: q.phase,
          difficulty: q.difficulty ?? 'medium',
          isPro: q.is_pro,
          type: q.type,
          source: q.source,
          topicId: q.topic_id,
          status: q.status,
          createdAt: new Date(q.created_at),
        })),
        skipDuplicates: true,
      });
      inserted += result.count;
    } catch (err) {
      // FK violation: algum topic_id não existe no live — tenta sem topicId
      console.error(`\n  Batch ${i}-${i+BATCH} falhou, tentando sem topicId...`);
      try {
        const result = await prisma.question.createMany({
          data: batch.map(q => ({
            id: q.id, externalId: q.external_id, statement: q.statement,
            options: q.options as object, correctAnswer: q.correct_answer,
            explanation: q.explanation, subject: q.subject, topic: q.topic,
            lawCode: q.law_code, board: q.board, year: q.year, phase: q.phase,
            difficulty: q.difficulty ?? 'medium', isPro: q.is_pro,
            type: q.type, source: q.source, topicId: null,
            status: q.status, createdAt: new Date(q.created_at),
          })),
          skipDuplicates: true,
        });
        inserted += result.count;
      } catch { /* skip batch */ }
    }

    const done = Math.min(i + BATCH, rows.length);
    process.stdout.write(`\r  ${done}/${rows.length} inseridas: ${inserted}`);
  }

  console.log(`\n✓ Inseridas: ${inserted} (novas)`);

  const [cnt] = await prisma.$queryRaw<{ count: bigint }[]>`
    SELECT COUNT(*) AS count FROM questions WHERE type = 'review' AND status = 'active'
  `;
  console.log(`  Live: ${cnt.count} questões review ativas`);

  await prisma.$disconnect();
}

main().catch(err => { console.error('\nERROR:', (err as Error).message); process.exit(1); });
