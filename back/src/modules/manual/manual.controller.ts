import { FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import { ManualService } from './manual.service';

export class ManualController {
  private svc = new ManualService();

  async listTopics(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const query = z.object({ lawCode: z.string().optional() }).parse(req.query);
    return reply.send(await this.svc.listTopics(user.id, query.lawCode));
  }

  async getTopic(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const { id } = z.object({ id: z.string() }).parse(req.params);
    return reply.send(await this.svc.getTopic(id, user.id));
  }

  async markAsRead(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const { id } = z.object({ id: z.string() }).parse(req.params);
    return reply.send(await this.svc.markAsRead(user.id, id));
  }

  async search(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const query = z.object({ q: z.string().min(2), lawCode: z.string().optional() }).parse(req.query);
    return reply.send(await this.svc.search(user.id, query.q, query.lawCode));
  }

  async getArticle(req: FastifyRequest, reply: FastifyReply) {
    const query = z
      .object({
        lawCode: z.string(),
        article: z.string(),
        paragraph: z.string().optional(),
        inciso: z.string().optional(),
      })
      .parse(req.query);

    return reply.send(await this.svc.getArticle(query));
  }
}
