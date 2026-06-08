/**
 * promote_review_questions_prisma.ts
 *
 * Promove questões de revisão de pending_review → active
 * em STAGING e LIVE (Supabase) — usando @prisma/client (sem dependência extra).
 *
 * Uso (na raiz do back/):
 *   npx ts-node scripts/promote_review_questions_prisma.ts
 *
 * ou, se preferir compilar antes:
 *   npx tsc scripts/promote_review_questions_prisma.ts --outDir dist/scripts --esModuleInterop true
 *   node dist/scripts/promote_review_questions_prisma.js
 */

import { PrismaClient } from '@prisma/client';

const STAGING_URL = 'postgresql://postgres.zmwufyrpcdlmihjcsajh:do6qCilQoPsPHb1f@aws-1-us-west-2.pooler.supabase.com:5432/postgres';
const LIVE_URL    = 'postgresql://postgres.fovfrflxwksgyvnxvgst:wIIRwdzAUjEkhO0x@aws-1-us-west-2.pooler.supabase.com:5432/postgres';

interface StatusRow {
  status: string;
  count: bigint;
}

async function run(databaseUrl: string, label: string): Promise<number> {
  const prisma = new PrismaClient({
    datasources: { db: { url: databaseUrl } },
  });

  console.log(`\n=== ${label} ===`);

  const before = await prisma.$queryRaw<StatusRow[]>`
    SELECT status, COUNT(*) AS count
    FROM questions
    WHERE type = 'review'
    GROUP BY status
    ORDER BY status
  `;
  console.log('BEFORE:');
  before.forEach(r => console.log(`  status=${r.status}  count=${r.count}`));

  const result = await prisma.$executeRaw`
    UPDATE questions
    SET status = 'active'
    WHERE type = 'review'
      AND status = 'pending_review'
  `;
  console.log(`UPDATED: ${result} rows`);

  const after = await prisma.$queryRaw<StatusRow[]>`
    SELECT status, COUNT(*) AS count
    FROM questions
    WHERE type = 'review'
    GROUP BY status
    ORDER BY status
  `;
  console.log('AFTER:');
  after.forEach(r => console.log(`  status=${r.status}  count=${r.count}`));

  await prisma.$disconnect();
  return result;
}

(async () => {
  try {
    const stagingCount = await run(STAGING_URL, 'STAGING');
    const liveCount    = await run(LIVE_URL,    'LIVE');

    console.log('\n=== SUMMARY ===');
    console.log(`STAGING: ${stagingCount} rows updated`);
    console.log(`LIVE:    ${liveCount} rows updated`);
    console.log('\nDone.');
  } catch (err) {
    console.error('\nERROR:', (err as Error).message);
    process.exit(1);
  }
})();
