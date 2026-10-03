# ATO — API Contract (Frontend Reference)

**Base URL:** `https://api.lcf.app` (prod) | `http://localhost:3000` (dev)
**Auth:** Bearer JWT (Supabase) em todos os endpoints exceto `/health` e `/subscriptions/webhook/revenuecat`
**Erros:** `{ "error": "CODE", "message": "..." }`

---

## Auth

| Método | Rota | Body | Response 200 |
|--------|------|------|--------------|
| `POST` | `/auth/verify` | — | `{ user, profile, subscription }` |
| `GET` | `/auth/me` | — | `{ user, profile, subscription }` |
| `DELETE` | `/auth/me` | — | `{ deleted: true }` |

**Fluxo login:** Supabase Auth → `POST /auth/verify` (cria usuário ATO se novo)

---

## Onboarding (M1)

| Método | Rota | Body | Response 200 |
|--------|------|------|--------------|
| `POST` | `/onboarding/complete` | `{ academicPhase, dailyStudyMins }` | `{ done, flow, nivelamentoPendente, studyPlan }` |
| `POST` | `/onboarding/diagnostic/complete` | — | `{ done: true }` |
| `POST` | `/onboarding/diagnostic/dismiss` | — | `{ done: true }` |

`academicPhase`: `"graduation_start" | "graduation_mid" | "graduation_end" | "oab_prep"`
`dailyStudyMins`: `30 | 60 | 120 | 180`

---

## Dashboard (M2)

| Método | Rota | Response 200 |
|--------|------|--------------|
| `GET` | `/dashboard` | `{ name, plan, oabMode, nivelamentoPendente, streak, dailyProgress }` |
| `GET` | `/dashboard/revision-cards` | `{ cards: [...] }` |
| `GET` | `/dashboard/performance` | `{ bySubject: [{ subject, total, correct, accuracy }] }` |

---

## Manual (M3)

| Método | Rota | Body/Query | Response 200 |
|--------|------|-----------|--------------|
| `GET` | `/manual/topics` | `?area=&subject=&page=&limit=` | `{ topics, total, page }` |
| `GET` | `/manual/topics/:id` | — | `{ id, title, content, articles, isRead }` |
| `POST` | `/manual/topics/:id/read` | — | `{ done: true }` |
| `GET` | `/manual/search` | `?q=` | `{ results: [{ id, title, source, excerpt }] }` |

---

## Tutor IA (M4)

| Método | Rota | Body | Response 200 |
|--------|------|------|--------------|
| `POST` | `/tutor/message` | `{ message, sessionId? }` | `{ reply, sessionId, chips, autoSavedAnnotationId? }` |
| `DELETE` | `/tutor/session/:id` | — | `{ done: true }` |

`chips`: sempre array de 4 strings (sugestões de follow-up)
`autoSavedAnnotationId`: só presente para usuários PRO quando `confidence: "high"`

---

## Simulados (M5)

| Método | Rota | Body/Query | Response 200 |
|--------|------|-----------|--------------|
| `POST` | `/simulados/start` | `{ totalQ, subjects?, area? }` | `{ simuladoId, questions }` |
| `GET` | `/simulados/in-progress` | — | `{ simulado }` ou `null` |
| `POST` | `/simulados/:id/answer` | `{ questionId, answer }` | `{ correct, explanation? }` |
| `POST` | `/simulados/:id/abandon` | — | `{ done: true }` |
| `GET` | `/simulados/:id/results` | — | `{ score, total, bySubject, questions }` |

Free limits: `totalQ` máx 15; 429 ao exceder limite diário
PRO: `explanation` disponível em cada questão nos resultados

---

## Anotações (M6)

| Método | Rota | Body/Query | Response 200 |
|--------|------|-----------|--------------|
| `POST` | `/annotations` | `{ title, content, subject?, tags? }` | `{ id, ...annotation }` |
| `GET` | `/annotations` | `?subject=&tag=&q=` | `{ annotations: [...] }` |
| `GET` | `/annotations/:id` | — | `{ ...annotation }` |
| `PUT` | `/annotations/:id` | `{ title?, content?, subject?, tags? }` | `{ ...annotation }` |
| `DELETE` | `/annotations/:id` | — | `{ done: true }` |

---

## Users

| Método | Rota | Body | Response 200 |
|--------|------|------|--------------|
| `PUT` | `/users/profile` | `{ academicPhase?, dailyStudyMins?, name? }` | `{ ...profile }` |
| `GET` | `/users/profile` | — | `{ ...profile }` |

---

## Subscriptions

| Método | Rota | Uso |
|--------|------|-----|
| `POST` | `/subscriptions/webhook/revenuecat` | Webhook RevenueCat (não chamar do frontend) |

O plano é gerenciado via RevenueCat SDK no app — nunca chamar endpoints de subscription diretamente.
