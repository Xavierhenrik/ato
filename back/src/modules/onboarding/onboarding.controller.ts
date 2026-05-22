import { FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import { OnboardingService } from './onboarding.service';

const CompleteSchema = z.object({
  academicPhase: z.enum(['graduation_start', 'graduation_mid', 'graduation_end', 'oab_prep']),
  dailyStudyMins: z.union([z.literal(30), z.literal(60), z.literal(120), z.literal(180)]),
});

export class OnboardingController {
  private svc = new OnboardingService();

  async complete(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const body = CompleteSchema.parse(req.body);
    return reply.send(await this.svc.complete(user.id, body.academicPhase, body.dailyStudyMins));
  }

  async completeQuiz(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    return reply.send(await this.svc.completeQuiz(user.id));
  }

  async dismissQuiz(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    return reply.send(await this.svc.dismissQuiz(user.id));
  }
}
