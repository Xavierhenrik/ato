import { FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import { HistoryService, HistoryListQuerySchema } from '../services/history.service';

export class HistoryController {
  private historySvc = new HistoryService();

  async list(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const query = HistoryListQuerySchema.parse(req.query);

    const result = await this.historySvc.list(user.id, query);

    return reply.send(result);
  }

  async getById(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);

    const result = await this.historySvc.getById(user.id, id);

    return reply.send(result);
  }

  async deleteById(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);

    await this.historySvc.deleteById(user.id, id);

    return reply.code(204).send();
  }
}
