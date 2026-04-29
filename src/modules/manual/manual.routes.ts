import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { ManualController } from './manual.controller';

export async function manualRoutes(app: FastifyInstance) {
  const ctrl = new ManualController();

  // T09 — Lista de diplomas/matérias
  app.get('/topics', { preHandler: [requireAuth] }, ctrl.listTopics.bind(ctrl));

  // T10/T13 — Conteúdo de um tópico específico
  app.get('/topics/:id', { preHandler: [requireAuth] }, ctrl.getTopic.bind(ctrl));

  // Busca full-text no manual
  app.get('/search', { preHandler: [requireAuth] }, ctrl.search.bind(ctrl));

  // Artigo direto do corpus (lookup_article)
  app.get('/articles', { preHandler: [requireAuth] }, ctrl.getArticle.bind(ctrl));
}
