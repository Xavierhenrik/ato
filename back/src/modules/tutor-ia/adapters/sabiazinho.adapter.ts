// Maritaca AI — Sabiázinho-4 (modelo compacto, ~5× mais barato que Sabiá-4)
// Usado para queries direct simples que não requerem raciocínio profundo.
// API idêntica ao SabiaAdapter — apenas o model slug difere.
import { LLMAdapter, LLMRequest, LLMResponse, ToolCall, ChatMessage, ToolResultBlock } from './llm.interface';
import { Errors } from '../../../shared/errors';

interface MaritacaMessage {
  role: string;
  content: string | null;
  tool_calls?: Array<{ id: string; type: 'function'; function: { name: string; arguments: string } }>;
  tool_call_id?: string;
}

interface MaritacaChoice {
  message: {
    content: string | null;
    tool_calls?: Array<{
      id: string;
      function: { name: string; arguments: string };
    }>;
  };
  finish_reason: string;
}

interface MaritacaResponse {
  choices: MaritacaChoice[];
  usage: { prompt_tokens: number; completion_tokens: number };
}

const TIMEOUT_MS = 30_000;
const RETRYABLE_STATUS = new Set([500, 503]);

export class SabiazinhoAdapter implements LLMAdapter {
  private baseUrl = process.env.MARITACA_BASE_URL ?? 'https://chat.maritaca.ai/api';
  private apiKey = process.env.MARITACA_API_KEY!;

  async complete(req: LLMRequest): Promise<LLMResponse> {
    const body: Record<string, unknown> = {
      model: 'sabiazinho-4',
      max_tokens: req.maxTokens ?? 1024,
      temperature: req.temperature ?? 0.2,
      messages: this.mapToOpenAI(req),
    };

    if (req.tools?.length) {
      body.tools = req.tools.map((t) => ({
        type: 'function',
        function: { name: t.name, description: t.description, parameters: t.input_schema },
      }));
      body.tool_choice = 'auto';
    }

    return this.fetchWithRetry(body);
  }

  private mapToOpenAI(req: LLMRequest): MaritacaMessage[] {
    const result: MaritacaMessage[] = [{ role: 'system', content: req.systemPrompt }];

    for (const msg of req.messages as ChatMessage[]) {
      if (msg.role === 'assistant' && msg.tool_calls?.length) {
        result.push({
          role: 'assistant',
          content: (msg.content as string) || null,
          tool_calls: msg.tool_calls.map((tc: ToolCall) => ({
            id: tc.id,
            type: 'function',
            function: {
              name: tc.name,
              arguments: JSON.stringify(tc.input),
            },
          })),
        });
        continue;
      }

      if (msg.role === 'user' && Array.isArray(msg.content)) {
        for (const block of msg.content as ToolResultBlock[]) {
          if (block.type === 'tool_result') {
            result.push({
              role: 'tool',
              content: block.content,
              tool_call_id: block.tool_use_id,
            });
          }
        }
        continue;
      }

      result.push({ role: msg.role, content: msg.content as string });
    }

    return result;
  }

  private async fetchWithRetry(
    body: Record<string, unknown>,
    attempt = 1,
  ): Promise<LLMResponse> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), TIMEOUT_MS);

    let res: Response;
    try {
      res = await fetch(`${this.baseUrl}/chat/completions`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        signal: controller.signal,
      });
    } catch (err) {
      clearTimeout(timeout);
      console.error('[SabiazinhoAdapter] fetch error:', err);
      throw err;
    } finally {
      clearTimeout(timeout);
    }

    if (!res.ok) {
      if (attempt === 1 && RETRYABLE_STATUS.has(res.status)) {
        console.warn(`[SabiazinhoAdapter] status ${res.status} — retrying (attempt 2/2)`);
        return this.fetchWithRetry(body, 2);
      }
      const errText = await res.text();
      console.error(`[SabiazinhoAdapter] API error ${res.status}:`, errText);
      throw Errors.upstream(`Maritaca API error ${res.status}: ${errText}`);
    }

    const data = (await res.json()) as MaritacaResponse;
    const choice = data.choices[0];
    const msg = choice.message;

    const toolCalls: ToolCall[] = (msg.tool_calls ?? []).map((tc) => ({
      id: tc.id,
      name: tc.function.name,
      input: JSON.parse(tc.function.arguments) as Record<string, unknown>,
    }));

    return {
      content: msg.content ?? '',
      stop_reason: choice.finish_reason === 'tool_calls' ? 'tool_use' : 'end_turn',
      tool_calls: toolCalls.length ? toolCalls : undefined,
      inputTokens: data.usage.prompt_tokens,
      outputTokens: data.usage.completion_tokens,
    };
  }
}
