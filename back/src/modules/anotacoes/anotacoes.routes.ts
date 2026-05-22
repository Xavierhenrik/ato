import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { AnotacoesController } from './anotacoes.controller';

export async function anotacoesRoutes(app: FastifyInstance) {
  const ctrl = new AnotacoesController();

  app.get('/', { preHandler: [requireAuth] }, ctrl.list.bind(ctrl));
  app.post('/', { preHandler: [requireAuth] }, ctrl.create.bind(ctrl));
  app.put('/:id', { preHandler: [requireAuth] }, ctrl.update.bind(ctrl));
  app.delete('/:id', { preHandler: [requireAuth] }, ctrl.remove.bind(ctrl));
}
