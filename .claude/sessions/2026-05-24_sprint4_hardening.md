# Sessão 2026-05-24 — Sprint 4 Hardening & Integração

## O que foi feito

- **5.1 Segurança e Validação (Auditoria Zod):** auditados todos os controllers (auth, onboarding, dashboard, manual, anotacoes, users, simulados, tutor-ia, subscriptions). Resultado: todos já usam `schema.parse()` explícito em body, query params e path params. `requirePro` já estava aplicado em `weak_areas` e `excludeAnswered` (service layer). Nenhuma correção necessária.
- **5.1 Rate Limits Granulares:**
  - `POST /simulados/start` → 5 req/min por usuário (via `config.rateLimit`)
  - `POST /annotations` → 30 req/min por usuário
  - `POST /tutor/message` → 60 req/min por usuário (rate limit de infra, separado do rate limit de negócio Redis)
- **5.2 Índices de DB:** adicionados ao model `SimuladoQuestion` em `prisma/schema.prisma`:
  - `@@index([isCorrect])`
  - `@@index([answeredAt])`
  - `@@index([attemptId, isCorrect])`
- **5.3 Tech Debt:** adicionado `@db.Uuid` em `Question.id` — resolve type mismatch UUID/TEXT entre ETL e Prisma. A FK `simulado_questions → questions` já existe implicitamente via Prisma relation; com `@db.Uuid` o tipo está correto em nível PostgreSQL.
- **5.4 Health Check:** expandido `GET /health` em `src/app.ts`:
  - Testa DB com `db.$queryRaw\`SELECT 1\``
  - Testa Redis com `redis.ping()`
  - Retorna `{ status: "ok"|"degraded", ts, db: "ok"|"error", redis: "ok"|"error" }`
  - Sempre HTTP 200 — nunca 500
- **5.5 API Contract Sync:** `docs/api-contract.md` atualizado com:
  - `POST /onboarding/diagnostic/complete` — já documentado, confirmado
  - `POST /onboarding/diagnostic/dismiss` — já documentado, confirmado
  - `GET /dashboard/revision-cards` — já documentado, confirmado
  - `GET /dashboard/performance` — já documentado, confirmado
  - `POST /simulados/:id/abandon` — adicionado com schema de request/response
  - `POST /manual/topics/:id/read` — adicionado
  - Schemas detalhados de `POST /simulados/start`, `POST /simulados/:id/answer`, `GET /simulados/:id/results`
  - Rate limits documentados por endpoint
  - `GET /health` response schema documentado
  - `GET /annotations` query params expandidos (`subject`, `tag`, `q`)

## Arquivos modificados

- `back/src/app.ts` — health check expandido + imports db/redis
- `back/src/modules/simulados/simulados.routes.ts` — rate limit 5/min em POST /start
- `back/src/modules/anotacoes/anotacoes.routes.ts` — rate limit 30/min em POST /
- `back/src/modules/tutor-ia/tutor.routes.ts` — rate limit 60/min em POST /message
- `back/prisma/schema.prisma` — `@@index` em SimuladoQuestion + `@db.Uuid` em Question.id
- `docs/api-contract.md` — sync completo com todos os endpoints dos Sprints 1–3

## Critérios de aceite cumpridos

- [x] Todos os endpoints com body/query têm parse Zod explícito (auditoria confirmou cobertura total)
- [x] `requirePro` aplicado em `weak_areas` e `excludeAnswered` (já estava — confirmado)
- [x] `POST /simulados/start` → 5 req/min por usuário
- [x] `POST /annotations` → 30 req/min por usuário
- [x] `POST /tutor/message` → 60 req/min (infra) separado do rate limit de negócio Redis
- [x] `@@index([isCorrect])`, `@@index([answeredAt])`, `@@index([attemptId, isCorrect])` no schema
- [x] `@db.Uuid` em `questions.id`
- [x] `GET /health` retorna `{ status, ts, db, redis }` — sempre HTTP 200
- [x] `docs/api-contract.md` reflete todos os endpoints dos Sprints 1–3
- [x] `npx tsc --noEmit` — zero erros

## Pendências / Próximos passos

- Rodar `npx prisma migrate dev --name sprint4_simulado_indexes` no ambiente de dev/staging (requer DB com credenciais)
- Push Notifications (OneSignal) — bloqueado aguardando ONESIGNAL_APP_ID + API_KEY

## Decisões tomadas

- Rate limits por rota usam `config.rateLimit` do `@fastify/rate-limit` com `keyGenerator` por `userId` (fallback `req.ip` para casos não autenticados)
- Health check nunca retorna 500 — padrão Railway para evitar restart loops em falhas temporárias de conectividade
- `@db.Uuid` em `Question.id` resolve o débito técnico de type mismatch; FK implícita via Prisma ORM é suficiente para o MVP
