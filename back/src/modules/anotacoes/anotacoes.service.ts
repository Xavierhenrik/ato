import { db } from '../../shared/db';
import { Prisma } from '@prisma/client';
import { Errors } from '../../shared/errors';
import { randomUUID } from 'crypto';

export class AnotacoesService {
  async list(
    userId: string,
    filters: { topicId?: string; subject?: string; tag?: string; q?: string },
  ) {
    const { topicId, subject, tag, q } = filters;

    // Filtro por tag requer raw query (JSON array contains)
    if (tag) {
      const tagJson = JSON.stringify([tag]);
      const rows = await db.$queryRaw<Array<Record<string, unknown>>>(
        Prisma.sql`
          SELECT id, user_id, topic_id, law_code, article_ref,
                 title, content, highlight, tags, subject,
                 created_at, updated_at
          FROM annotations
          WHERE user_id = ${userId}
            ${subject ? Prisma.sql`AND subject = ${subject}` : Prisma.empty}
            AND tags @> ${tagJson}::jsonb
            ${q ? Prisma.sql`AND (title ILIKE ${'%' + q + '%'} OR content ILIKE ${'%' + q + '%'})` : Prisma.empty}
          ORDER BY updated_at DESC
        `,
      );
      return rows;
    }

    const where: Prisma.AnnotationWhereInput = {
      userId,
      ...(topicId && { topicId }),
      ...(subject && { subject }),
      ...(q && {
        OR: [
          { title: { contains: q, mode: 'insensitive' } },
          { content: { contains: q, mode: 'insensitive' } },
        ],
      }),
    };

    return db.annotation.findMany({
      where,
      orderBy: { updatedAt: 'desc' },
    });
  }

  async create(
    userId: string,
    data: {
      topicId?: string;
      lawCode?: string;
      articleRef?: string;
      content: string;
      highlight?: string;
      title?: string;
      tags?: string[];
      subject?: string;
    },
  ) {
    return db.annotation.create({
      data: {
        id: randomUUID(),
        userId,
        ...data,
        tags: data.tags ?? undefined,
      },
    });
  }

  async update(
    userId: string,
    id: string,
    data: {
      content?: string;
      title?: string;
      tags?: string[];
      subject?: string;
      lawCode?: string;
      articleRef?: string;
    },
  ) {
    const note = await db.annotation.findFirst({ where: { id, userId } });
    if (!note) throw Errors.notFound('Anotação');

    return db.annotation.update({
      where: { id },
      data: {
        ...data,
        tags: data.tags ?? undefined,
      },
    });
  }

  async remove(userId: string, id: string) {
    const note = await db.annotation.findFirst({ where: { id, userId } });
    if (!note) throw Errors.notFound('Anotação');
    await db.annotation.delete({ where: { id } });
  }
}
