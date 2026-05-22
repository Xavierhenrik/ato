import { db } from '../../../shared/db';
import { Prisma } from '@prisma/client';
import { Tool, ToolCall } from '../adapters/llm.interface';

export const SEARCH_LEGISLATION_TOOL: Tool = {
  name: 'search_legislation',
  description:
    'Busca artigos relevantes sobre um tema na legislação brasileira. ' +
    'Use para encontrar dispositivos relacionados à pergunta.',
  input_schema: {
    type: 'object',
    properties: {
      query: { type: 'string', description: 'Termos de busca em português' },
      law_code: { type: 'string', nullable: true, description: 'Filtrar por diploma, ex: "CC"' },
      limit: { type: 'number', default: 5, description: 'Máximo de resultados (padrão 5)' },
    },
    required: ['query'],
  },
};

export async function handleSearchLegislation(tc: ToolCall): Promise<string> {
  const { query, law_code, limit = 5 } = tc.input as {
    query: string;
    law_code?: string;
    limit?: number;
  };

  const rows = await db.$queryRaw<
    Array<{ full_reference: string; content: string; law_name: string; score: number }>
  >(
    Prisma.sql`
      SELECT full_reference, content, law_name,
             ts_rank(content_tsv, plainto_tsquery('portuguese_unaccent', ${query})) AS score
      FROM legal_articles
      WHERE content_tsv @@ plainto_tsquery('portuguese_unaccent', ${query})
      ${law_code ? Prisma.sql`AND law_code = ${law_code}` : Prisma.empty}
      ORDER BY score DESC
      LIMIT ${limit}
    `,
  );

  return JSON.stringify(rows);
}
