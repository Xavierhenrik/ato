import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { UsersController } from './users.controller';

export async function usersRoutes(app: FastifyInstance) {
  const ctrl = new UsersController();

  // T20 — Perfil
  app.get('/profile', { preHandler: [requireAuth] }, ctrl.getProfile.bind(ctrl));
  app.put('/profile', { preHandler: [requireAuth] }, ctrl.updateProfile.bind(ctrl));

  // T21 — Notificações (preferências gerais)
  app.put('/notifications', { preHandler: [requireAuth] }, ctrl.updateNotifications.bind(ctrl));

  // Sprint 3 — Registrar OneSignal Player ID (valida via API antes de salvar)
  app.put('/notifications/player', { preHandler: [requireAuth] }, ctrl.updateNotificationsPlayer.bind(ctrl));
}
