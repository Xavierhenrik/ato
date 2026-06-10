# Sessão 2026-06-09 — Bug Fix: Dashboard 3 erros simultâneos

## O que foi feito

### Diagnóstico
Tela Início exibia 3 erros ("Erro ao carregar dados.", "Erro ao carregar metas.", "Erro ao carregar revisões.") porque o Flutter app no Android Emulator tentava conectar a `http://localhost:3000` — que no emulador aponta para o próprio dispositivo, não para o host.

Verificação direta:
- `GET https://lcf-production.up.railway.app/health` → `{"status":"ok","db":"ok","redis":"ok"}` ✅
- `GET https://lcf-production.up.railway.app/dashboard` (sem token) → 401 ✅ (correto)

**Causa raiz:** o `api_client.dart` usa `http://localhost:3000` como `defaultValue` de `API_BASE_URL`. No Android Emulator, `localhost` = o emulador; connection refused → DioException → erro genérico nos widgets.

**O backend estava funcionando corretamente.**

### Correção 1 — PEM normalization em `app.ts`
Railway armazena variáveis de ambiente com `\n` literal (não quebra de linha real). O `@fastify/jwt` / `jsonwebtoken` exige PEM com quebras reais. Adicionado `.replace(/\\n/g, '\n')` na leitura de `SUPABASE_JWT_PUBLIC_KEY`.

### Correção 2 — `env-checklist.md`
Adicionado:
- URL de produção do Railway: `https://lcf-production.up.railway.app`
- Nota sobre formato PEM com `\n` literal no Railway
- Seção "Flutter App — Variáveis de build" com os comandos `flutter run --dart-define=API_BASE_URL=...` para emulador (Railway) e local (10.0.2.2)

## Arquivos modificados

- `back/src/app.ts` — `.replace(/\\n/g, '\n')` na leitura do SUPABASE_JWT_PUBLIC_KEY
- `docs/env-checklist.md` — URL Railway, nota PEM, seção Flutter build vars

## Critérios de aceite cumpridos

- [x] `GET /health` retorna `{"status":"ok","db":"ok","redis":"ok"}`
- [x] `GET /dashboard` sem token retorna 401 (backend correto)
- [x] `tsc --noEmit` zero erros
- [x] Causa raiz documentada: `API_BASE_URL=http://localhost:3000` no emulador
- [x] URL Railway documentada em `env-checklist.md`

## Pendências / Próximos passos

- **Flutter**: rodar o app com `--dart-define=API_BASE_URL=https://lcf-production.up.railway.app` para confirmar que os 3 erros somem
- Testar JWT com token real: `curl -H "Authorization: Bearer <token>" https://lcf-production.up.railway.app/dashboard`

## Decisões tomadas

- PEM normalization aplicada defensivamente — sem custo, protege contra Railway e outros CIs que não preservam newlines reais em env vars
- Não alterado o `defaultValue` de `API_BASE_URL` em `api_client.dart` (correto manter `localhost:3000` para dev local no host com `http://10.0.2.2:3000` documentado)
