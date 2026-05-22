# LCF Backend — API Contract

**Base URL:** `https://api.lcf.app` (prod) | `http://localhost:3000` (dev)  
**Auth:** Bearer JWT (Supabase JWT) em todos os endpoints exceto `/health` e `/subscriptions/webhook/revenuecat`  
**Formato:** JSON. Erros no formato `{ "error": "code", "message": "..." }`

---

## Health

| Method | Route | Auth | Descrição |
|--------|-------|------|-----------|
| GET | `/health` | — | Status da API |

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

---

## Manual (M3 — T09-T13)

| Method | Route | Auth | Query Params | Descrição |
|--------|-------|------|-------------|-----------|
| GET | `/manual/topics` | JWT | `lawCode?` | Lista tópicos (todos ou por diploma) |
| GET | `/manual/topics/:id` | JWT | — | Conteúdo completo do tópico |
| GET | `/manual/search` | JWT | `q`, `lawCode?` | Busca BM25 no corpus legal_articles |
| GET | `/manual/articles` | JWT | `lawCode`, `article`, `paragraph?`, `inciso?` | Artigo exato do corpus |

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
- Free: 20 msgs/dia → HTTP 429 com mensagem de upgrade
- PRO: 200 msgs/dia

---

## Simulados (M5 — T15-T18)

| Method | Route | Auth | Descrição |
|--------|-------|------|-----------|
| GET | `/simulados/questions` | JWT | Banco de questões. Query: `subject?`, `lawCode?`, `difficulty?`, `limit?` |
| POST | `/simulados/start` | JWT | Inicia simulado. Body: `{ mode, subject?, totalQ }` |
| POST | `/simulados/:id/answer` | JWT | Responde questão. Body: `{ questionId, answer, timeSpentSecs? }` |
| POST | `/simulados/:id/complete` | JWT | Finaliza simulado |
| GET | `/simulados/:id/results` | JWT | Resultado completo com questões |
| GET | `/simulados/history` | JWT | Últimas 20 tentativas completadas |

### Modos: `custom`, `oab_phase1`, `oab_phase2`, `weak_areas`

---

## Anotações (M6 — T12)

| Method | Route | Auth | Descrição |
|--------|-------|------|-----------|
| GET | `/annotations` | JWT | Lista anotações do usuário. Query: `topicId?` |
| POST | `/annotations` | JWT | Cria anotação. Body: `{ topicId?, lawCode?, articleRef?, content, highlight? }` |
| PUT | `/annotations/:id` | JWT | Atualiza conteúdo. Body: `{ content }` |
| DELETE | `/annotations/:id` | JWT | Remove anotação |

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
