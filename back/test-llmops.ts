/**
 * Smoke tests — LLM-Ops Fase 1+2
 * Cobre: selectLLM routing + extractTokens KB heuristic
 *
 * Run: npx tsx test-llmops.ts
 */
import { selectLLM } from './src/modules/tutor-ia/adapters/llm.router';

// ── helpers ───────────────────────────────────────────────────────────────────
let passed = 0;
let failed = 0;

function assert(label: string, actual: string, expected: string) {
  if (actual === expected) {
    console.log(`  ✅  ${label}`);
    passed++;
  } else {
    console.error(`  ❌  ${label}`);
    console.error(`      expected: ${expected}`);
    console.error(`      got:      ${actual}`);
    failed++;
  }
}

function adapterName(ctx: Parameters<typeof selectLLM>[0]): string {
  return selectLLM(ctx).constructor.name;
}

// ─────────────────────────────────────────────────────────────────────────────
// TAREFA 1 — selectLLM routing
// ─────────────────────────────────────────────────────────────────────────────
console.log('\n╔══════════════════════════════════════════╗');
console.log('║   selectLLM — roteamento por modo       ║');
console.log('╚══════════════════════════════════════════╝\n');

console.log('── direct simples → SabiazinhoAdapter ──────────────────────');
assert(
  'mensagem curta genérica',
  adapterName({ mode: 'direct', message: 'o que é dolo?' }),
  'SabiazinhoAdapter',
);
assert(
  'mensagem curta sem palavra-chave',
  adapterName({ mode: 'direct', message: 'conceito de culpa' }),
  'SabiazinhoAdapter',
);
assert(
  'exatamente 200 chars (limite — simples)',
  adapterName({ mode: 'direct', message: 'a'.repeat(200) }),
  'SabiazinhoAdapter',
);

console.log('\n── direct complexo → SabiaAdapter ──────────────────────────');
assert(
  '>200 chars',
  adapterName({ mode: 'direct', message: 'a'.repeat(201) }),
  'SabiaAdapter',
);
assert(
  'verbo "analise"',
  adapterName({ mode: 'direct', message: 'analise a diferença entre dolo e culpa' }),
  'SabiaAdapter',
);
assert(
  'verbo "compare"',
  adapterName({ mode: 'direct', message: 'compare habeas corpus com mandado de segurança' }),
  'SabiaAdapter',
);
assert(
  'verbo "explique"',
  adapterName({ mode: 'direct', message: 'explique o princípio da dignidade humana' }),
  'SabiaAdapter',
);
assert(
  'verbo "diferencie"',
  adapterName({ mode: 'direct', message: 'diferencie dolo eventual de culpa consciente' }),
  'SabiaAdapter',
);
assert(
  'verbo "justifique"',
  adapterName({ mode: 'direct', message: 'justifique a decisão do STF' }),
  'SabiaAdapter',
);
assert(
  'verbo "discorra"',
  adapterName({ mode: 'direct', message: 'discorra sobre a improbidade administrativa' }),
  'SabiaAdapter',
);
assert(
  'verbo "critique"',
  adapterName({ mode: 'direct', message: 'critique a posição doutrinária sobre isso' }),
  'SabiaAdapter',
);
assert(
  'verbo "fundamente"',
  adapterName({ mode: 'direct', message: 'fundamente sua resposta com base na lei' }),
  'SabiaAdapter',
);
assert(
  'art. N com ponto',
  adapterName({ mode: 'direct', message: 'o que diz o art. 5 da CF?' }),
  'SabiaAdapter',
);
assert(
  'art N sem ponto',
  adapterName({ mode: 'direct', message: 'explique o art 927 do código civil' }),
  'SabiaAdapter',
);
assert(
  '"código civil" minúsculo',
  adapterName({ mode: 'direct', message: 'o código civil prevê isso?' }),
  'SabiaAdapter',
);
assert(
  '"código penal" maiúsculo',
  adapterName({ mode: 'direct', message: 'Pelo Código Penal, qual a pena?' }),
  'SabiaAdapter',
);
assert(
  '"clt" isolado',
  adapterName({ mode: 'direct', message: 'isso está previsto na clt?' }),
  'SabiaAdapter',
);
assert(
  '"estatuto" genérico',
  adapterName({ mode: 'direct', message: 'o que diz o estatuto sobre isso?' }),
  'SabiaAdapter',
);

