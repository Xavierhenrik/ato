import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { DashboardController } from './dashboard.controller';

export async function dashboardRoutes(app: FastifyInstance) {
  const ctrl = new DashboardController();

  app.get('/',             { preHandler: [requireAuth] }, ctrl.getHome.bind(ctrl));
  app.get('/revision-cards', { preHandler: [requireAuth] }, ctrl.getRevisionCards.bind(ctrl));
  app.get('/performance',  { preHandler: [requireAuth] }, ctrl.getPerformance.bind(ctrl));
  app.get('/streak',       { preHandler: [requireAuth] }, ctrl.getStreak.bind(ctrl));
  app.post('/study-session', { preHandler: [requireAuth] }, ctrl.logStudySession.bind(ctrl));
}
