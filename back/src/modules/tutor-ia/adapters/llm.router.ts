import { ClaudeAdapter } from './claude.adapter';
import { SabiaAdapter } from './sabia.adapter';
import { LLMAdapter } from './llm.interface';

export type TutorMode = 'reading' | 'simulado' | 'direct';
export type QueryComplexity = 'high' | 'normal';

export interface TutorContext {
  mode: TutorMode;
  complexity?: QueryComplexity;
}

const claudeAdapter = new ClaudeAdapter();
const sabiaAdapter = new SabiaAdapter();

// Roteamento por modo e complexidade (spec LCF_ArquiteturaIA_MVP seção 4.2):
// simulado + high complexity → Claude Sonnet (~25% das queries)
// resto → Sabiá-4 (~75% das queries)
export function selectLLM(ctx: TutorContext): LLMAdapter {
  if (ctx.mode === 'simulado') return claudeAdapter;
  if (ctx.complexity === 'high') return claudeAdapter;
  return sabiaAdapter;
}
