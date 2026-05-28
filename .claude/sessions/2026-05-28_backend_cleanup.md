# Sessão 2026-05-28 — Backend Cleanup

## O que foi feito

- Removido dead code em `dismissQuiz`: if/else com dois branches idênticos colapsado em uma única chamada `db.profile.update(...)`. Comentário enganoso sobre idempotência também removido.
- Deletado `back/nixpacks.toml` (abordagem rejeitada pelo usuário).
- Verificado `users.service.ts`: `updateProfile` já aceita e persiste `dailyStudyMins` corretamente (Zod min:15 max:480).
- `npx tsc --noEmit` — zero erros.

## Arquivos modificados

- `back/src/modules/onboarding/onboarding.service.ts` — colapsado if/else morto em `dismissQuiz`
- `back/nixpacks.toml` — deletado

## Critérios de aceite cumpridos

- [x] `dismissQuiz` usa uma única chamada `db.profile.update`
- [x] `nixpacks.toml` removido
- [x] `updateProfile` aceita `dailyStudyMins` — confirmado já correto
- [x] `tsc --noEmit` — zero erros TypeScript

## Pendências / Próximos passos

- Aguardando Agent 1 (NotificationsService) para commit conjunto.

## Decisões tomadas

- O comentário sobre idempotência em `dismissQuiz` era enganoso: o código nunca tocou `nivelamentoConcluido` em nenhum dos dois branches. A intenção original (não sobrescrever `nivelamentoConcluido`) já estava garantida porque `nivelamentoConcluido` nunca estava nos dados do update.
