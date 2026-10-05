# ATO Backend — Architecture Overview

**Stack:** Node.js 20 + TypeScript strict + Fastify 4 + Prisma 5 + PostgreSQL (Supabase) + Redis (Upstash)  
**Deploy:** Railway (Hobby ~$5/mês)  
**Padrão:** Monolito Modular → 8 módulos, cada um com route → controller → service

---

## Estrutura de Pastas

```
ato-backend/
├── prisma/
│   └── schema.prisma          # 9 modelos: User, Profile, Subscription, StudyPlan,
│                              #   Topic, TutorSession, TutorMessage, Question,
│                              #   SimuladoAttempt, SimuladoQuestion, Annotation
├── src/
│   ├── server.ts              # Entry point — Fastify listen
│   ├── app.ts                 # Registro de plugins e rotas
│   ├── shared/
│   │   ├── db.ts              # Singleton PrismaClient
│   │   ├── redis.ts           # Upstash Redis client + key builders
│   │   ├── errors.ts          # AppError + Errors factory
│   │   └── middlewares/
│   │       └── auth.middleware.ts   # requireAuth + requirePro
│   └── modules/
│       ├── auth/              # M1 T02 — verify, me, delete account
│       ├── onboarding/        # M1 T03-T06 — steps, complete, study plan
│       ├── dashboard/         # M2 T07-T08 — home data, streak
│       ├── manual/            # M3 T09-T13 — topics, search, articles
│       ├── tutor-ia/          # M4 T14 — loop agêntico completo
│       │   ├── adapters/      # llm.interface, claude.adapter, sabia.adapter, llm.router
│       │   ├── prompts/       # system.prompt, context-reading, context-simulado, chips
│       │   ├── tools/         # lookup-article, search-legislation
│       │   ├── services/      # tutor, context, session, citation
│       │   ├── controllers/   # tutor.controller
│       │   └── schemas/       # tutor-response.schema (Zod)
│       ├── simulados/         # M5 T15-T18 — questões, tentativas, resultados
│       ├── anotacoes/         # M6 T12 — CRUD anotações
│       ├── users/             # T20-T21 — perfil, notificações
│       └── subscriptions/     # T22-T23 — status PRO, RevenueCat webhook
```

---

## Fluxo de Autenticação

```
Flutter App
  → GET /auth (Supabase SDK) → JWT Supabase
  → POST /auth/verify (ATO API, Bearer JWT)
     → requireAuth middleware: jwtVerify() com SUPABASE_JWT_SECRET
     → auto-provision User + Profile + Subscription(free) se novo
     → req.currentUser = { id, email }
  → Todos os endpoints seguintes usam req.currentUser
```

---

## Fluxo Lexia — Loop Agêntico

```
POST /tutor/message
  → requireAuth
  → Verifica rate limit (Redis counter, TTL 24h)
  → llm.router.ts: seleciona Sabiá-4 (75%) ou Claude Sonnet (25%)
  → contextService.build(): monta system prompt + contexto do modo
  → sessionService.getHistory(): últimas 8 msgs do Redis (TTL 4h)
  → adapter.complete(systemPrompt, messages, [lookup_article, search_legislation])
  → LOOP enquanto stop_reason === "tool_use":
      → citationService.handle(toolCall): consulta legal_articles no Supabase
      → append tool_result ao messages
      → adapter.complete() novamente
  → sessionService.append(): persiste histórico
  → citationService.parse(): extrai JSON estruturado (TutorResponseSchema)
  → retorna { message, sources, confidence, disclaimer, mode }
```

---

## Banco de Dados

- **Supabase PostgreSQL 15** — schema principal + `legal_articles` (ETL concluído: 18.779 registros)
- **Prisma 5** — ORM com type-safe queries e migrations
- **Tabelas ETL (já existentes, fora do Prisma):** `legal_articles`, `legal_document`, `ingestion_run`, `source_audit`
- **pgvector** — coluna `embedding VECTOR(1536)` já no schema de `legal_articles` (NULL no MVP; v1.1 popula com OpenAI embeddings)

---

## Redis (Upstash)

Três namespaces:

| Chave | TTL | Uso |
|-------|-----|-----|
| `tutor:session:{uuid}` | 4h | Histórico das últimas 8 mensagens |
| `tutor:rate:{userId}` | 24h | Contador de mensagens diárias |
| `tutor:tokens:{uuid}` | 4h | Budget de tokens por sessão (20k max) |

---

## Módulo Lexia — LLM Híbrido

| LLM | % queries | Quando usar |
|-----|-----------|-------------|
| Sabiá-4 (Maritaca AI) | ~75% | Modo direct, reading, queries simples |
| Claude Sonnet 4.6 | ~25% | Modo simulado, complexity=high |

Ambos implementam `LLMAdapter` — troca de modelo sem refatoração do loop agêntico.

---

## Decisões Pendentes (bloqueiam deploy parcial)

| Item | Impacto | Status |
|------|---------|--------|
| Pricing model | Bloqueia T22/T23 (PRO) e RevenueCat | Pendente |
| OneSignal App ID | Bloqueia T21 (notificações push) | Aguardando setup |
| Banco de questões | Bloqueia M5 (simulados com conteúdo real) | Time externo |
| Embeddings pgvector | v1.1 busca semântica | Pendente após MVP |

---

## Roadmap de Implementação

### Sprint 1 — Core (sem questões)
- [ ] `npm install` + `prisma migrate dev`
- [ ] Módulos: auth, onboarding, dashboard, users
- [ ] Testes manuais com Supabase dev

### Sprint 2 — Conteúdo
- [ ] Módulo manual (topics + search no corpus)
- [ ] Módulo anotações

### Sprint 3 — Lexia
- [ ] Configurar API keys Anthropic + Maritaca
- [ ] Testar loop agêntico com 50 artigos reais
- [ ] Rate limiting + session TTL

### Sprint 4 — Monetização + Simulados
- [ ] RevenueCat webhook (após pricing decidido)
- [ ] Módulo simulados (após banco de questões pronto)
- [ ] OneSignal push notifications
