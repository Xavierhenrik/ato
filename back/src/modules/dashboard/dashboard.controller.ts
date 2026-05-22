import { FastifyRequest, FastifyReply } from 'fastify';
import { DashboardService } from './dashboard.service';

export class DashboardController {
  private svc = new DashboardService();

  async getHome(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    return reply.send(await this.svc.getHomeData(user.id));
  }

  async getRevisionCards(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    return reply.send(await this.svc.getRevisionCards(user.id));
  }

  async getPerformance(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    return reply.send(await this.svc.getPerformanceHub(user.id));
  }

  async getStreak(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    return reply.send(await this.svc.getStreakData(user.id));
  }

  async logStudySession(req: FastifyRequest, reply: FastifyReply) {
    const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
    return reply.send(await this.svc.logStudySession(user.id));
  }
}
