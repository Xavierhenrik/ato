import { z } from 'zod';
import { Prisma } from '@prisma/client';
import { db } from '../../../shared/db';
import { Errors } from '../../../shared/errors';
import { getIsPro } from './plan.service';

export const HistoryListQuerySchema = z.object({
  mode: z.enum(['direct', 'reading']),
  cursor: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

export type HistoryListQuery = z.infer<typeof HistoryListQuerySchema>;

interface HistorySessionItem {
  id: string;
  mode: string;
  title: string | null;
  topicId: string | null;
  topicTitle: string | null;
  createdAt: Date;
  msgCount: number;
}

interface HistoryListResult {
  sessions: HistorySessionItem[];
  nextCursor: string | null;
  retention: '7d' | 'all';
}

interface HistoryMessageItem {
  id: string;
  role: string;
  content: string;
  sources: Prisma.JsonValue;
  createdAt: Date;
}

interface HistoryDetailResult {
  session: HistorySessionItem;
  messages: HistoryMessageItem[];
}

function subDays(date: Date, days: number): Date {
  const result = new Date(date);
  result.setDate(result.getDate() - days);
  return result;
}

export class HistoryService {
  async list(userId: string, query: HistoryListQuery): Promise<HistoryListResult> {
    const isPro = await getIsPro(userId);
    const retention: '7d' | 'all' = isPro ? 'all' : '7d';

    let cursorCreatedAt: Date | undefined;
    if (query.cursor) {
      const cursorSession = await db.tutorSession.findFirst({
        where: { id: query.cursor, userId },
        select: { createdAt: true },
      });
      if (!cursorSession) {
        throw Errors.validation('Cursor inválido');
      }
      cursorCreatedAt = cursorSession.createdAt;
    }

    const createdAtFilter: Prisma.DateTimeFilter = {
      ...(isPro ? {} : { gte: subDays(new Date(), 7) }),
      ...(cursorCreatedAt ? { lt: cursorCreatedAt } : {}),
    };

    const hasCreatedAtFilter = !isPro || cursorCreatedAt !== undefined;

    const where: Prisma.TutorSessionWhereInput = {
      userId,
      mode: query.mode,
      msgCount: { gt: 0 },
      ...(hasCreatedAtFilter ? { createdAt: createdAtFilter } : {}),
    };

    const sessions = await db.tutorSession.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: query.limit,
      select: {
        id: true,
        mode: true,
        title: true,
        topicId: true,
        createdAt: true,
        msgCount: true,
      },
    });

    // Batch lookup for topic titles
    const topicIds = [...new Set(
      sessions.map((s) => s.topicId).filter((id): id is string => id !== null),
    )];
    const topicMap = new Map<string, string>();
    if (topicIds.length > 0) {
      const topics = await db.topic.findMany({
        where: { id: { in: topicIds } },
        select: { id: true, title: true },
      });
      for (const t of topics) {
        topicMap.set(t.id, t.title);
      }
    }

    const items: HistorySessionItem[] = sessions.map((s) => ({
      id: s.id,
      mode: s.mode,
      title: s.title,
      topicId: s.topicId,
      topicTitle: s.topicId ? (topicMap.get(s.topicId) ?? null) : null,
      createdAt: s.createdAt,
      msgCount: s.msgCount,
    }));

    const nextCursor =
      sessions.length === query.limit ? (sessions[sessions.length - 1]?.id ?? null) : null;

    return { sessions: items, nextCursor, retention };
  }

  async getById(userId: string, sessionId: string): Promise<HistoryDetailResult> {
    const isPro = await getIsPro(userId);

    const session = await db.tutorSession.findFirst({
      where: { id: sessionId, userId },
      select: {
        id: true,
        mode: true,
        title: true,
        topicId: true,
        createdAt: true,
        msgCount: true,
      },
    });

    if (!session) {
      throw Errors.notFound('Sessão');
    }

    // Gate Free: sessão com createdAt > 7 dias => 404
    if (!isPro) {
      const cutoff = subDays(new Date(), 7);
      if (session.createdAt < cutoff) {
        throw Errors.notFound('Sessão');
      }
    }

    // Batch lookup for topic title
    let topicTitle: string | null = null;
    if (session.topicId) {
      const topic = await db.topic.findUnique({
        where: { id: session.topicId },
        select: { title: true },
      });
      topicTitle = topic?.title ?? null;
    }

    const messages = await db.tutorMessage.findMany({
      where: { sessionId },
      orderBy: { createdAt: 'asc' },
      select: {
        id: true,
        role: true,
        content: true,
        sources: true,
        createdAt: true,
      },
    });

    const sessionItem: HistorySessionItem = {
      id: session.id,
      mode: session.mode,
      title: session.title,
      topicId: session.topicId,
      topicTitle,
      createdAt: session.createdAt,
      msgCount: session.msgCount,
    };

    return { session: sessionItem, messages };
  }

  async deleteById(userId: string, sessionId: string): Promise<void> {
    const session = await db.tutorSession.findFirst({
      where: { id: sessionId, userId },
      select: { id: true },
    });

    if (!session) {
      throw Errors.notFound('Sessão');
    }

    await db.tutorSession.delete({ where: { id: sessionId } });
  }
}
