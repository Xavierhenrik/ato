import { FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import { OnboardingService } from './onboarding.service';

const UpdateStepSchema = z.object({
  step: z.number().int().min(1).max(4),
  data: z.record(z.unknown()),
});

export class OnboardingController {
  private svc = new OnboardingService();

  async getState(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    return reply.send(await this.svc.getState(user.id));
  }

  async updateStep(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const body = UpdateStepSchema.parse(req.body);
    return reply.send(await this.svc.updateStep(user.id, body.step, body.data));
  }

  async complete(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    return reply.send(await this.svc.complete(user.id));
  }
}
