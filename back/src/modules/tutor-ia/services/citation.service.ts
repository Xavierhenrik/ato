import { ToolCall } from '../adapters/llm.interface';
import { handleLookupArticle } from '../tools/lookup-article.tool';
import { handleSearchLegislation } from '../tools/search-legislation.tool';
import { Citation, TutorResponse } from '../schemas/tutor-response.schema';
import { TutorMode } from '../adapters/llm.router';

// Sources accumulated during the agentic loop. We keep the tool result text
// (which the tool itself returns as JSON) plus the requested reference so we
// can rebuild a Citation[] without asking the LLM to repeat the data.
export interface ToolCallTrace {
  name: string;
  input: Record<string, unknown>;
  resultText: string;
}

interface LookupArticleResult {
  found?: boolean;
  full_reference?: string;
  content?: string;
  law_name?: string;
  manual_topic_id?: string;
}

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

  /**
   * Builds the final TutorResponse from the LLM's free-form Markdown answer
   * and the tool calls that happened during the agentic loop.
   *
   * Why no JSON parsing: the previous schema-driven approach was unreliable
   * (sabia-4 cannot follow strict JSON contracts), and a failed parse silently
   * dumped raw output to the user. We now:
   *   - take the raw text as message (cleaned of obvious metadata footers),
   *   - build sources[] from real lookup_article calls,
   *   - infer confidence heuristically from how many citations verified.
   */
  parse(
    rawContent: string,
    mode: TutorMode,
    toolTrace: ToolCallTrace[] = [],
  ): TutorResponse {
    const message = this.cleanMessage(rawContent);
    const sources = this.buildSources(toolTrace);
    const confidence = this.inferConfidence(sources, message);

    return { message, sources, confidence, mode };
  }

  /**
   * Strips trailing "**Fontes:**" / "**Confiança:**" / "**Modo:**" footers
   * that older prompts taught the model to write. Keeps the rest intact.
   */
  private cleanMessage(raw: string): string {
    let text = raw.trim();

    // Drop everything from the first occurrence of a known metadata header.
    const metadataHeaders = [
      /\n+\s*-{3,}\s*\n+\*\*Fontes?\*\*:?/i,
      /\n+\*\*Fontes?\*\*:?\s*\n/i,
      /\n+\*\*Confian[çc]a\*\*:?\s*\n/i,
      /\n+\*\*Modo\*\*:?\s*\n/i,
      // Stray JSON tail like '\n{ "message": ...'
      /\n+\{\s*"?message"?\s*:/i,
    ];
    for (const re of metadataHeaders) {
      const m = text.match(re);
      if (m && m.index !== undefined) {
        text = text.slice(0, m.index).trimEnd();
      }
    }

    // If, despite all of the above, the model returned a JSON envelope, try to
    // unwrap just the "message" field — last-resort recovery.
    const envelope = text.match(
      /^\s*\{\s*"message"\s*:\s*"([\s\S]*?)"\s*(,|\})/,
    );
    if (envelope) {
      try {
        // Unescape JSON string content
        text = JSON.parse(`"${envelope[1]}"`) as string;
      } catch {
        // keep original on failure
      }
    }

    return text.trim();
  }

  /**
   * Builds Citation[] from lookup_article tool calls. Deduplicates by
   * full_reference. search_legislation results are not surfaced as
   * citations (they're broader, used for orientation only).
   */
  private buildSources(toolTrace: ToolCallTrace[]): Citation[] {
    const seen = new Set<string>();
    const sources: Citation[] = [];

    for (const t of toolTrace) {
      if (t.name !== 'lookup_article') continue;
      let parsed: LookupArticleResult;
      try {
        parsed = JSON.parse(t.resultText) as LookupArticleResult;
      } catch {
        continue;
      }

      const ref = parsed.full_reference ?? this.inputToReference(t.input);
      if (!ref || seen.has(ref)) continue;
      seen.add(ref);

      sources.push({
        full_reference: ref,
        content: parsed.content ?? '',
        law_name: parsed.law_name ?? this.inputLawName(t.input),
        certainty: parsed.found === true ? 'verified' : 'not_found',
        ...(parsed.manual_topic_id ? { manual_topic_id: parsed.manual_topic_id } : {}),
      });
    }

    return sources;
  }

  private inputToReference(input: Record<string, unknown>): string {
    const article = (input.article as string | undefined) ?? '';
    const lawCode = (input.law_code as string | undefined) ?? '';
    if (!article && !lawCode) return '';
    return `Art. ${article} ${lawCode ? `do ${lawCode}` : ''}`.trim();
  }

  private inputLawName(input: Record<string, unknown>): string {
    return (input.law_code as string | undefined) ?? '';
  }

  /**
   * Heuristic:
   *   - At least one verified citation     → high
   *   - No tool calls or all not_found     → low
   *   - Mixed / model expressed uncertainty → medium
   */
  private inferConfidence(
    sources: Citation[],
    message: string,
  ): 'high' | 'medium' | 'low' {
    const uncertaintySignals =
      /\b(n[ãa]o tenho certeza|n[ãa]o consegui verificar|controvers[ao]|majorit[áa]ria entende)\b/i;

    if (uncertaintySignals.test(message)) return 'low';
    if (sources.length === 0) return 'medium';

    const verifiedCount = sources.filter((s) => s.certainty === 'verified').length;
    if (verifiedCount === 0) return 'low';
    if (verifiedCount === sources.length) return 'high';
    return 'medium';
  }
}
