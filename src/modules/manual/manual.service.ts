import { db } from '../../shared/db';
import { Prisma } from '@prisma/client';
import { Errors } from '../../shared/errors';

export class ManualService {
  async listTopics(lawCode?: string) {
    return db.topic.findMany({
      where: lawCode ? { lawCode } : undefined,
      select: { id: true, code: true, title: true, lawCode: true, chapter: true, order: true, isPro: true },
      orderBy: [{ lawCode: 'asc' }, { order: 'asc' }],
    });
  }

  async getTopic(id: string) {
    const topic = await db.topic.findUnique({ where: { id } });
    if (!topic) throw Errors.notFound('Tópico');
    return topic;
  }

  async search(q: string, lawCode?: string) {
    // Delega para a tabela legal_articles via raw SQL (BM25 com portuguese_unaccent)
    const rows = await db.$queryRaw<
      Array<{ law_code: string; article_number: string; full_reference: string; content: string; score: number }>
    >(
      Prisma.sql`
        SELECT law_code, article_number, full_reference, content,
               ts_rank(content_tsv, plainto_tsquery('portuguese_unaccent', ${q})) AS score
        FROM legal_articles
        WHERE content_tsv @@ plainto_tsquery('portuguese_unaccent', ${q})
        ${lawCode ? Prisma.sql`AND law_code = ${lawCode}` : Prisma.empty}
        ORDER BY score DESC
        LIMIT 10
      `,
    );

    return rows;
  }

  async getArticle(params: {
    lawCode: string;
    article: string;
    paragraph?: string;
    inciso?: string;
  }) {
    const rows = await db.$queryRaw<
      Array<{ full_reference: string; content: string; law_name: string; status: string }>
    >(
      Prisma.sql`
        SELECT full_reference, content, law_name, status
        FROM legal_articles
        WHERE law_code = ${params.lawCode}
          AND article_number = ${params.article}
          AND COALESCE(paragraph, '') = COALESCE(${params.paragraph ?? null}, '')
          AND COALESCE(inciso, '') = COALESCE(${params.inciso ?? null}, '')
        LIMIT 1
      `,
    );

    if (!rows.length) return null;
    return rows[0];
  }
}
