import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { SubscriptionsController } from './subscriptions.controller';

export async function subscriptionsRoutes(app: FastifyInstance) {
  const ctrl = new SubscriptionsController();

  // T22 — Status do plano atual
  app.get('/status', { preHandler: [requireAuth] }, ctrl.getStatus.bind(ctrl));

  // RevenueCat webhook (sem auth JWT — autenticado pelo header secret)
  app.post('/webhook/revenuecat', ctrl.revenueCatWebhook.bind(ctrl));
}
