import Fastify from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import jwt from '@fastify/jwt';
import rateLimit from '@fastify/rate-limit';
import * as Sentry from '@sentry/node';

import { AppError } from './shared/errors';
import { db } from './shared/db';
import { redis } from './shared/redis';
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
    secret: {
      public: process.env.SUPABASE_JWT_PUBLIC_KEY!,
    },
  });
  await app.register(rateLimit, {
    max: 200,
    timeWindow: '1 minute',
  });

  // Allow POST/PUT requests with Content-Type: application/json but no body
  // (e.g. POST /tutor/session/new). Fastify rejects empty bodies by default.
  app.addContentTypeParser('application/json', { parseAs: 'string' }, (_req, body: string, done) => {
    if (!body || body.trim() === '') { done(null, null); return; }
    try { done(null, JSON.parse(body)); }
    catch (e) { (e as Error & { statusCode?: number }).statusCode = 400; done(e as Error); }
  });

  app.setErrorHandler((error, _req, reply) => {
    if (error instanceof AppError) {
      return reply.status(error.statusCode).send({
        error: error.code,
        message: error.message,
        statusCode: error.statusCode,
        ...error.extra,
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

  // Health check — sempre retorna HTTP 200 para evitar restart loops
  app.get('/health', async (_req, reply) => {
    let dbStatus: 'ok' | 'error' = 'ok';
    let redisStatus: 'ok' | 'error' = 'ok';

    try {
      await db.$queryRaw`SELECT 1`;
    } catch {
      dbStatus = 'error';
    }

    try {
      await redis.ping();
    } catch {
      redisStatus = 'error';
    }

    const overallStatus = dbStatus === 'ok' && redisStatus === 'ok' ? 'ok' : 'degraded';

    return reply.code(200).send({
      status: overallStatus,
      ts: new Date().toISOString(),
      db: dbStatus,
      redis: redisStatus,
    });
  });

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
