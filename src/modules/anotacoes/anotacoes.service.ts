import { db } from '../../shared/db';
import { Errors } from '../../shared/errors';

export class AnotacoesService {
  async list(userId: string, topicId?: string) {
    return db.annotation.findMany({
      where: { userId, ...(topicId && { topicId }) },
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
    },
  ) {
    return db.annotation.create({ data: { userId, ...data } });
  }

  async update(userId: string, id: string, content: string) {
    const note = await db.annotation.findFirst({ where: { id, userId } });
    if (!note) throw Errors.notFound('Anotação');
    return db.annotation.update({ where: { id }, data: { content } });
  }

  async remove(userId: string, id: string) {
    const note = await db.annotation.findFirst({ where: { id, userId } });
    if (!note) throw Errors.notFound('Anotação');
    await db.annotation.delete({ where: { id } });
  }
}
