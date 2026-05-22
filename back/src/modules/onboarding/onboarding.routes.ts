import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { OnboardingController } from './onboarding.controller';

export async function onboardingRoutes(app: FastifyInstance) {
  const ctrl = new OnboardingController();

  app.post('/complete',                    { preHandler: [requireAuth] }, ctrl.complete.bind(ctrl));
  app.post('/diagnostic/complete',         { preHandler: [requireAuth] }, ctrl.completeQuiz.bind(ctrl));
  app.post('/diagnostic/dismiss',          { preHandler: [requireAuth] }, ctrl.dismissQuiz.bind(ctrl));
}
