import 'dotenv/config';
import * as Sentry from '@sentry/node';
import { buildApp } from './app';

if (process.env.SENTRY_DSN) {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.NODE_ENV ?? 'development',
    tracesSampleRate: 0.2,
  });
}

const PORT = parseInt(process.env.PORT ?? '3000', 10);
const HOST = process.env.HOST ?? '0.0.0.0';

async function start() {
  const app = await buildApp();

  try {
    await app.listen({ port: PORT, host: HOST });
    app.log.info(`LEX Backend running on ${HOST}:${PORT} [${process.env.NODE_ENV}]`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
}

start();
