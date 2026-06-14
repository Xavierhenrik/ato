# LCF Backend — API Contract

**Base URL:** `https://api.lcf.app` (prod) | `http://localhost:3000` (dev)  
**Auth:** Bearer JWT (Supabase JWT) em todos os endpoints exceto `/health` e `/subscriptions/webhook/revenuecat`  
**Formato:** JSON. Erros no formato `{ "error": "code", "message": "..." }`

---

## Health

| Method | Route | Auth | Descrição |
|--------|-------|------|-----------|
| GET | `/health` | — | Status da API com conectividade DB e Redis |

### GET /health
```json
// Response 200 (sempre 200 — nunca 500)
{ "status": "ok" | "degraded", "ts": "2026-05-24T12:00:00.000Z", "db": "ok" | "error", "redis": "ok" | "error" }
```

---

## Auth (M1 — T02)

| Method | Route | Auth | Descrição |
|--------|-------|------|-----------|
| POST | `/auth/verify` | JWT | Verifica token Supabase; cria usuário LCF se novo |
| GET | `/auth/me` | JWT | Retorna usuário + perfil + assinatura |
| DELETE | `/auth/me` | JWT | Exclui conta (LGPD cascade) |

---

## Onboarding (M1 — T03-T06)

> **Decisão de design (Maio 2026):** onboarding é uma tela única com 2 perguntas. Fluxo de steps removido. Quiz Diagnóstico é universal (todos os perfis) com dois caminhos: `oab` e `graduation`.

| Method | Route | Auth | Descrição |
|--------|-------|------|-----------|
| POST | `/onboarding/complete` | JWT | Finaliza onboarding, gera StudyPlan. Body obrigatório. |
| POST | `/onboarding/diagnostic/complete` | JWT | Marca Quiz Diagnóstico como concluído |
| POST | `/onboarding/diagnostic/dismiss` | JWT | Usuário dispensa conscientemente o quiz |

### POST /onboarding/complete
```json
// Body
{ "academicPhase": "graduation_start" | "graduation_mid" | "graduation_end" | "oab_prep",
  "dailyStudyMins": 30 | 60 | 120 | 180 }

// Response 200
{ "done": true, "flow": "graduation" | "oab", "nivelamentoPendente": true,
  "nivelamentoPath": "graduation" | "oab",
  "studyPlan": { "id": "uuid", "durationDays": 90|120|180, "dailyMins": 30|60|120|180 } }
```

### durationDays por fase
| academicPhase | durationDays |
|---------------|-------------|
| graduation_start | 180 |
| graduation_mid | 120 |
| graduation_end | 90 |
| oab_prep | 90 |

---

## Dashboard (M2 — T07-T08)

| Method | Route | Auth | Descrição |
|--------|-------|------|-----------|
| GET | `/dashboard` | JWT | Home: streak, progresso, tentativas recentes |
| GET | `/dashboard/streak` | JWT | Detalhes do streak atual e maior |
| POST | `/dashboard/study-session` | JWT | Registra sessão de estudo (atualiza streak) |
| GET | `/dashboard/revision-cards` | JWT | Cards de revisão para a sessão atual |
| GET | `/dashboard/performance` | JWT | Desempenho geral e por matéria |

### GET /dashboard/revision-cards
```json
// Response 200
{
  "cards": [
    {
      "subject": "Civil",
      "lawCode": "CC",
      "errorRate": 0.72,
      "totalAnswered": 18,
      "priority": "high",
      "topTopics": [
        { "id": "uuid", "title": "Responsabilidade Civil Subjetiva", "errors": 5 },
        { "id": "uuid", "title": "Vícios do Negócio Jurídico", "errors": 3 }
      ]
    }
  ]
}
// topTopics: até 3 tópicos priorizados para revisão. Duas camadas:
//   Camada 1 (padrão): top 3 por contagem de erros nos últimos 14 dias (questões type:review com topicId).
//   Camada 2 (PRO, quando ativo): ranking Sonnet dos últimos 60 dias — substituído quando StudyPlan.analyzedAt < 7 dias.
//                                  Trigger: ao completar simulado (POST /simulados/:id/complete) com plano PRO.
//   Vazio se o usuário só tiver erros em questões OAB (topicId null) e nenhuma análise Sonnet persistida.
// errors em Camada 2: contagem real da janela de 14 dias (0 se tópico não foi errado no período recente).
```

