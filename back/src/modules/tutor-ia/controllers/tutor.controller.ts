import { FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import { TutorService } from '../services/tutor.service';
import { SessionService } from '../services/session.service';
import { db } from '../../../shared/db';
import { redis, keys } from '../../../shared/redis';
import { FOLLOW_UP_CHIPS } from '../prompts/chips.config';

const MessageBodySchema = z.object({
  session_id: z.string().uuid(),
  message: z.string().min(1).max(2000),
  mode: z.enum(['reading', 'simulado', 'direct']),
  context: z
    .object({
      topic_id: z.string().optional(),
      topic_title: z.string().optional(),
      topic_content: z.string().optional(),
      question_bundle: z
        .object({
          statement: z.string(),
          options: z.object({ A: z.string(), B: z.string(), C: z.string(), D: z.string() }),
          correct_answer: z.string(),
          student_answer: z.string(),
          subject: z.string(),
          board: z.string(),
          year: z.number(),
        })
        .optional(),
    })
    .optional(),
});

export class TutorController {
  private tutorSvc = new TutorService();
  private sessionSvc = new SessionService();

  private async _getIsPro(userId: string): Promise<boolean> {
    const cacheKey = keys.subPro(userId);
    const cached = await redis.get<string>(cacheKey);
    if (cached !== null) return cached === 'true';

    const sub = await db.subscription.findUnique({ where: { userId } });
    const isPro = sub?.plan === 'pro' && sub?.status === 'active';
    await redis.set(cacheKey, isPro ? 'true' : 'false', { ex: 300 });
    return isPro;
  }

  async newSession(_req: FastifyRequest, reply: FastifyReply) {
    const sessionId = crypto.randomUUID();
    return reply.send({ session_id: sessionId });
  }

  async sendMessage(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const body = MessageBodySchema.parse(req.body);

    const isPro = await this._getIsPro(user.id);

    const response = await this.tutorSvc.chat({
      sessionId: body.session_id,
      userId: user.id,
      message: body.message,
      mode: body.mode,
      isPro,
      context: body.context,
      logger: req.log,
    });

    return reply.send({ ...response, chips: FOLLOW_UP_CHIPS });
  }

  async getSession(req: FastifyRequest, reply: FastifyReply) {
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const history = await this.sessionSvc.getHistory(id);
    return reply.send({ session_id: id, messages: history });
  }

  async deleteSession(req: FastifyRequest, reply: FastifyReply) {
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const { mode } = z.object({
      mode: z.enum(['reading', 'simulado', 'direct']).default('direct'),
    }).parse(req.query);
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };

    await this.sessionSvc.persistToDB(id, user.id, mode);
    await this.sessionSvc.clear(id);
    return reply.code(204).send();
  }
}
