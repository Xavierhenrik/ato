# Sessão 2026-05-27 — Contract Fixes Flutter↔Backend

## O que foi feito

Corrigidos 6 bugs/desalinhamentos entre frontend Flutter e backend Node.js identificados em auditoria.

## Arquivos modificados

### Flutter
- `lib/features/simulados/data/simulado_repository.dart` — Fix 1 + Fix 2
- `lib/features/simulados/data/models/simulado_models.dart` — Fix 6
- `lib/features/simulados/presentation/screens/simulado_config_screen.dart` — Fix 4
- `lib/features/tutor/data/tutor_repository.dart` — Fix 5

### Backend
- `src/modules/users/users.service.ts` — Fix 3a
- `src/modules/users/users.controller.ts` — Fix 3b

## Critérios de aceite cumpridos

- [x] **Fix 1 (🔴)** — `getHistory()`: `_dio.get<dynamic>` + `resp.data as List<dynamic>?` — elimina TypeError crash
- [x] **Fix 2 (🔴)** — `getInProgress()`: `_dio.get<dynamic>` + `statusCode == 204 || data == null` — elimina crash em 204
- [x] **Fix 3a (🔴)** — `getProfile()` retorna `email` (via User) e `plan` (via Subscription) com Promise.all
- [x] **Fix 3b (🟡)** — `updateProfile()` aceita e persiste `dailyStudyMins`; schema Zod atualizado
- [x] **Fix 3c (✅)** — `perfil_models.dart` já tinha fallbacks corretos para `email` e `plan` — sem mudanças
- [x] **Fix 4 (🟡)** — `_quantities`: `100` substituído por `80` (limite real do backend)
- [x] **Fix 5 (🟡)** — `sendMessage()` aceita `mode` como named param com default `'direct'`; sem quebra no provider caller
- [x] **Fix 6 (⚪)** — `SimuladoHistoryItem` agora lê e expõe `correctAnswers` do backend
- [x] `npx tsc --noEmit` → zero erros
- [x] `flutter analyze` → zero issues
- [x] build_runner não necessário (nenhum provider/schema/JsonSerializable novo)

## Pendências / Próximos passos

- Nenhuma pendência crítica aberta nesta sessão
- `SimuladoHistoryItem.correctAnswers` disponível para uso na tela de histórico quando UX for atualizada

## Decisões tomadas

- Fix 3c não requereu mudanças — `perfil_models.dart` já estava preparado para os campos que agora o backend envia
- Fix 5 mantém compatibilidade total com o `tutor_provider.dart` existente (parâmetro opcional com default)
