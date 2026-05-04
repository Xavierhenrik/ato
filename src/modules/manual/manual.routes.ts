import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { ManualController } from './manual.controller';

export async function manualRoutes(app: FastifyInstance) {
  const ctrl = new ManualController();

  app.get('/topics',           { preHandler: [requireAuth] }, ctrl.listTopics.bind(ctrl));
  app.get('/topics/:id',       { preHandler: [requireAuth] }, ctrl.getTopic.bind(ctrl));
  app.post('/topics/:id/read', { preHandler: [requireAuth] }, ctrl.markAsRead.bind(ctrl));
  app.get('/search',           { preHandler: [requireAuth] }, ctrl.search.bind(ctrl));
  app.get('/articles',         { preHandler: [requireAuth] }, ctrl.getArticle.bind(ctrl));
}
