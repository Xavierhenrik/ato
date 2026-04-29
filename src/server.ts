import 'dotenv/config';
import { buildApp } from './app';

const PORT = parseInt(process.env.PORT ?? '3000', 10);
const HOST = process.env.HOST ?? '0.0.0.0';

async function start() {
  const app = await buildApp();

  try {
    await app.listen({ port: PORT, host: HOST });
    app.log.info(`LCF Backend running on ${HOST}:${PORT} [${process.env.NODE_ENV}]`);
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
}

start();
