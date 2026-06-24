---
domain: backend
updated: 2026-06-24
owner: lex-backend
---

# Memória de Backend — LEX

> Node.js 20 + TS strict, Fastify 4, Prisma 5, Supabase PG, Upstash Redis. Monolito modular (2 devs).
> Convenções obrigatórias: `back/CLAUDE.md` (fonte da verdade). Status detalhado: `.claude/PROJECT_STATE.md`.

---

## Padrão de módulo

`routes.ts → controller.ts → service.ts`. Lógica de negócio só no service; query nunca no controller.

| Convenção | Regra |
|-----------|-------|
| Erros | factory `Errors.*` — nunca `new Error()` nem `throw {statusCode}` |
| Validação | Zod em TODO input (body, query, params); texto com `max` |
| Auth | `requireAuth` / `requirePro` no preHandler; `currentUser` no padrão |
| `legal_articles` | fora do Prisma → `$queryRaw` com params **bindados** (nunca interpolar) |
| Listas | array direto, sem `{data,total}`, sem paginação no MVP |
| Log | `req.log` / `app.log`, nunca `console.log` |

## Status dos módulos (todos ✅ Completos)

Auth · Tutor IA (M4) · Subscriptions · Onboarding (M1) · Dashboard (M2) · Manual (M3) ·
Anotações (M6) · Users · Simulados (M5) · Push Notifications (graceful degradation, credenciais pendentes) ·
Histórico Tutor (M4.1 — migration aplicada em live).

## Redis — namespaces

`tutor:session:{uuid}` 4h · `tutor:rate:{userId}` 24h (Free 20/PRO 200) · `tutor:tokens:{uuid}` 4h (20k) ·
`tutor:session:owner:{sessionId}` 4h (ownership/IDOR) · `simulado:daily:{userId}` 24h (Free max 15).

## Dados em banco

- `legal_articles`: 18.779 artigos (9 diplomas) — `$queryRaw`.
- `topics`: 1.883 com resumos validados (≥7/10).
- Questões: 2.210 OAB reais (`type:simulado`) + 5.791 review ativas (`type:review`).
- Models Prisma: User, Profile, StudyPlan, Subscription, Topic, TutorSession, TutorMessage, Question, SimuladoAttempt, SimuladoQuestion, Annotation, UserQuestionAnswered.

## Decisões de API recentes

- Rate limits granulares por rota: `/simulados/start` 5/min, `/annotations` 30/min, `/tutor/message` 60/min.
- Health check sempre 200 (`degraded` em falha) — evita restart loop Railway.
- `GET /simulados/in-progress` → 204 sem corpo quando vazio.
- `GET /simulados/history` → array direto.
- Histórico Tutor: persistência write-through (`persistTurn`/turno; Free vê 7 dias, PRO tudo; conversas antigas read-only).

## Validação obrigatória

```
cd back && npx tsc --noEmit && npm run lint
```
Mexeu em schema → `npm run db:generate` (+ `db:migrate:staging` quando aplicável). Staging antes de live.

Ver também: [[infra.md]] · [[llm.md]] · [[security.md]]
