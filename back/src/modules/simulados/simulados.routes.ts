import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { SimuladosController } from './simulados.controller';

export async function simuladosRoutes(app: FastifyInstance) {
  const ctrl = new SimuladosController();

  // Banco de questões (filtros por matéria, diploma, dificuldade)
  app.get('/questions', { preHandler: [requireAuth] }, ctrl.listQuestions.bind(ctrl));

  // Simulado em andamento
  app.get('/in-progress', { preHandler: [requireAuth] }, ctrl.inProgress.bind(ctrl));

  // Histórico de simulados concluídos
  app.get('/history', { preHandler: [requireAuth] }, ctrl.getHistory.bind(ctrl));

  // Inicia simulado — rate limit: 5 req/min por usuário
  app.post('/start', {
    preHandler: [requireAuth],
    config: {
      rateLimit: {
        max: 5,
        timeWindow: '1 minute',
        keyGenerator: (req) => {
          const user = (req as unknown as Record<string, unknown>).currentUser as { id: string } | undefined;
          return user?.id ?? req.ip;
        },
      },
    },
  }, ctrl.start.bind(ctrl));

  // Responde uma questão
  app.post('/:id/answer', { preHandler: [requireAuth] }, ctrl.answer.bind(ctrl));

  // Finaliza simulado
  app.post('/:id/complete', { preHandler: [requireAuth] }, ctrl.complete.bind(ctrl));

  // Abandona simulado
  app.post('/:id/abandon', { preHandler: [requireAuth] }, ctrl.abandon.bind(ctrl));

  // Resultados de uma tentativa
  app.get('/:id/results', { preHandler: [requireAuth] }, ctrl.getResults.bind(ctrl));
}
