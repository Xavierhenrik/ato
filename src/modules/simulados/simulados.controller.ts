import { FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import { SimuladosService } from './simulados.service';

const StartSchema = z.object({
  mode: z.enum(['custom', 'oab_phase1', 'oab_phase2', 'weak_areas']),
  subject: z.string().optional(),
  totalQ: z.number().int().min(5).max(80).default(30),
});

const AnswerSchema = z.object({
  questionId: z.string().uuid(),
  answer: z.enum(['A', 'B', 'C', 'D']),
  timeSpentSecs: z.number().int().optional(),
});

export class SimuladosController {
  private svc = new SimuladosService();

  async listQuestions(req: FastifyRequest, reply: FastifyReply) {
    const query = z
      .object({
        subject: z.string().optional(),
        lawCode: z.string().optional(),
        difficulty: z.string().optional(),
        limit: z.coerce.number().default(20),
      })
      .parse(req.query);
    return reply.send(await this.svc.listQuestions(query));
  }

  async start(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const body = StartSchema.parse(req.body);
    return reply.send(await this.svc.startAttempt(user.id, body));
  }

  async answer(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const body = AnswerSchema.parse(req.body);
    return reply.send(await this.svc.submitAnswer(user.id, id, body));
  }

  async complete(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    return reply.send(await this.svc.completeAttempt(user.id, id));
  }

  async getResults(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    return reply.send(await this.svc.getResults(user.id, id));
  }

  async getHistory(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    return reply.send(await this.svc.getHistory(user.id));
  }
}
