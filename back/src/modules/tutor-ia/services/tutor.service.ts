import { selectLLM, TutorMode } from '../adapters/llm.router';
import { ChatMessage, ToolResultBlock } from '../adapters/llm.interface';
import { LOOKUP_ARTICLE_TOOL } from '../tools/lookup-article.tool';
import { SEARCH_LEGISLATION_TOOL } from '../tools/search-legislation.tool';
import { SessionService } from './session.service';
import { ContextService, TutorRequestContext } from './context.service';
import { CitationService } from './citation.service';
import { TutorResponse } from '../schemas/tutor-response.schema';
import { QuestionBundle } from '../prompts/context-simulado';
import { Errors } from '../../../shared/errors';
import { db } from '../../../shared/db';

const TOOLS = [LOOKUP_ARTICLE_TOOL, SEARCH_LEGISLATION_TOOL];

export interface TutorRequest {
  sessionId: string;
  userId: string;
  message: string;
  mode: TutorMode;
  isPro: boolean;
  context?: {
    topic_id?: string;
    topic_content?: string;
    topic_title?: string;
    question_bundle?: QuestionBundle;
  };
  logger?: { info(obj: Record<string, unknown>, msg: string): void };
}

export class TutorService {
  private sessionSvc = new SessionService();
  private contextSvc = new ContextService();
  private citationSvc = new CitationService();

  async chat(req: TutorRequest): Promise<TutorResponse & { autoSavedAnnotationId?: string }> {
    // Rate limit check
    const rate = await this.sessionSvc.checkRateLimit(req.userId, req.isPro);
    if (!rate.allowed) {
      throw Errors.rateLimited(req.isPro ? 'pro' : 'free');
    }

    const ctx: TutorRequestContext = {
      mode: req.mode,
      topicTitle: req.context?.topic_title,
      topicContent: req.context?.topic_content,
      questionBundle: req.context?.question_bundle,
    };

    const maxTokens = req.mode === 'simulado' ? 1024 : req.mode === 'reading' ? 768 : 512;
    const adapter = selectLLM({ mode: req.mode, message: req.message });
    const systemPrompt = this.contextSvc.build(ctx);
    const history = await this.sessionSvc.getHistory(req.sessionId);
    const messages: ChatMessage[] = [...history, { role: 'user', content: req.message }];

    // Loop agêntico — Claude chama tools até ter resposta final
    let res = await adapter.complete({ systemPrompt, messages, tools: TOOLS, maxTokens });

    if (res.cacheReadTokens !== undefined || res.cacheCreationTokens !== undefined) {
      req.logger?.info(
        { cacheRead: res.cacheReadTokens ?? 0, cacheCreation: res.cacheCreationTokens ?? 0 },
        'claude:prompt_cache',
      );
    }

    while (res.stop_reason === 'tool_use' && res.tool_calls?.length) {
      const results = await Promise.all(res.tool_calls.map((tc) => this.citationSvc.handle(tc)));

      const toolResultBlocks: ToolResultBlock[] = results.map((r) => ({
        type: 'tool_result',
        tool_use_id: r.tool_use_id,
        content: r.content,
      }));

      messages.push({ role: 'assistant', content: res.content, tool_calls: res.tool_calls });
      messages.push({ role: 'user', content: toolResultBlocks });

      res = await adapter.complete({ systemPrompt, messages, tools: TOOLS, maxTokens });
    }

    // Persiste histórico (últimas 8 mensagens)
    const newMessages: ChatMessage[] = [
      { role: 'user', content: req.message },
      { role: 'assistant', content: res.content },
    ];
    await this.sessionSvc.append(req.sessionId, newMessages);

    const parsed = this.citationSvc.parse(res.content, req.mode);

    // PRO: auto-save como anotação quando confidence === "high"
    let autoSavedAnnotationId: string | undefined;
    if (req.isPro && parsed.confidence === 'high') {
      const annotation = await db.annotation.create({
        data: {
          userId: req.userId,
          title: parsed.message.substring(0, 60),
          content: parsed.message,
          subject: req.context?.question_bundle?.subject ?? req.context?.topic_title ?? undefined,
        },
      });
      autoSavedAnnotationId = annotation.id;
    }

    return { ...parsed, autoSavedAnnotationId };
  }
}
