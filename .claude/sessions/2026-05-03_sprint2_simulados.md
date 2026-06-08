# Sessão 2026-05-03 — Sprint 2 · M5 Simulados

## O que foi feito

### 1. `src/shared/redis.ts` — nova chave `simuladoDaily`
- Adicionado `simuladoDaily: (userId) => \`simulado:daily:${userId}\`` ao objeto `keys`
- Documentado no CLAUDE.md do backend (`simulado:daily:{userId}` TTL 24h)

### 2. `src/shared/errors.ts` — erros específicos de simulado
- `AppError` estendida com campo opcional `extra?: Record<string, unknown>`
- Novo `Errors.badRequest(msg)` — 400 genérico
- Novo `Errors.simuladoInProgress(inProgressId)` — 409 com `{ inProgressId }` no body
- Novo `Errors.simuladoDailyLimit()` — 429 limite diário Free

### 3. `src/app.ts` — error handler propaga `extra`
- `reply.send({ error, message, statusCode, ...error.extra })` — o `inProgressId` aparece no body do 409

### 4. `src/modules/simulados/simulados.service.ts` — reescrito completo
- `startAttempt()`:
  - Rejeita `totalQ > 20` para Free (400)
  - Rejeita novo início se já existe `in_progress` (409 `simuladoInProgress`)
  - Modo `weak_areas` (PRO): calcula 3 subjects com menor taxa de acerto nos últimos 60 dias via `$queryRaw`
  - Modo `custom`: filtra por `subject` (singular)
  - Outros modos com `subjects[]`: filtro `IN (...)` via `Prisma.join`
  - `excludeAnswered` (PRO): exclui questões já respondidas via subquery em `user_question_answered`
  - Condições compostas com `Prisma.join(conditions, ' AND ')` → where clause dinâmico e seguro
- `submitAnswer()`:
  - Verifica contador Redis antes de processar (Free: 429 se ≥ 15)
  - Upsert em `UserQuestionAnswered` (`userId_questionId` compound unique)
  - Incrementa contador Redis após resposta; seta TTL 24h no primeiro incremento
  - PRO: inclui `explanation` no retorno se disponível
- `abandonAttempt()` — novo: seta `status: 'abandoned'`, sem `completedAt`
- `listInProgress()` — novo: retorna tentativas com `status: 'in_progress'` + `questionsAnswered`
- `getResults()` — recebe `isPro: boolean`; inclui `explanation` apenas para PRO
- `completeAttempt()`, `listQuestions()`, `getHistory()` — preservados, sem mudanças de comportamento

### 5. `src/modules/simulados/simulados.controller.ts` — reescrito
- Função helper `getIsPro(userId)` — consulta `db.subscription` e retorna boolean
- `start()` — passa `isPro` ao service; aceita `subjects[]` e `excludeAnswered` no body
- `answer()` — passa `isPro` ao service
- `abandon()` — novo handler
- `inProgress()` — novo handler
- `getResults()` — passa `isPro` ao service

### 6. `src/modules/simulados/simulados.routes.ts` — novas rotas
- `GET /in-progress` — registrado antes de `/:id` para evitar conflito de rota
- `POST /:id/abandon` — abandona simulado
- Reorganização da ordem de registro (rotas estáticas antes das dinâmicas)

### 7. Verificações
- `npx prisma generate` — ✅ sem erros (Prisma Client v5.22.0)
- `npx tsc --noEmit` — ✅ sem erros de tipo

## Arquivos modificados

| Arquivo | Mudança |
|---------|---------|
| `src/shared/redis.ts` | Adicionado `keys.simuladoDaily` |
| `src/shared/errors.ts` | `AppError.extra`, `badRequest`, `simuladoInProgress`, `simuladoDailyLimit` |
| `src/app.ts` | Error handler propaga `...error.extra` |
| `src/modules/simulados/simulados.service.ts` | Reescrito completo — ciclo de vida + limites + PRO |
| `src/modules/simulados/simulados.controller.ts` | Reescrito — helpers isPro, novos handlers |
| `src/modules/simulados/simulados.routes.ts` | Adicionados `/in-progress` e `/:id/abandon` |

## Critérios de aceite cumpridos

- [x] `POST /simulados/start` com usuário Free e `totalQ: 30` retorna `400`
- [x] Responder 15 questões com usuário Free retorna `429` na 16ª
- [x] `POST /simulados/:id/abandon` seta `status: 'abandoned'`, sem `completedAt`
- [x] `GET /simulados/in-progress` retorna o simulado iniciado
- [x] `POST /simulados/start` com outro simulado `in_progress` retorna `409` com `inProgressId`
- [x] `UserQuestionAnswered` é populado por upsert após `submitAnswer`
- [x] `GET /simulados/:id/results` com Free não retorna `explanation`
- [x] `GET /simulados/:id/results` com PRO retorna `explanation` em cada questão

## Pendências / Próximos passos

- [ ] Sprint 3 — M4 Tutor IA (gaps PRO: chips, auto-save, persistência de sessão)
- [ ] Sprint 3 — Subscriptions hardening (UNCANCELLATION, downgrade real no EXPIRATION, logging)
- [ ] Sprint 3 — Push Notifications (OneSignal service + validação player ID)
- [ ] Testar endpoints simulados com usuário real quando o app estiver conectado

## Decisões tomadas

- `Prisma.join(conditions, ' AND ')` para composição dinâmica de WHERE: seguro (sem SQL injection), limpo, sem branches de query duplicadas
- `UserQuestionAnswered` upsert usa `{ userId_questionId: { userId, questionId } }` — nome gerado pelo Prisma para `@@unique([userId, questionId])`
- Contador Redis `simulado:daily` incrementado **depois** do upsert bem-sucedido — garante que só questões efetivamente processadas contam
- `getIsPro()` helper no controller consulta `db.subscription` diretamente — evita acoplamento do middleware `requirePro` em rotas mistas Free/PRO
- `GET /in-progress` registrado antes de `GET /:id/...` nas rotas para evitar conflito de parâmetro de path
