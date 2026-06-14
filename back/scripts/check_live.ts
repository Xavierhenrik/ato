import { PrismaClient } from '@prisma/client';

async function main() {
  const raw = process.env.DATABASE_URL!;
  const url = raw.replace(':5432/', ':6543/').replace(/\?.*$/, '') + '?pgbouncer=true&connection_limit=1';
  const p = new PrismaClient({ datasources: { db: { url } } });
  const rows = await p.$queryRaw<{status:string,count:bigint}[]>`
    SELECT status, COUNT(*) as count FROM questions WHERE type='review' GROUP BY status ORDER BY status
  `;
  console.log('Review questions no live:');
  if (rows.length === 0) console.log('  (nenhuma)');
  rows.forEach(r => console.log(`  status=${r.status}  count=${r.count}`));
  await p.$disconnect();
}
main().catch(e => { console.error(e.message); process.exit(1); });
