import { redis, keys, TTL } from '../../../shared/redis';
import { ChatMessage } from '../adapters/llm.interface';

const MAX_HISTORY = 8; // últimas 8 mensagens (spec seção 8.1)

export class SessionService {
  async getHistory(sessionId: string): Promise<ChatMessage[]> {
    const raw = await redis.get<ChatMessage[]>(keys.tutorSession(sessionId));
    return raw ?? [];
  }

  async append(sessionId: string, newMessages: ChatMessage[]): Promise<void> {
    const history = await this.getHistory(sessionId);
    const updated = [...history, ...newMessages].slice(-MAX_HISTORY);
    await redis.set(keys.tutorSession(sessionId), updated, { ex: TTL.tutorSession });
  }

  async clear(sessionId: string): Promise<void> {
    await redis.del(keys.tutorSession(sessionId));
  }

  async checkRateLimit(userId: string, isPro: boolean): Promise<{ allowed: boolean; remaining: number }> {
    const dailyLimit = isPro
      ? parseInt(process.env.TUTOR_RATE_PRO ?? '200', 10)
      : parseInt(process.env.TUTOR_RATE_FREE ?? '20', 10);

    const key = keys.tutorRateLimit(userId);
    const count = (await redis.get<number>(key)) ?? 0;

    if (count >= dailyLimit) {
      return { allowed: false, remaining: 0 };
    }

    // Increment with TTL reset on first hit each day
    if (count === 0) {
      await redis.set(key, 1, { ex: TTL.rateLimitDay });
    } else {
      await redis.incr(key);
    }

    return { allowed: true, remaining: dailyLimit - count - 1 };
  }

  async checkTokenBudget(sessionId: string, tokensUsed: number): Promise<boolean> {
    const SESSION_BUDGET = 20_000;
    const key = keys.tutorTokenBudget(sessionId);
    const used = (await redis.get<number>(key)) ?? 0;

    if (used + tokensUsed > SESSION_BUDGET) return false;

    await redis.set(key, used + tokensUsed, { ex: TTL.tutorSession });
    return true;
  }
}
