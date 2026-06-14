/**
 * copy_review_questions_to_live.ts
 *
 * Copia questões type:review do staging para o live em lotes (upsert por external_id).
 * Executa sem credenciais hardcoded — lê de DATABASE_URL e LIVE_DATABASE_URL.
 *
 * Uso:
 *   LIVE_DATABASE_URL="..." dotenv -e .env.staging -- npx tsx scripts/copy_review_questions_to_live.ts
 */

import { PrismaClient, Prisma } from '@prisma/client';

function txUrl(raw: string) {
  return raw.replace(':5432/', ':6543/').replace(/\?.*$/, '') + '?pgbouncer=true&connection_limit=1';
}

const BATCH = 200;

async function main() {
  const stagingRaw = process.env.DATABASE_URL;
  const liveRaw    = process.env.LIVE_DATABASE_URL;

  if (!stagingRaw || !liveRaw) {
    console.error('Requer DATABASE_URL (staging) e LIVE_DATABASE_URL (live).');
    process.exit(1);
  }

  const staging = new PrismaClient({ datasources: { db: { url: txUrl(stagingRaw) } } });
  const live    = new PrismaClient({ datasources: { db: { url: txUrl(liveRaw)    } } });

  console.log('Lendo questões type:review do staging...');
  const questions = await staging.$queryRaw<{
    id: string; external_id: string | null; statement: string; options: Prisma.JsonValue;
    correct_answer: string; explanation: string | null; subject: string; topic: string | null;
    law_code: string | null; board: string | null; year: number | null; phase: string | null;
    difficulty: string | null; is_pro: boolean; type: string; source: string;
    topic_id: string | null; status: string; created_at: Date;
  }[]>`
    SELECT id, external_id, statement, options, correct_answer, explanation,
           subject, topic, law_code, board, year, phase, difficulty, is_pro,
           type, source, topic_id, status, created_at
    FROM questions
    WHERE type = 'review'
    ORDER BY created_at
  `;

  console.log(`  ${questions.length} questões encontradas no staging`);
  if (questions.length === 0) { console.log('Nada a migrar.'); process.exit(0); }

  let inserted = 0;
  let skipped  = 0;

  for (let i = 0; i < questions.length; i += BATCH) {
    const batch = questions.slice(i, i + BATCH);

    for (const q of batch) {
      try {
        await live.$executeRaw`
          INSERT INTO questions (
            id, external_id, statement, options, correct_answer, explanation,
            subject, topic, law_code, board, year, phase, difficulty, is_pro,
            type, source, topic_id, status, created_at
          ) VALUES (
            ${q.id}::uuid, ${q.external_id}, ${q.statement}, ${q.options}::jsonb,
            ${q.correct_answer}, ${q.explanation}, ${q.subject}, ${q.topic},
            ${q.law_code}, ${q.board}, ${q.year}, ${q.phase}, ${q.difficulty},
            ${q.is_pro}, ${q.type}, ${q.source}, ${q.topic_id}::uuid,
            ${q.status}, ${q.created_at}
          )
          ON CONFLICT (id) DO NOTHING
        `;
        inserted++;
      } catch {
        skipped++;
      }
    }

    const done = Math.min(i + BATCH, questions.length);
    process.stdout.write(`\r  Progresso: ${done}/${questions.length} (${skipped} conflitos)`);
  }

  console.log(`\n\n✓ Inseridas: ${inserted} | Conflitos/skip: ${skipped}`);

  // Verificar resultado
  const [liveCount] = await live.$queryRaw<{ count: bigint }[]>`
    SELECT COUNT(*) AS count FROM questions WHERE type = 'review' AND status = 'active'
  `;
  console.log(`  Live: ${liveCount.count} questões review ativas`);

  await staging.$disconnect();
  await live.$disconnect();
}

main().catch(err => {
  console.error('ERROR:', (err as Error).message);
  process.exit(1);
});
