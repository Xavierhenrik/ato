import { FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import { UsersService } from './users.service';

const UpdateProfileSchema = z.object({
  name:          z.string().min(1).optional(),
  avatarUrl:     z.string().url().optional(),
  academicPhase: z.enum(['graduation_start', 'graduation_mid', 'graduation_end', 'oab_prep']).optional(),
});

const UpdateNotifSchema = z.object({
  notifEnabled:       z.boolean(),
  notifTime:          z.string().regex(/^\d{2}:\d{2}$/).optional(),
  oneSignalPlayerId:  z.string().optional(),
});

export class UsersController {
  private svc = new UsersService();

  async getProfile(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    return reply.send(await this.svc.getProfile(user.id));
  }

  async updateProfile(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const body = UpdateProfileSchema.parse(req.body);
    return reply.send(await this.svc.updateProfile(user.id, body));
  }

  async updateNotifications(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const body = UpdateNotifSchema.parse(req.body);
    return reply.send(await this.svc.updateNotifications(user.id, body));
  }
}
