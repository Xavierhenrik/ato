import { FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import { AnotacoesService } from './anotacoes.service';

const CreateSchema = z.object({
  topicId:    z.string().optional(),
  lawCode:    z.string().optional(),
  articleRef: z.string().optional(),
  content:    z.string().min(1),
  highlight:  z.string().optional(),
  title:      z.string().optional(),
  tags:       z.array(z.string()).optional(),
  subject:    z.string().optional(),
});

const UpdateSchema = z.object({
  content:    z.string().min(1).optional(),
  title:      z.string().optional(),
  tags:       z.array(z.string()).optional(),
  subject:    z.string().optional(),
  lawCode:    z.string().optional(),
  articleRef: z.string().optional(),
});

const ListQuerySchema = z.object({
  topicId: z.string().optional(),
  subject: z.string().optional(),
  tag:     z.string().optional(),
  q:       z.string().optional(),
});

export class AnotacoesController {
  private svc = new AnotacoesService();

  async list(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const query = ListQuerySchema.parse(req.query);
    return reply.send(await this.svc.list(user.id, query));
  }

  async create(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const body = CreateSchema.parse(req.body);
    return reply.code(201).send(await this.svc.create(user.id, body));
  }

  async update(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const body = UpdateSchema.parse(req.body);
    return reply.send(await this.svc.update(user.id, id, body));
  }

  async remove(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    await this.svc.remove(user.id, id);
    return reply.code(204).send();
  }
}
