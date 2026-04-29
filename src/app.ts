import Fastify from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import jwt from '@fastify/jwt';
import rateLimit from '@fastify/rate-limit';

import { authRoutes } from './modules/auth/auth.routes';
import { onboardingRoutes } from './modules/onboarding/onboarding.routes';
import { dashboardRoutes } from './modules/dashboard/dashboard.routes';
import { manualRoutes } from './modules/manual/manual.routes';
import { tutorRoutes } from './modules/tutor-ia/tutor.routes';
import { simuladosRoutes } from './modules/simulados/simulados.routes';
import { anotacoesRoutes } from './modules/anotacoes/anotacoes.routes';
import { usersRoutes } from './modules/users/users.routes';
import { subscriptionsRoutes } from './modules/subscriptions/subscriptions.routes';

export async function buildApp() {
  const app = Fastify({
    logger: {
      level: process.env.LOG_LEVEL ?? 'info',
      ...(process.env.NODE_ENV === 'development' && {
        transport: { target: 'pino-pretty' },
      }),
    },
  });

  await app.register(helmet);
  await app.register(cors, {
    origin: process.env.NODE_ENV === 'production' ? false : true,
  });
  await app.register(jwt, {
    secret: process.env.SUPABASE_JWT_SECRET!,
  });
  await app.register(rateLimit, {
    max: 200,
    timeWindow: '1 minute',
  });

  // Health check
  app.get('/health', async () => ({ status: 'ok', ts: new Date().toISOString() }));

  // Modules
  await app.register(authRoutes, { prefix: '/auth' });
  await app.register(onboardingRoutes, { prefix: '/onboarding' });
  await app.register(dashboardRoutes, { prefix: '/dashboard' });
  await app.register(manualRoutes, { prefix: '/manual' });
  await app.register(tutorRoutes, { prefix: '/tutor' });
  await app.register(simuladosRoutes, { prefix: '/simulados' });
  await app.register(anotacoesRoutes, { prefix: '/annotations' });
  await app.register(usersRoutes, { prefix: '/users' });
  await app.register(subscriptionsRoutes, { prefix: '/subscriptions' });

  return app;
}
