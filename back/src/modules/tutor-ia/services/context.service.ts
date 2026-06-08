import { SYSTEM_PROMPT } from '../prompts/system.prompt';
import { buildReadingContext } from '../prompts/context-reading';
import { buildSimuladoContext, QuestionBundle } from '../prompts/context-simulado';
import { TutorMode } from '../adapters/llm.router';

export interface TutorRequestContext {
  mode: TutorMode;
  topicTitle?: string;
  topicContent?: string;
  questionBundle?: QuestionBundle;
}

export class ContextService {
  build(ctx: TutorRequestContext): string {
    const modeContext = this.buildModeContext(ctx);
    return modeContext ? `${SYSTEM_PROMPT}\n\n${modeContext}` : SYSTEM_PROMPT;
  }

  private buildModeContext(ctx: TutorRequestContext): string {
    if (ctx.mode === 'reading' && ctx.topicTitle && ctx.topicContent) {
      return buildReadingContext(ctx.topicTitle, ctx.topicContent);
    }
    if (ctx.mode === 'simulado' && ctx.questionBundle) {
      return buildSimuladoContext(ctx.questionBundle);
    }
    return '';
  }
}
