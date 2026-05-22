import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { TutorController } from './controllers/tutor.controller';

export async function tutorRoutes(app: FastifyInstance) {
  const ctrl = new TutorController();

  // POST /tutor/session/new
  app.post('/session/new', { preHandler: [requireAuth] }, ctrl.newSession.bind(ctrl));

  // POST /tutor/message
  app.post('/message', { preHandler: [requireAuth] }, ctrl.sendMessage.bind(ctrl));

  // GET /tutor/session/:id
  app.get('/session/:id', { preHandler: [requireAuth] }, ctrl.getSession.bind(ctrl));

  // DELETE /tutor/session/:id
  app.delete('/session/:id', { preHandler: [requireAuth] }, ctrl.deleteSession.bind(ctrl));
}
