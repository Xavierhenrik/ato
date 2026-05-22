import { ToolCall } from '../adapters/llm.interface';
import { handleLookupArticle } from '../tools/lookup-article.tool';
import { handleSearchLegislation } from '../tools/search-legislation.tool';
import { TutorResponse, TutorResponseSchema } from '../schemas/tutor-response.schema';
import { TutorMode } from '../adapters/llm.router';

export class CitationService {
  async handle(tc: ToolCall): Promise<{ tool_use_id: string; content: string }> {
    let content: string;

    if (tc.name === 'lookup_article') {
      content = await handleLookupArticle(tc);
    } else if (tc.name === 'search_legislation') {
      content = await handleSearchLegislation(tc);
    } else {
      content = JSON.stringify({ error: `Tool desconhecida: ${tc.name}` });
    }

    return { tool_use_id: tc.id, content };
  }

  parse(rawContent: string, mode: TutorMode): TutorResponse {
    try {
      const jsonMatch = rawContent.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]) as unknown;
        return TutorResponseSchema.parse({ ...parsed as object, mode });
      }
    } catch {
      // Fallback para resposta não-estruturada
    }

    return {
      message: rawContent,
      sources: [],
      confidence: 'medium',
      mode,
    };
  }
}
