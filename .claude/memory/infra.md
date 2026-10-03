---
domain: infra
updated: 2026-06-24
owner: ato-infra
---

# Memória de Infraestrutura — ATO

> Estado real dos provedores e da configuração de ambiente. Mantido pelo agent `ato-infra`
> ao fim de toda auditoria ou mudança de infra. Fonte de números: `docs/specs/ATO_Stack_Infraestrutura_v1.0.txt`,
> `docs/env-checklist.md`, `.claude/PROJECT_STATE.md`.

---

## Mapa de Provedores (MVP — 100–500 assinantes)

| Serviço | Provedor | Plano | Custo/mês | Estado |
|---------|----------|-------|-----------|--------|
| API | **Railway** | Hobby | ~$5–8 | ⚠️ Root Directory pendente (`/` → `back`) |
| DB + Auth | **Supabase** | Free | $0 | ✅ staging + live; upgrade Pro ($25) ao atingir ~400 MB |
| Cache/Sessão | **Upstash Redis** | Free | $0 | ✅ 10k cmds/dia, 256 MB |
| CDN | **Cloudflare** | Free | $0 | ⏳ não configurado (sem domínio) |
| Observabilidade | **Sentry** | Free 5k ev/mês | $0 | ⏳ `SENTRY_DSN` pendente |
| Analytics | **Umami** | self-host Railway | $0 | ⏳ não provisionado |
| Push | **OneSignal** | Free 10k subs | $0 | ⏳ credenciais pendentes (graceful degradation no código) |
| Pagamento | **RevenueCat** | Free < $2.5k MRR | $0 | ⏳ webhook secret + produtos IAP pendentes |
| LLM primário | **Maritaca** (Sabiá-4/Sabiázinho-4) | pay-per-token | ~$1–32 | ✅ ativo — ver `llm.md` |
| LLM secundário | **Anthropic** (Sonnet 4.6) | pay-per-token | incl. acima | ✅ ativo (só perfil) — ver `llm.md` |

**Total atual estimado:** ~$6–40/mês.

---

## Railway (API)

- **URL produção:** `https://lcf-production.up.railway.app`
- **Build:** `npm run build` · **Start:** `node dist/server.js`
- **Health check:** `GET /health` — sempre HTTP 200 com `status: degraded` em falha de DB/Redis (decisão fixada: evita restart loops).
- **⚠️ Pendência crítica:** Root Directory ainda em `/`; deve ser `back` (Settings → Source). Sem isso o deploy detecta a raiz errada.
- **Env vars:** todas em Railway → Variables. `SUPABASE_JWT_SECRET` colado com `\n` literal — `app.ts` normaliza via `.replace(/\\n/g,'\n')`.
- **Escala:** Hobby → Pro automático sob carga; esperado ~$20–50/mês com 500+ assinantes.

## Supabase (DB + Auth)

- **Ambientes:** staging + live (dois projetos).
- **Conexão:** Transaction mode, porta **6543** (pooler `aws-1-us-west-2.pooler.supabase.com`).
- **Auth:** JWT **HS256 simétrico** via `SUPABASE_JWT_SECRET` (não RS256 — `SUPABASE_JWT_PUBLIC_KEY` não existe). Google OAuth ✅ funcionando; Apple ⏳ aguarda licença Apple.
- **`legal_articles`** (18.779 registros) está **fora do Prisma** — acessar só via `$queryRaw`.
- **Gatilho de upgrade:** storage (~400 MB) chega antes do limite de 50k MAU.
- **Sem pgvector no MVP** — busca é BM25 (`portuguese_unaccent`). pgvector só na v1.1.

## Upstash Redis (Cache/Sessão)

- **Free:** 10k comandos/dia, 256 MB. REST API (`UPSTASH_REDIS_REST_URL` + `_TOKEN`).
- **Namespaces ativos:** `tutor:session:{uuid}` (4h), `tutor:rate:{userId}` (24h), `tutor:tokens:{uuid}` (4h), `tutor:session:owner:{sessionId}` (4h), `simulado:daily:{userId}` (24h).
- **Atenção de capacidade:** 10k cmds/dia é o teto mais apertado do stack — monitorar primeiro aqui sob carga real.

## Pendentes / não provisionados

- Cloudflare CDN (depende de domínio).
- Sentry DSN (frontend Flutter + backend Node).
- Umami container no Railway.
- OneSignal `ONESIGNAL_APP_ID` + `ONESIGNAL_API_KEY`.
- RevenueCat `REVENUECAT_WEBHOOK_SECRET` + produtos IAP (bloqueado por pricing + App Store Connect).

---

## Thresholds de upgrade vigiar (pós-lançamento)

| Sinal | Ação |
|-------|------|
| Supabase storage > ~400 MB | Free → Pro ($25/mês) |
| Upstash > 10k cmds/dia | Pay-as-you-go |
| Railway CPU/RAM saturando | Hobby → Pro |
| Sentry > 5k eventos/mês | revisar sampling ou plano |
| RevenueCat > $2.5k MRR | passa a cobrar 1% |

---

## Roadmap de escala (não implementar no MVP)

- 500+: cache de respostas LLM frequentes, Umami dedicado.
- 1000+: Supabase→RDS, Railway→ECS/Fargate, ElastiCache, Datadog/New Relic.
- IA futura: RAG com pgvector, fila Bull/BullMQ para embeddings. LLM agnóstico via adapter (troca de provedor sem refatorar — só o adapter).

Ver também: [[llm.md]] · [[launch.md]] · [[security.md]]
