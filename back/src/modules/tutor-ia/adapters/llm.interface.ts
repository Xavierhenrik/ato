export interface ChatMessage {
  role: 'user' | 'assistant';
  content: string | ToolResultBlock[];
}

export interface ToolResultBlock {
  type: 'tool_result';
  tool_use_id: string;
  content: string;
}

export interface Tool {
  name: string;
  description: string;
  input_schema: Record<string, unknown>;
}

export interface ToolCall {
  id: string;
  name: string;
  input: Record<string, unknown>;
}

export interface LLMRequest {
  systemPrompt: string;
  messages: ChatMessage[];
  tools?: Tool[];
  maxTokens?: number;
  temperature?: number;
}

export interface LLMResponse {
  content: string;
  stop_reason: 'end_turn' | 'tool_use';
  tool_calls?: ToolCall[];
  inputTokens: number;
  outputTokens: number;
}

export interface LLMAdapter {
  complete(req: LLMRequest): Promise<LLMResponse>;
}