### GET /dashboard/performance
```json
// Response 200
{ "bySubject": { "Constitucional": 0.75, "Penal": 0.60 }, "overall": 0.68 }
```

---

## Manual (M3 — T09-T13)

| Method | Route | Auth | Query Params | Descrição |
|--------|-------|------|-------------|-----------|
| GET | `/manual/topics` | JWT | `lawCode?` | Lista tópicos (todos ou por diploma) |
| GET | `/manual/topics/:id` | JWT | — | Conteúdo completo do tópico |
| POST | `/manual/topics/:id/read` | JWT | — | Marca tópico como lido (idempotente) |
| GET | `/manual/search` | JWT | `q`, `lawCode?` | Busca BM25 no corpus legal_articles |
| GET | `/manual/articles` | JWT | `lawCode`, `article`, `paragraph?`, `inciso?` | Artigo exato do corpus |

### POST /manual/topics/:id/read
```json
// Response 200
{ "topicId": "uuid", "readAt": "2026-05-24T12:00:00.000Z" }
```

---

## Tutor IA (M4 — T14)

| Method | Route | Auth | Descrição |
|--------|-------|------|-----------|
| POST | `/tutor/session/new` | JWT | Cria sessão, retorna `session_id` (UUID) |
| POST | `/tutor/message` | JWT | Envia mensagem. Body abaixo. |
| GET | `/tutor/session/:id` | JWT | Histórico ativo (últimas 8 msgs do Redis) |
| DELETE | `/tutor/session/:id` | JWT | Encerra sessão, limpa Redis |

### POST /tutor/message body:
```json
{
  "session_id": "uuid",
  "message": "string",
  "mode": "reading | simulado | direct",
  "context": {
    "topic_id": "uuid",
    "topic_title": "string",
    "topic_content": "string",
    "question_bundle": {
      "statement": "string",
      "options": { "A": "...", "B": "...", "C": "...", "D": "..." },
      "correct_answer": "A",
      "student_answer": "C",
      "subject": "Constitucional",
      "board": "OAB",
      "year": 2024
    }
  }
}
```

### Rate limits:
- Free: 20 msgs/dia → HTTP 429 (Redis, rate limit de negócio)
- PRO: 200 msgs/dia
- Infra: 60 req/min por usuário (independente do plano)

---

## Simulados (M5 — T15-T18)

| Method | Route | Auth | Descrição |
|--------|-------|------|-----------|
| GET | `/simulados/questions` | JWT | Banco de questões. Query: `subject?`, `lawCode?`, `difficulty?`, `limit?` |
| POST | `/simulados/start` | JWT | Inicia simulado. Body: `{ mode, subject?, subjects?, totalQ, excludeAnswered? }` |
| POST | `/simulados/:id/answer` | JWT | Responde questão. Body: `{ questionId, answer, timeSpentSecs? }` |
| POST | `/simulados/:id/complete` | JWT | Finaliza simulado |
| POST | `/simulados/:id/abandon` | JWT | Abandona simulado em andamento |
| GET | `/simulados/:id/results` | JWT | Resultado completo com questões |
| GET | `/simulados/history` | JWT | Últimas 20 tentativas completadas |
| GET | `/simulados/in-progress` | JWT | Tentativa em andamento (204 se não houver) |

### POST /simulados/start
```json
// Body
{ "mode": "custom" | "oab_phase1" | "oab_phase2" | "weak_areas",
  "subject": "Constitucional",
  "subjects": ["Constitucional", "Civil"],
  "totalQ": 30,
  "excludeAnswered": true }

// Response 200
{ "id": "uuid", "mode": "custom", "status": "in_progress", "totalQ": 30, "totalQuestions": 30,
  "subjects": ["Constitucional"], "startedAt": "...",
  "questions": [{ "id": "uuid", "order": 1, "enunciado": "...", "opcoes": { "A": "...", "B": "...", "C": "...", "D": "..." }, "subject": "...", "difficulty": "medium" }] }

// Errors: 400 Free>20q, 403 PRO_REQUIRED (weak_areas/excludeAnswered), 409 SIMULADO_IN_PROGRESS
```

