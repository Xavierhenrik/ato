import { db } from '../../../shared/db';
import { Prisma } from '@prisma/client';
import { Tool, ToolCall } from '../adapters/llm.interface';

export const LOOKUP_ARTICLE_TOOL: Tool = {
  name: 'lookup_article',
  description:
    'Busca o texto exato de um artigo da legislação brasileira. ' +
    'Use SEMPRE que precisar citar um artigo específico. ' +
    'Se não encontrar, informe que não pode verificar.',
  input_schema: {
    type: 'object',
    properties: {
      law_code: { type: 'string', description: 'Código do diploma: CC, CF, CP, CLT, CPC, CPP, CTN, CDC, EOAB' },
      article: { type: 'string', description: 'Número do artigo, ex: "186", "5"' },
      paragraph: { type: 'string', nullable: true, description: 'Parágrafo, ex: "1", "unico"' },
      inciso: { type: 'string', nullable: true, description: 'Inciso em romano, ex: "I", "II"' },
    },
    required: ['law_code', 'article'],
  },
};

export async function handleLookupArticle(tc: ToolCall): Promise<string> {
  const { law_code, article, paragraph, inciso } = tc.input as {
    law_code: string;
    article: string;
    paragraph?: string;
    inciso?: string;
  };

  const rows = await db.$queryRaw<
    Array<{ full_reference: string; content: string; law_name: string; status: string }>
  >(
    Prisma.sql`
      SELECT full_reference, content, law_name, status
      FROM legal_articles
      WHERE law_code = ${law_code}
        AND article_number = ${article}
        AND COALESCE(paragraph, '') = COALESCE(${paragraph ?? null}, '')
        AND COALESCE(inciso, '') = COALESCE(${inciso ?? null}, '')
      LIMIT 1
    `,
  );

  if (!rows.length) {
    return JSON.stringify({
      found: false,
      message: 'ARTIGO NÃO ENCONTRADO. Não cite este artigo.',
    });
  }

  return JSON.stringify({ found: true, ...rows[0] });
}
