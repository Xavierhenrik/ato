import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { OnboardingController } from './onboarding.controller';

export async function onboardingRoutes(app: FastifyInstance) {
  const ctrl = new OnboardingController();

  app.get('/state', { preHandler: [requireAuth] }, ctrl.getState.bind(ctrl));
  app.put('/step', { preHandler: [requireAuth] }, ctrl.updateStep.bind(ctrl));
  app.post('/complete', { preHandler: [requireAuth] }, ctrl.complete.bind(ctrl));
}
