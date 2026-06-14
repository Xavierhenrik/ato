/**
 * apply_camada2_and_promote.ts
 *
 * 1. Aplica migration Camada 2 (weak_topics + analyzed_at em study_plans)
 * 2. Promove questões type:review de pending_review → active
 *
 * Uso:
 *   npx tsx scripts/apply_camada2_and_promote.ts              # usa .env
 *   dotenv -e .env.staging -- npx tsx scripts/apply_camada2_and_promote.ts
 */

import { PrismaClient } from '@prisma/client';

interface StatusRow { status: string; count: bigint }

async function main() {
  const rawUrl = process.env.DATABASE_URL;
  if (!rawUrl) {
    console.error('DATABASE_URL não definida. Forneça via .env ou variável de ambiente.');
    process.exit(1);
  }

  // Forçar transaction mode (porta 6543 + pgbouncer) para evitar EMAXCONNSESSION
  const url = rawUrl
    .replace(':5432/', ':6543/')
    .replace(/\?.*$/, '') + '?pgbouncer=true&connection_limit=1';

  console.log(`Conectando em modo transaction (6543)...`);
  const prisma = new PrismaClient({ datasources: { db: { url } } });

  console.log('[1/2] Migration: weak_topics + analyzed_at em study_plans');
  await prisma.$executeRaw`
    ALTER TABLE study_plans
      ADD COLUMN IF NOT EXISTS weak_topics  jsonb,
      ADD COLUMN IF NOT EXISTS analyzed_at  timestamptz
  `;
  console.log('  ✓ Colunas adicionadas (ou já existiam)');

  console.log('\n[2/2] Promover questões type:review → active');
  const before = await prisma.$queryRaw<StatusRow[]>`
    SELECT status, COUNT(*) AS count FROM questions WHERE type = 'review' GROUP BY status ORDER BY status
  `;
  console.log('  BEFORE:');
  before.forEach(r => console.log(`    status=${r.status}  count=${r.count}`));

  const promoted = await prisma.$executeRaw`
    UPDATE questions SET status = 'active' WHERE type = 'review' AND status = 'pending_review'
  `;
  console.log(`  UPDATED: ${promoted} rows`);

  const after = await prisma.$queryRaw<StatusRow[]>`
    SELECT status, COUNT(*) AS count FROM questions WHERE type = 'review' GROUP BY status ORDER BY status
  `;
  console.log('  AFTER:');
  after.forEach(r => console.log(`    status=${r.status}  count=${r.count}`));

  await prisma.$disconnect();
  console.log('\n✓ Concluído.');
}

main().catch(err => {
  console.error('ERROR:', (err as Error).message);
  process.exit(1);
});
