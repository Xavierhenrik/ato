import { FastifyRequest, FastifyReply } from 'fastify';
import { z } from 'zod';
import { UsersService } from './users.service';

const UpdateProfileSchema = z.object({
  name:           z.string().min(1).optional(),
  avatarUrl:      z.string().url().optional(),
  academicPhase:  z.enum(['graduation_start', 'graduation_mid', 'graduation_end', 'oab_prep']).optional(),
  dailyStudyMins: z.number().int().min(15).max(480).optional(),
});

const UpdateNotifSchema = z.object({
  notifEnabled:       z.boolean().optional(),
  notifTime:          z.string().regex(/^\d{2}:\d{2}$/).optional(),
  oneSignalPlayerId:  z.string().optional(),
});

const UpdateNotifPlayerSchema = z.object({
  oneSignalPlayerId: z.string().uuid(),
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

  /** Sprint 3 · Push Notifications — PUT /users/notifications/player */
  async updateNotificationsPlayer(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    const { oneSignalPlayerId } = UpdateNotifPlayerSchema.parse(req.body);
    await this.svc.updateNotificationsPlayer(user.id, oneSignalPlayerId);
    return reply.status(204).send();
  }
}
