import Fastify from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import jwt from '@fastify/jwt';
import rateLimit from '@fastify/rate-limit';
import * as Sentry from '@sentry/node';

import { AppError } from './shared/errors';
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

  const corsOrigin: string | string[] | boolean =
    process.env.NODE_ENV === 'production'
      ? process.env.CORS_ORIGIN
        ? process.env.CORS_ORIGIN.split(',').map((o) => o.trim())
        : true
      : true;

  await app.register(cors, { origin: corsOrigin });
  await app.register(jwt, {
    secret: process.env.SUPABASE_JWT_SECRET!,
  });
  await app.register(rateLimit, {
    max: 200,
    timeWindow: '1 minute',
  });

  app.setErrorHandler((error, _req, reply) => {
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send({
        error: error.code,
        message: error.message,
        statusCode: error.statusCode,
      });
    }

    if (error.statusCode === 400) {
      return reply.status(400).send({
        error: 'VALIDATION_ERROR',
        message: error.message,
        statusCode: 400,
      });
    }

    Sentry.captureException(error);
    reply.log.error(error);
    return reply.status(500).send({
      error: 'INTERNAL_ERROR',
      message: 'Erro interno do servidor',
      statusCode: 500,
    });
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