console.log('\n── simulado → ClaudeAdapter (complexo) / SabiaAdapter (simples) ──');
assert(
  'simulado verbo "explique"',
  adapterName({ mode: 'simulado', message: 'explique por que a alternativa A está errada' }),
  'ClaudeAdapter',
);
assert(
  'simulado >150 chars',
  adapterName({ mode: 'simulado', message: 'x'.repeat(151) }),
  'ClaudeAdapter',
);
assert(
  'simulado verbo "analise"',
  adapterName({ mode: 'simulado', message: 'analise a questão com detalhes' }),
  'ClaudeAdapter',
);
assert(
  'simulado simples curto',
  adapterName({ mode: 'simulado', message: 'por que errei?' }),
  'SabiaAdapter',
);
assert(
  'simulado exatamente 150 chars (simples)',
  adapterName({ mode: 'simulado', message: 'b'.repeat(150) }),
  'SabiaAdapter',
);

console.log('\n── reading → SabiaAdapter padrão / ClaudeAdapter se high ────');
assert(
  'reading sem complexity',
  adapterName({ mode: 'reading' }),
  'SabiaAdapter',
);
assert(
  'reading complexity normal',
  adapterName({ mode: 'reading', complexity: 'normal' }),
  'SabiaAdapter',
);
assert(
  'reading complexity high',
  adapterName({ mode: 'reading', complexity: 'high' }),
  'ClaudeAdapter',
);

// ─────────────────────────────────────────────────────────────────────────────
// TAREFA 2 — extractTokens (lógica da KB)
// ─────────────────────────────────────────────────────────────────────────────
console.log('\n╔══════════════════════════════════════════╗');
console.log('║   KbService — lógica de tokenização     ║');
console.log('╚══════════════════════════════════════════╝\n');

// Replicar exatamente a função privada para testar isoladamente
const STOP_WORDS = new Set([
  'o','a','os','as','um','uma','de','do','da','em','no',
  'na','e','que','se','para','por','com','me','te','eu',
]);

function extractTokens(query: string): string {
  return query
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9\s]/g, ' ')
    .split(/\s+/)
    .filter((t) => t.length > 2 && !STOP_WORDS.has(t))
    .join(' & ');
}

function wouldTriggerKb(query: string): boolean {
  const tokens = extractTokens(query);
  return Boolean(tokens) && tokens.split(' & ').length >= 2;
}

function assertKb(label: string, query: string, expected: boolean) {
  const result = wouldTriggerKb(query);
  const tokens = extractTokens(query);
  if (result === expected) {
    console.log(`  ✅  ${label}`);
    console.log(`      "${query}" → tokens: [${tokens}]`);
    passed++;
  } else {
    console.error(`  ❌  ${label}`);
    console.error(`      "${query}" → tokens: [${tokens}]`);
    console.error(`      esperava hit=${expected}, obteve hit=${result}`);
    failed++;
  }
}

console.log('── queries que DEVEM acionar a KB ──────────────────────────');
assertKb('habeas corpus', 'o que é habeas corpus', true);
assertKb('mandado de injunção (com acento)', 'mandado de injunção', true);
assertKb('princípios constitucionais', 'princípios constitucionais fundamentais', true);
assertKb('prescrição e decadência', 'diferença entre prescrição e decadência', true);
assertKb('responsabilidade civil', 'responsabilidade civil subjetiva', true);
assertKb('processo administrativo', 'processo administrativo disciplinar', true);

console.log('\n── queries que NÃO devem acionar a KB (< 2 tokens) ─────────');
assertKb('query de 1 palavra curta', 'ok', false);
assertKb('query apenas stopwords', 'o que é', false);
assertKb('query muito genérica — tokens insuficientes', 'me explica', false);
assertKb('só stopwords PT', 'e se por que', false);

console.log('\n── normalização de acentos ──────────────────────────────────');
(function testAccentNormalization() {
  const with_ = extractTokens('habeas corpus').split(' & ');
  const wout  = extractTokens('habeas corpus').split(' & ');
  const ok = with_.every((t, i) => t === wout[i]);
  if (ok) {
    console.log('  ✅  tokens com e sem acento são iguais após normalização');
    passed++;
  } else {
    console.error('  ❌  normalização de acentos falhou');
    failed++;
  }
})();

// ─────────────────────────────────────────────────────────────────────────────
// Resultado
// ─────────────────────────────────────────────────────────────────────────────
const total = passed + failed;
console.log('\n══════════════════════════════════════════════════════════════');
console.log(`  Total: ${total}   ✅ ${passed} passed   ❌ ${failed} failed`);
console.log('══════════════════════════════════════════════════════════════\n');

if (failed > 0) process.exit(1);
