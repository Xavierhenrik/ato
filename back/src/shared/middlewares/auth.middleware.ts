import { FastifyRequest, FastifyReply } from 'fastify';
import { db } from '../db';
import { Errors } from '../errors';

export async function requireAuth(req: FastifyRequest, _reply: FastifyReply) {
  try {
    await req.jwtVerify();

    const payload = req.user as { sub: string; email: string };
    const user = await db.user.findUnique({ where: { supabaseId: payload.sub } });

    if (!user) {
      // Auto-provision on first verified request
      const newUser = await db.user.create({
        data: {
          supabaseId: payload.sub,
          email: payload.email,
          profile: {
            create: { name: payload.email.split('@')[0] },
          },
          subscription: {
            create: { plan: 'free' },
          },
        },
      });
      (req as unknown as Record<string, unknown>).currentUser = newUser;
    } else {
      (req as unknown as Record<string, unknown>).currentUser = user;
    }
  } catch {
    throw Errors.unauthorized();
  }
}

export async function requirePro(req: FastifyRequest, _reply: FastifyReply) {
  const user = (req as unknown as Record<string, unknown>).currentUser as { id: string };
  const sub = await db.subscription.findUnique({ where: { userId: user.id } });

  if (!sub || sub.plan !== 'pro' || sub.status !== 'active') {
    throw Errors.proRequired();
  }
}
