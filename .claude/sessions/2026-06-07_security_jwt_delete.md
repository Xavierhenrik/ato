# Sessão 2026-06-07 — Security: JWT + Deleção de Conta

## O que foi feito

### Problema 1 — JWT com env var errada (undefined behavior)
`app.ts` registrava `@fastify/jwt` com `secret: { public: process.env.SUPABASE_JWT_PUBLIC_KEY! }`.
Supabase usa HS256 simétrico — a chave pública assimétrica não existe no projeto.
Se a variável estivesse ausente, `jwtVerify()` verificava tokens contra `undefined`, causando comportamento imprevisível.

**Correção:** `secret: process.env.SUPABASE_JWT_SECRET!` (já presente no `.env.example`).

### Problema 2 — Recriação de conta após DELETE /auth/me (violação LGPD)
`AuthService.deleteAccount` deletava o user do banco sem invalidar a sessão no Supabase.
O `requireAuth` tem auto-provisioning: se `findUnique` retorna null, cria um novo user.
Resultado: usuário que pediu exclusão tinha a conta recriada automaticamente na próxima request com o JWT ainda válido.

**Correção:**
- `supabaseAdmin.auth.admin.deleteUser(supabaseId)` chamado **antes** de `db.user.delete`
- `deleteAccount` agora recebe `supabaseId` além de `userId`
- Controller atualizado para extrair `supabaseId` de `currentUser`
- `SUPABASE_SERVICE_ROLE_KEY` adicionado ao `.env.example` e `docs/env-checklist.md`

## Arquivos modificados

- `back/src/app.ts` — `secret: { public: SUPABASE_JWT_PUBLIC_KEY }` → `secret: SUPABASE_JWT_SECRET`
- `back/src/modules/auth/auth.service.ts` — supabaseAdmin criado, `deleteAccount(userId, supabaseId)`, invalida sessão Supabase primeiro
- `back/src/modules/auth/auth.controller.ts` — extrai `supabaseId` de `currentUser`, passa para service
- `back/.env.example` — `SUPABASE_SERVICE_ROLE_KEY` adicionado
- `docs/env-checklist.md` — `SUPABASE_SERVICE_ROLE_KEY` adicionado à seção Supabase Auth

## Critérios de aceite cumpridos

- [x] `SUPABASE_JWT_PUBLIC_KEY` removido do código
- [x] `@fastify/jwt` usando `secret: process.env.SUPABASE_JWT_SECRET!`
- [x] `SUPABASE_SERVICE_ROLE_KEY` no `.env.example` e no checklist
- [x] `supabaseAdmin.auth.admin.deleteUser` chamado antes do `db.user.delete`
- [x] Nenhum arquivo de teste ou seed modificado

## Pendências / Próximos passos

- Adicionar `SUPABASE_SERVICE_ROLE_KEY` nas variáveis do Railway (produção)
- Testar manualmente os critérios de aceite descritos no prompt de segurança:
  1. `GET /auth/me` com JWT válido → 200
  2. `GET /auth/me` com JWT inválido → 401
  3. `DELETE /auth/me` → 204; subsequente `GET /auth/me` com mesmo JWT → 401
  4. Verificar Supabase Dashboard: user removido de Auth Users
  5. Verificar banco: user deletado (SELECT * FROM "User" WHERE "supabaseId" = '...')

## Decisões tomadas

- `supabaseAdmin` criado como singleton no módulo `auth.service.ts` (não em shared/) porque é o único módulo que precisa de admin operations no MVP
- Ordem de operações: Supabase primeiro, banco depois — se o banco falhar, o Supabase já invalidou; retry do usuário receberá 401. Inverso seria pior: banco deletado mas JWT ainda válido.
