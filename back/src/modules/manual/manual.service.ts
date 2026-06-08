import { db } from '../../shared/db';
import { Prisma } from '@prisma/client';
import { Errors } from '../../shared/errors';
import { randomUUID } from 'crypto';

interface TopicSection {
  order: number;
  title: string;
  content: string;
}

const CANONICAL_TITLES: Record<string, string> = {
  'fundamento': 'fundamento',
  'artigos centrais': 'artigos_centrais',
  'exemplo prático': 'exemplo_pratico',
  'exemplo pratico': 'exemplo_pratico',
  'atenção': 'atencao',
  'atencao': 'atencao',
  'como cai na oab': 'oab',
  'resumo': 'resumo',
};

function normalizeTitle(raw: string): string {
  const lower = raw.toLowerCase().trim();
  return CANONICAL_TITLES[lower] ?? raw.trim();
}

function countWords(text: string): number {
  return text.trim().split(/\s+/).filter(w => w.length > 0).length;
}

function parseMarkdownSections(content: string): TopicSection[] {
  const blocks = content.split(/^## /m);
  const sections: TopicSection[] = [];
  let order = 0;

  for (const block of blocks) {
    const trimmed = block.trim();
    if (!trimmed) continue;

    const newlineIndex = trimmed.indexOf('\n');
    const rawTitle = newlineIndex === -1 ? trimmed : trimmed.slice(0, newlineIndex);
    const body = newlineIndex === -1 ? '' : trimmed.slice(newlineIndex + 1).trim();

    if (!rawTitle.trim()) continue;

    sections.push({ order: order++, title: normalizeTitle(rawTitle), content: body });
  }

  return sections;
}

export class ManualService {
  async listTopics(userId: string, lawCode?: string) {
    const topics = await db.topic.findMany({
      where: lawCode ? { lawCode } : undefined,
      select: {
        id: true,
        code: true,
        title: true,
        lawCode: true,
        chapter: true,
        order: true,
        isPro: true,
        updatedAt: true,
        content: true,
      },
      orderBy: [{ lawCode: 'asc' }, { order: 'asc' }],
    });

    if (!topics.length) return [];

    const readCounts = await db.topicRead.groupBy({
      by: ['topicId'],
      where: { userId },
      _count: { topicId: true },
    });
    const readTopicIds = new Set(readCounts.map(r => r.topicId));

    // Conta total por lawCode
    const totalByCode = new Map<string, number>();
    const readByCode = new Map<string, number>();

    for (const topic of topics) {
      totalByCode.set(topic.lawCode, (totalByCode.get(topic.lawCode) ?? 0) + 1);
      if (readTopicIds.has(topic.id)) {
        readByCode.set(topic.lawCode, (readByCode.get(topic.lawCode) ?? 0) + 1);
      }
    }

    return topics.map(({ content, ...t }) => ({
      ...t,
      readTimeMinutes: Math.max(1, Math.round(countWords(content) / 200)),
      progress: {
        readCount: readByCode.get(t.lawCode) ?? 0,
        totalTopics: totalByCode.get(t.lawCode) ?? 0,
      },
    }));
  }

  async getTopic(id: string, userId: string) {
    const topic = await db.topic.findUnique({ where: { id } });
    if (!topic) throw Errors.notFound('Tópico');

    const read = await db.topicRead.findUnique({
      where: { userId_topicId: { userId, topicId: id } },
    });

    const readTimeMinutes = Math.max(1, Math.round(countWords(topic.content) / 200));
    const sections = parseMarkdownSections(topic.content);

    return {
      id: topic.id,
      title: topic.title,
      lawCode: topic.lawCode,
      isRead: !!read,
      updatedAt: topic.updatedAt,
      readTimeMinutes,
      sections,
    };
  }

  async markAsRead(userId: string, topicId: string) {
    const topic = await db.topic.findUnique({ where: { id: topicId }, select: { id: true } });
    if (!topic) throw Errors.notFound('Tópico');

    const existing = await db.topicRead.findUnique({
      where: { userId_topicId: { userId, topicId } },
    });

    if (existing) {
      return { topicId, readAt: existing.readAt.toISOString(), isNew: false };
    }

    const record = await db.topicRead.create({
      data: { id: randomUUID(), userId, topicId },
    });

    return { topicId, readAt: record.readAt.toISOString(), isNew: true };
  }

  async search(_userId: string, q: string, lawCode?: string) {
    // Busca em topics (ILIKE em title e content) — máximo 5
    const topicResults = await db.topic.findMany({
      where: {
        AND: [
          lawCode ? { lawCode } : {},
          {
            OR: [
              { title: { contains: q, mode: 'insensitive' } },
              { content: { contains: q, mode: 'insensitive' } },
            ],
          },
        ],
      },
      select: { id: true, title: true, lawCode: true, content: true },
      take: 5,
    });

    // Busca em legal_articles via BM25 — máximo 10
    const articleResults = await db.$queryRaw<
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

    const results = [
      ...topicResults.map(t => ({
        source: 'topic' as const,
        id: t.id,
        title: t.title,
        lawCode: t.lawCode,
        snippet: t.content.substring(0, 200),
      })),
      ...articleResults.map(a => ({
        source: 'article' as const,
        lawCode: a.law_code,
        articleNumber: a.article_number,
        fullReference: a.full_reference,
        content: a.content,
        score: Number(a.score),
      })),
    ];

    return { results };
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
