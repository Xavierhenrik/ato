// Maritaca AI — Sabiá-4
// API compatível com OpenAI: usa parâmetros tools e tool_choice nativamente.
import { LLMAdapter, LLMRequest, LLMResponse, ToolCall } from './llm.interface';

interface MaritacaMessage {
  role: string;
  content: string | unknown[];
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

export class SabiaAdapter implements LLMAdapter {
  private baseUrl = process.env.MARITACA_BASE_URL ?? 'https://chat.maritaca.ai/api';
  private apiKey = process.env.MARITACA_API_KEY!;

  async complete(req: LLMRequest): Promise<LLMResponse> {
    const body: Record<string, unknown> = {
      model: 'sabia-4',
      max_tokens: req.maxTokens ?? 1024,
      temperature: req.temperature ?? 0.2,
      messages: [
        { role: 'system', content: req.systemPrompt },
        ...(req.messages as MaritacaMessage[]),
      ],
    };

    if (req.tools?.length) {
      body.tools = req.tools.map((t) => ({
        type: 'function',
        function: { name: t.name, description: t.description, parameters: t.input_schema },
      }));
      body.tool_choice = 'auto';
    }

    const res = await fetch(`${this.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    if (!res.ok) {
      const err = await res.text();
      throw new Error(`Maritaca API error ${res.status}: ${err}`);
    }

    const data: MaritacaResponse = await res.json();
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