### POST /simulados/:id/answer
```json
// Body
{ "questionId": "uuid", "answer": "A" | "B" | "C" | "D", "timeSpentSecs": 45 }

// Response 200
{ "correct": true, "correctAnswer": "A", "explanation": "..." }
// Free: explanation omitido
```

### POST /simulados/:id/abandon
```json
// Response 200
{ "id": "uuid", "status": "abandoned" }
```

### GET /simulados/in-progress
```json
// Response 200: mesmo schema de POST /simulados/start
// Response 204: nenhum simulado em andamento
```

### GET /simulados/:id/results
```json
// Response 200
{ "id": "uuid", "score": 75.0, "total": 30, "correct": 22, "wrong": 8,
  "completedAt": "...", "bySubject": { "Constitucional": 80.0 },
  "questions": [{ "id": "uuid", "order": 1, "enunciado": "...", "opcoes": {...},
    "correctAnswer": "A", "userAnswer": "B", "isCorrect": false, "subject": "...",
    "explanation": "..." }] }
// Free: explanation omitido em cada questão
```

### Modos: `custom`, `oab_phase1`, `oab_phase2`, `weak_areas`
### PRO-only: `mode: "weak_areas"`, `excludeAnswered: true`, campo `explanation` nos resultados

### Rate limits (infra):
- `POST /simulados/start`: 5 req/min por usuário

---

## Anotações (M6 — T12)

| Method | Route | Auth | Descrição |
|--------|-------|------|-----------|
| GET | `/annotations` | JWT | Lista anotações. Query: `topicId?`, `subject?`, `tag?`, `q?` |
| POST | `/annotations` | JWT | Cria anotação |
| PUT | `/annotations/:id` | JWT | Atualiza anotação |
| DELETE | `/annotations/:id` | JWT | Remove anotação |

### POST /annotations
```json
// Body
{ "topicId": "uuid", "lawCode": "CC", "articleRef": "Art. 186",
  "content": "...", "highlight": "...", "title": "...",
  "tags": ["prova", "importante"], "subject": "Civil" }

// Response 201
{ "id": "uuid", "userId": "...", "content": "...", "title": "...", "tags": [...], "subject": "...", "createdAt": "..." }
```

### GET /annotations query params:
- `topicId`: filtra por tópico do Manual
- `subject`: filtra por matéria (ex: `"Constitucional"`)
- `tag`: filtra por tag no array JSON
- `q`: busca full-text em `title` e `content`

### Rate limits (infra):
- `POST /annotations`: 30 req/min por usuário

---

## Users / Perfil (T20-T21)

| Method | Route | Auth | Descrição |
|--------|-------|------|-----------|
| GET | `/users/profile` | JWT | Perfil completo |
| PUT | `/users/profile` | JWT | Atualiza perfil. Body: `{ name?, avatarUrl? }` |
| PUT | `/users/notifications` | JWT | Notificações. Body: `{ notifEnabled, notifTime?, oneSignalPlayerId? }` |

---

## Assinaturas (T22-T23)

| Method | Route | Auth | Descrição |
|--------|-------|------|-----------|
| GET | `/subscriptions/status` | JWT | Plano atual: `{ plan, status, isActive, expiresAt }` |
| POST | `/subscriptions/webhook/revenuecat` | Header secret | RevenueCat webhook (INITIAL_PURCHASE, RENEWAL, CANCELLATION, EXPIRATION) |

---

## Códigos de Status

| Code | Significado |
|------|-------------|
| 200 | OK |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request (validação Zod) |
| 401 | Unauthorized (JWT inválido) |
| 403 | Forbidden (PRO required) |
| 404 | Not Found |
| 409 | Conflict |
| 429 | Rate Limited (Tutor IA) |
| 500 | Internal Server Error |
