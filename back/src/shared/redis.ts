import { Redis } from '@upstash/redis';
import { MemoryRedis } from './memory-redis';

// REDIS_MODE=memory: workaround local enquanto o Upstash esta fora. Remover a linha do .env volta ao Upstash.
const useMemory = process.env.REDIS_MODE === 'memory';

if (useMemory && process.env.NODE_ENV === 'production') {
  throw new Error('REDIS_MODE=memory nao e permitido em producao');
}
if (useMemory) {
  console.warn('[redis] REDIS_MODE=memory: usando Redis em memoria (workaround local, estado volatil)');
}

export const redis: Redis = useMemory
  ? (new MemoryRedis() as unknown as Redis)
  : new Redis({
      url: process.env.UPSTASH_REDIS_REST_URL!,
      token: process.env.UPSTASH_REDIS_REST_TOKEN!,
    });

// Key builders
export const keys = {
  tutorSession: (sessionId: string) => `tutor:session:${sessionId}`,
  tutorSessionOwner: (sessionId: string) => `tutor:session:owner:${sessionId}`,
  tutorRateLimit: (userId: string) => `tutor:rate:${userId}`,
  tutorTokenBudget: (sessionId: string) => `tutor:tokens:${sessionId}`,
  simuladoDaily: (userId: string) => `simulado:daily:${userId}`,
  subPro: (userId: string) => `sub:pro:${userId}`,
};

export const TTL = {
  tutorSession: 4 * 60 * 60,    // 4 hours
  rateLimitDay: 24 * 60 * 60,   // 24 hours
};
