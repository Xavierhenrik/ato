import { FastifyInstance } from 'fastify';
import { requireAuth } from '../../shared/middlewares/auth.middleware';
import { AuthController } from './auth.controller';

export async function authRoutes(app: FastifyInstance) {
  const ctrl = new AuthController();

  // Verifica JWT Supabase e retorna/cria usuário LCF
  app.post('/verify', { preHandler: [requireAuth] }, ctrl.verify.bind(ctrl));

  // Perfil do usuário autenticado
  app.get('/me', { preHandler: [requireAuth] }, ctrl.me.bind(ctrl));

  // Exclusão de conta (LGPD)
  app.delete('/me', { preHandler: [requireAuth] }, ctrl.deleteAccount.bind(ctrl));
}
