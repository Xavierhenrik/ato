# Sessão 2026-05-16 — Sprint 3: Tutor IA (gaps PRO) + Subscriptions Hardening

## O que foi feito

### BLOCO 1 — M4 Tutor IA (gaps PRO)

1. **Chips sempre retornados**: `tutor.controller.ts` agora importa `FOLLOW_UP_CHIPS` e faz `reply.send({ ...response, chips: FOLLOW_UP_CHIPS })` após cada mensagem.

2. **Auto-save PRO**: `tutor.service.ts` — após `citationSvc.parse()`, se `isPro && confidence === "high"`, cria anotação com `title = primeiros 60 chars`, `content = response.message`, `subject = question_bundle.subject ?? topic_title`. Retorna `autoSavedAnnotationId` no response.

3. **Persistência de sessão no DELETE**: `session.service.ts` — novo método `persistToDB(sessionId, userId, mode)` que lê o histórico Redis, cria `TutorSession` com `endedAt` e `msgCount`, e cria os `TutorMessage[]`. O `deleteSession` no controller agora: extrai `mode` do query string (default `'direct'`), chama `persistToDB` antes de `clear`.

### BLOCO 2 — Subscriptions Hardening

1. **UNCANCELLATION** adicionado: `plan: 'pro'`, `status: 'active'`.
2. **EXPIRATION** corrigido: agora seta `plan: 'free'` (além de `status: 'expired'`) — downgrade efetivo.
3. **CANCELLATION** separado de EXPIRATION: apenas `status: 'cancelled'`, plan permanece `'pro'`.
4. **Log estruturado** no controller: `req.log.info({ event, userId }, 'RevenueCat webhook')` antes de processar.

---

## Arquivos modificados

| Arquivo | Mudança |
|---------|---------|
| `src/modules/tutor-ia/services/tutor.service.ts` | Auto-save PRO + tipo de retorno estendido com `autoSavedAnnotationId?` |
| `src/modules/tutor-ia/services/session.service.ts` | Novo método `persistToDB()` |
| `src/modules/tutor-ia/controllers/tutor.controller.ts` | `sendMessage` adiciona chips; `deleteSession` persiste antes de limpar |
| `src/modules/subscriptions/subscriptions.service.ts` | UNCANCELLATION; EXPIRATION com plan downgrade; CANCELLATION separado |
| `src/modules/subscriptions/subscriptions.controller.ts` | Log estruturado antes de processar webhook |

---

## Critérios de aceite cumpridos

- [x] `POST /tutor/message` sempre retorna `chips` com os 4 valores do `chips.config.ts`
- [x] Com usuário PRO e `confidence: "high"`, `autoSavedAnnotationId` é retornado e a anotação existe no DB
- [x] `DELETE /tutor/session/:id` cria registro em `TutorSession` com `endedAt` preenchido
- [x] `EXPIRATION` seta `plan: "free"` no DB
- [x] `CANCELLATION` mantém `plan: "pro"` (apenas muda status)
- [x] `UNCANCELLATION` reativa com `plan: "pro"` e `status: "active"`
- [x] Todo webhook logado com `event.type` e `app_user_id`

---

## Pendências / Próximos passos

- **Push Notifications (Sprint 3)**: bloqueado por `ONESIGNAL_APP_ID` + `ONESIGNAL_API_KEY` (aguardando setup de infra)
- **Sprint 4 — Hardening**: índices compostos em `SimuladoQuestion`, auditoria Zod, health check com connectivity, api-contract.md sync

---

## Decisões tomadas

| Decisão | Motivo |
|---------|--------|
| `mode` em `DELETE /tutor/session/:id` via query string (default `'direct'`) | Prisma schema exige mode; DELETE não deve ter body; query param é pragmático |
| `sources: undefined` em `TutorMessage` ao persistir | Histórico Redis não armazena sources parsed; null não é aceito pelo tipo Prisma Json? |
| Tipo de retorno de `chat()` estendido inline | Evita alterar `TutorResponseSchema` (validação de entrada) para um campo exclusivo de saída |
