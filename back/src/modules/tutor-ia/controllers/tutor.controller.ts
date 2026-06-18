import { FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import { TutorService } from '../services/tutor.service';
import { SessionService } from '../services/session.service';
import { getIsPro } from '../services/plan.service';
import { db } from '../../../shared/db';
import { FOLLOW_UP_CHIPS, READING_CHIPS } from '../prompts/chips.config';

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

  async newSession(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const sessionId = crypto.randomUUID();
    await this.sessionSvc.create(sessionId, user.id);
    return reply.send({ session_id: sessionId });
  }

  async sendMessage(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const body = MessageBodySchema.parse(req.body);
    await this.sessionSvc.validateOwnership(body.session_id, user.id);

    const isPro = await getIsPro(user.id);

    const response = await this.tutorSvc.chat({
      sessionId: body.session_id,
      userId: user.id,
      message: body.message,
      mode: body.mode,
      isPro,
      context: body.context,
      logger: req.log,
    });

    const chips = body.mode === 'reading' ? READING_CHIPS : FOLLOW_UP_CHIPS;
    return reply.send({ ...response, chips });
  }

  async getSession(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    await this.sessionSvc.validateOwnership(id, user.id);
    const history = await this.sessionSvc.getHistory(id);
    return reply.send({ session_id: id, messages: history });
  }

  async deleteSession(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const { id } = z.object({ id: z.string().uuid() }).parse(req.params);
    const { mode } = z.object({
      mode: z.enum(['reading', 'simulado', 'direct']).default('direct'),
    }).parse(req.query);
    await this.sessionSvc.validateOwnership(id, user.id);

    if (mode !== 'simulado') {
      await db.tutorSession.updateMany({
        where: { id, userId: user.id },
        data: { endedAt: new Date() },
      });
    }

    await this.sessionSvc.clear(id);
    return reply.code(204).send();
  }
}
