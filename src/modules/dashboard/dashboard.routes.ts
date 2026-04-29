import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { DashboardController } from './dashboard.controller';

export async function dashboardRoutes(app: FastifyInstance) {
  const ctrl = new DashboardController();

  // T07 — Home data (streak + progresso + atividade recente)
  app.get('/', { preHandler: [requireAuth] }, ctrl.getHome.bind(ctrl));

  // T08 — Streak details
  app.get('/streak', { preHandler: [requireAuth] }, ctrl.getStreak.bind(ctrl));

  // Registra sessão de estudo (atualiza streak)
  app.post('/study-session', { preHandler: [requireAuth] }, ctrl.logStudySession.bind(ctrl));
}
