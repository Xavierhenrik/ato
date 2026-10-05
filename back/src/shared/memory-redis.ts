/**
 * WORKAROUND LOCAL: substituto em memoria do Upstash, ativado por REDIS_MODE=memory.
 *
 * Cobre so os comandos que o backend usa (get, set com ex, incr, expire, del, ping).
 * Estado vive no processo: some a cada restart do tsx watch e nao e compartilhado.
 * Nunca usar em producao; o guard fica em redis.ts.
 */
type Entry = { value: unknown; expiresAt: number | null };

export class MemoryRedis {
  private store = new Map<string, Entry>();

  private read(key: string): Entry | undefined {
    const entry = this.store.get(key);
    if (entry && entry.expiresAt !== null && entry.expiresAt <= Date.now()) {
      this.store.delete(key);
      return undefined;
    }
    return entry;
  }

  async ping(): Promise<'PONG'> {
    return 'PONG';
  }

  async get<T>(key: string): Promise<T | null> {
    const entry = this.read(key);
    // structuredClone imita a (de)serializacao JSON do Upstash: quem le nao altera o armazenado
    return entry ? (structuredClone(entry.value) as T) : null;
  }

  async set(key: string, value: unknown, opts?: { ex?: number }): Promise<'OK'> {
    const expiresAt = opts?.ex ? Date.now() + opts.ex * 1000 : null;
    this.store.set(key, { value: structuredClone(value), expiresAt });
    return 'OK';
  }

  async incr(key: string): Promise<number> {
    const entry = this.read(key);
    const next = Number(entry?.value ?? 0) + 1;
    this.store.set(key, { value: next, expiresAt: entry?.expiresAt ?? null });
    return next;
  }

  async expire(key: string, seconds: number): Promise<0 | 1> {
    const entry = this.read(key);
    if (!entry) return 0;
    entry.expiresAt = Date.now() + seconds * 1000;
    return 1;
  }

  async del(...keys: string[]): Promise<number> {
    let removed = 0;
    for (const key of keys) {
      if (this.read(key) && this.store.delete(key)) removed++;
    }
    return removed;
  }
}
