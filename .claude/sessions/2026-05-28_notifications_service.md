# Sessão 2026-05-28 — Sprint 3 · Push Notifications

## O que foi feito

- Implementado `NotificationsService` (`back/src/shared/notifications.service.ts`) com graceful degradation: sem `ONESIGNAL_APP_ID`, `sendPush` retorna `{ success: false }` sem lançar exceção.
- `validatePlayer(playerId)` verifica o player ID via `GET /api/v1/players/:id` da OneSignal antes de salvar.
- `updateNotifications()` em `users.service.ts` agora valida `oneSignalPlayerId` via `validatePlayer` se o campo estiver presente.
- Novo método `updateNotificationsPlayer(userId, oneSignalPlayerId)` — sempre valida e persiste.
- Rota `PUT /users/notifications/player` adicionada com Zod UUID validation + `requireAuth`.
- `npx tsc --noEmit` — zero erros.

## Arquivos modificados

- `back/src/shared/notifications.service.ts` — novo arquivo (NotificationsService + singleton)
- `back/src/modules/users/users.service.ts` — importa notificationsService, adiciona validatePlayer + updateNotificationsPlayer
- `back/src/modules/users/users.controller.ts` — adiciona UpdateNotifPlayerSchema e handler updateNotificationsPlayer
- `back/src/modules/users/users.routes.ts` — adiciona PUT /notifications/player

## Decisões tomadas

- Rota `PUT /users/notifications/player` (não `/notifications`) para não quebrar o contrato Flutter da rota genérica de preferências.
- Sem `ONESIGNAL_APP_ID`: `validatePlayer` retorna false → `updateNotificationsPlayer` lança `400 BAD_REQUEST`. Intencional — player IDs não são persistidos até as credenciais serem configuradas.
- `https` nativo usado (sem fetch, sem dependências novas) — `tsconfig.json` usa `lib: ["ES2022"]` sem DOM, então `fetch` não é tipado.
- Logging via `console.warn/error` com JSON estruturado (sem contexto de request no shared service).
