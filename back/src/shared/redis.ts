import { Redis } from '@upstash/redis';

export const redis = new Redis({
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
