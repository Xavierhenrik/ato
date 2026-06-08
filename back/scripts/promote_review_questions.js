/**
 * promote_review_questions.js
 *
 * Promove questões de revisão de pending_review → active
 * em STAGING e LIVE (Supabase).
 *
 * Uso:
 *   node back/scripts/promote_review_questions.js
 *
 * Requer: pacote 'pg' instalado
 *   npm install pg   (se necessário)
 */

const { Client } = require('pg');

const STAGING = 'postgresql://postgres.zmwufyrpcdlmihjcsajh:do6qCilQoPsPHb1f@aws-1-us-west-2.pooler.supabase.com:5432/postgres';
const LIVE    = 'postgresql://postgres.fovfrflxwksgyvnxvgst:wIIRwdzAUjEkhO0x@aws-1-us-west-2.pooler.supabase.com:5432/postgres';

async function run(connectionString, label) {
  const client = new Client({ connectionString, ssl: { rejectUnauthorized: false } });
  await client.connect();

  console.log(`\n=== ${label} ===`);

  const before = await client.query(
    "SELECT status, COUNT(*) AS count FROM questions WHERE type = 'review' GROUP BY status ORDER BY status"
  );
  console.log('BEFORE:');
  before.rows.forEach(r => console.log(`  status=${r.status}  count=${r.count}`));

  const result = await client.query(
    "UPDATE questions SET status = 'active' WHERE type = 'review' AND status = 'pending_review'"
  );
  console.log(`UPDATED: ${result.rowCount} rows`);

  const after = await client.query(
    "SELECT status, COUNT(*) AS count FROM questions WHERE type = 'review' GROUP BY status ORDER BY status"
  );
  console.log('AFTER:');
  after.rows.forEach(r => console.log(`  status=${r.status}  count=${r.count}`));

  await client.end();
  return result.rowCount;
}

(async () => {
  try {
    const stagingCount = await run(STAGING, 'STAGING');
    const liveCount    = await run(LIVE,    'LIVE');

    console.log('\n=== SUMMARY ===');
    console.log(`STAGING: ${stagingCount} rows updated`);
    console.log(`LIVE:    ${liveCount} rows updated`);
    console.log('\nDone. Delete this script after use if desired.');
  } catch (err) {
    console.error('\nERROR:', err.message);
    process.exit(1);
  }
})();
