import { FastifyRequest, FastifyReply } from 'fastify';
import { AuthService } from './auth.service';

export class AuthController {
  private svc = new AuthService();

  async verify(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const result = await this.svc.getUser(user.id);
    return reply.send(result);
  }

  async me(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const result = await this.svc.getFullProfile(user.id);
    return reply.send(result);
  }

  async deleteAccount(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as {
      id: string;
      supabaseId: string;
    };
    await this.svc.deleteAccount(user.id, user.supabaseId);
    return reply.code(204).send();
  }
}
