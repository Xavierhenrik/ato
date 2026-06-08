import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { AnotacoesController } from './anotacoes.controller';

export async function anotacoesRoutes(app: FastifyInstance) {
  const ctrl = new AnotacoesController();

  app.get('/', { preHandler: [requireAuth] }, ctrl.list.bind(ctrl));

  // POST /annotations — rate limit: 30 req/min por usuário
  app.post('/', {
    preHandler: [requireAuth],
    config: {
      rateLimit: {
        max: 30,
        timeWindow: '1 minute',
        keyGenerator: (req) => {
          const user = (req as unknown as Record<string, unknown>).currentUser as { id: string } | undefined;
          return user?.id ?? req.ip;
        },
      },
    },
  }, ctrl.create.bind(ctrl));

  app.put('/:id', { preHandler: [requireAuth] }, ctrl.update.bind(ctrl));
  app.delete('/:id', { preHandler: [requireAuth] }, ctrl.remove.bind(ctrl));
}
