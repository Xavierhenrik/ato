import Anthropic from '@anthropic-ai/sdk';
import { LLMAdapter, LLMRequest, LLMResponse, ChatMessage } from './llm.interface';

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

export class ClaudeAdapter implements LLMAdapter {
  /**
   * Translates shared ChatMessage[] to Anthropic MessageParam[].
   * Assistant messages that carried tool_calls must be rebuilt with tool_use content blocks
   * so Anthropic accepts the following tool_result user turn.
   */
  private mapToAnthropic(messages: ChatMessage[]): Anthropic.MessageParam[] {
    return messages.map((msg) => {
      if (msg.role === 'assistant' && msg.tool_calls?.length) {
        const content: Anthropic.ContentBlockParam[] = [];
        if (msg.content) {
          content.push({ type: 'text', text: msg.content as string });
        }
        for (const tc of msg.tool_calls) {
          content.push({ type: 'tool_use', id: tc.id, name: tc.name, input: tc.input });
        }
        return { role: 'assistant', content };
      }
      return msg as unknown as Anthropic.MessageParam;
    });
  }

  async complete(req: LLMRequest): Promise<LLMResponse> {
    const response = await client.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: req.maxTokens ?? 1024,
      temperature: req.temperature ?? 0.2,
      system: [
        {
          type: 'text' as const,
          text: req.systemPrompt,
          cache_control: { type: 'ephemeral' as const },
        },
      ] as Anthropic.TextBlockParam[],
      messages: this.mapToAnthropic(req.messages as ChatMessage[]),
      tools: req.tools
        ? (req.tools.map((t, i, arr) => ({
            ...t,
            ...(i === arr.length - 1 ? { cache_control: { type: 'ephemeral' as const } } : {}),
          })) as Anthropic.Tool[])
        : undefined,
      tool_choice: req.tools?.length ? { type: 'auto' } : undefined,
    });

    const textBlock = response.content.find((b) => b.type === 'text') as
      | Anthropic.TextBlock
      | undefined;

    const toolCalls = response.content
      .filter((b): b is Anthropic.ToolUseBlock => b.type === 'tool_use')
      .map((b) => ({ id: b.id, name: b.name, input: b.input as Record<string, unknown> }));

    return {
      content: textBlock?.text ?? '',
      stop_reason: response.stop_reason === 'tool_use' ? 'tool_use' : 'end_turn',
      tool_calls: toolCalls.length ? toolCalls : undefined,
      inputTokens: response.usage.input_tokens,
      outputTokens: response.usage.output_tokens,
      cacheReadTokens: response.usage.cache_read_input_tokens ?? undefined,
      cacheCreationTokens: response.usage.cache_creation_input_tokens ?? undefined,
    };
  }
}
