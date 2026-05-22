import Anthropic from '@anthropic-ai/sdk';
import { LLMAdapter, LLMRequest, LLMResponse } from './llm.interface';

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

export class ClaudeAdapter implements LLMAdapter {
  async complete(req: LLMRequest): Promise<LLMResponse> {
    const response = await client.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: req.maxTokens ?? 1024,
      temperature: req.temperature ?? 0.2,
      system: req.systemPrompt,
      messages: req.messages as Anthropic.MessageParam[],
      tools: req.tools as Anthropic.Tool[],
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
    };
  }
}
