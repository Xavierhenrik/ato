import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { SimuladosController } from './simulados.controller';

export async function simuladosRoutes(app: FastifyInstance) {
  const ctrl = new SimuladosController();

  // T15 — Banco de questões (filtros por matéria, diploma, dificuldade)
  app.get('/questions', { preHandler: [requireAuth] }, ctrl.listQuestions.bind(ctrl));

  // Inicia simulado
  app.post('/start', { preHandler: [requireAuth] }, ctrl.start.bind(ctrl));

  // Responde uma questão
  app.post('/:id/answer', { preHandler: [requireAuth] }, ctrl.answer.bind(ctrl));

  // Finaliza simulado
  app.post('/:id/complete', { preHandler: [requireAuth] }, ctrl.complete.bind(ctrl));

  // T17 — Resultados de uma tentativa
  app.get('/:id/results', { preHandler: [requireAuth] }, ctrl.getResults.bind(ctrl));

  // Histórico de simulados do usuário
  app.get('/history', { preHandler: [requireAuth] }, ctrl.getHistory.bind(ctrl));
}
