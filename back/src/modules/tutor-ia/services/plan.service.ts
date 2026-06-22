import { redis, keys } from '../../../shared/redis';
import { db } from '../../../shared/db';

/**
 * Returns true if userId has an active PRO subscription.
 * Result is cached in Redis for 300s (5 min).
 */
export async function getIsPro(userId: string): Promise<boolean> {
  const cacheKey = keys.subPro(userId);
  const cached = await redis.get<string>(cacheKey);
  if (cached !== null) return cached === 'true';

  const sub = await db.subscription.findUnique({ where: { userId } });
  const isPro = sub?.plan === 'pro' && sub?.status === 'active';
  await redis.set(cacheKey, isPro ? 'true' : 'false', { ex: 300 });
  return isPro;
}
