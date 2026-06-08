import { ClaudeAdapter } from './claude.adapter';
import { SabiaAdapter } from './sabia.adapter';
import { SabiazinhoAdapter } from './sabiazinho.adapter';
import { LLMAdapter } from './llm.interface';

export type TutorMode = 'reading' | 'simulado' | 'direct';
export type QueryComplexity = 'high' | 'normal';

export interface TutorContext {
  mode: TutorMode;
  complexity?: QueryComplexity;
}

const claudeAdapter     = new ClaudeAdapter();
const sabiaAdapter      = new SabiaAdapter();
const sabiazinhoAdapter = new SabiazinhoAdapter();

const COMPLEX_VERBS = /\b(analise|compare|diferencie|justifique|explique|discorra|critique|fundamente)\b/i;
const ARTICLE_REF   = /\bart[\s.]?\s*\d+/i;
const LAW_NAME      = /\b(código civil|código penal|código de processo|clt|estatuto)\b/i;

function isDirectComplex(message: string): boolean {
  return (
    message.length > 200 ||
    COMPLEX_VERBS.test(message) ||
    ARTICLE_REF.test(message) ||
    LAW_NAME.test(message)
  );
}

function assessSimuladoComplexity(message: string): QueryComplexity {
  const isComplex =
    message.length > 150 ||
    /\b(explique|analise|justifique|discorra|compare|diferencie)\b/i.test(message);
  return isComplex ? 'high' : 'normal';
}

// Roteamento de modelos por modo e complexidade:
//   simulado complexo (>150 chars ou verbo analítico) → Claude Sonnet
//   simulado simples                                  → Sabiá-4
//   direct complexo (>200 chars, verbo, art. N, lei)  → Sabiá-4
//   direct simples                                    → Sabiázinho-4 (~5× mais barato)
//   reading + complexity high                         → Claude Sonnet
//   reading padrão                                    → Sabiá-4
export function selectLLM(ctx: TutorContext & { message?: string }): LLMAdapter {
  const msg = ctx.message ?? '';

  if (ctx.mode === 'simulado') {
    return assessSimuladoComplexity(msg) === 'high' ? claudeAdapter : sabiaAdapter;
  }

  if (ctx.mode === 'direct') {
    return isDirectComplex(msg) ? sabiaAdapter : sabiazinhoAdapter;
  }

  if (ctx.complexity === 'high') return claudeAdapter;
  return sabiaAdapter;
}
