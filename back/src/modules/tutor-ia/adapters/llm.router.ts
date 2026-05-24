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

function assessComplexity(message: string, mode: TutorMode): QueryComplexity {
  if (mode !== 'simulado') return 'normal';
  const isComplex =
    message.length > 150 ||
    /\b(explique|analise|justifique|discorra|compare|diferencie)\b/i.test(message);
  return isComplex ? 'high' : 'normal';
}

// simulado + query complexa (>150 chars ou verbo analítico) → Claude Sonnet (~25% das queries)
// simulado simples + outros modos → Sabiá-4 (~75% das queries)
export function selectLLM(ctx: TutorContext & { message?: string }): LLMAdapter {
  if (ctx.mode === 'simulado') {
    const complexity = assessComplexity(ctx.message ?? '', ctx.mode);
    return complexity === 'high' ? claudeAdapter : sabiaAdapter;
  }
  if (ctx.complexity === 'high') return claudeAdapter;
  return sabiaAdapter;
}
