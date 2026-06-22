# Sessão 2026-06-19 — Code Health Wave

## O que foi feito

### Backend
- `Errors.upstream(msg)` factory adicionada em `src/shared/errors.ts` (retorna HTTP 502)
- `new Error()` substituído por `Errors.upstream()` em `sabia.adapter.ts` e `sabiazinho.adapter.ts`
- Import de `Errors` adicionado em ambos os adapters

### Flutter — Novos utilitários
- `lib/shared/utils/lex_dialogs.dart` — `lexConfirmDialog()`: dialog de confirmação padrão LEX (AppColors + AppTextStyles + AppRadius.card); substitui 4 blocos AlertDialog inline
- `lib/shared/utils/async_value_handler.dart` — `handleAsyncError()`: centraliza redirect 401 + LexErrorState; substitui 4 blocos when(error:) duplicados
- `lib/shared/extensions/context_extensions.dart` — `.bottomPad` / `.topPad` extensions em BuildContext; substitui 8 declarações MediaQuery espalhadas
- `lib/shared/widgets/lex_glass_sheet.dart` — `LexGlassSheet.show<T>()` static: configura showModalBottomSheet com transparente + isScrollControlled automaticamente; substitui 3 chamadas duplicadas

### Flutter — Correções nos módulos
- **Anotações**: lexConfirmDialog + handleAsyncError + debugPrint + bottomPad
- **Simulados**: lexConfirmDialog (attempt) + debugPrint + bottomPad (attempt + config)
- **Manual**: handleAsyncError (list + detail) + fire-and-forget documentado (list + repository) + bottomPad
- **Dashboard**: debugPrint nos catches + fire-and-forget documentado (repository) + bottomPad
- **Onboarding/Diagnóstico**: debugPrint nos catches (×4 ocorrências)
- **Tutor**: lexConfirmDialog (history) + fire-and-forget documentado no dispose (tutor_screen)
- **Perfil/Segurança**: lexConfirmDialog (seguranca_card) + bottomPad (perfil_screen)
- **Sheets**: LexGlassSheet.show() em pro_gate_sheet + revisar_sheet + manual_tutor_sheet

## Arquivos criados
- `lib/shared/utils/lex_dialogs.dart`
- `lib/shared/utils/async_value_handler.dart`
- `lib/shared/extensions/context_extensions.dart`
- `.claude/sessions/2026-06-19_code_health_wave.md`

## Arquivos modificados (Flutter — 17)
- `lib/shared/widgets/lex_glass_sheet.dart` (+ método show())
- `lib/features/anotacoes/presentation/screens/anotacoes_screen.dart`
- `lib/features/simulados/presentation/screens/simulado_attempt_screen.dart`
- `lib/features/simulados/presentation/screens/simulado_config_screen.dart`
- `lib/features/manual/presentation/screens/manual_list_screen.dart`
- `lib/features/manual/presentation/screens/manual_detail_screen.dart`
- `lib/features/manual/data/manual_repository.dart`
- `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
- `lib/features/dashboard/data/dashboard_repository.dart`
- `lib/features/onboarding/providers/onboarding_provider.dart`
- `lib/features/onboarding/presentation/screens/diagnostico_screen.dart`
- `lib/features/tutor/presentation/screens/tutor_history_screen.dart`
- `lib/features/tutor/presentation/screens/tutor_screen.dart`
- `lib/features/perfil/presentation/widgets/seguranca_card.dart`
- `lib/shared/widgets/pro_gate_sheet.dart`
- `lib/features/dashboard/presentation/widgets/revisar_sheet.dart`
- `lib/features/manual/presentation/widgets/manual_tutor_sheet.dart`
- `lib/features/perfil/presentation/screens/perfil_screen.dart`

## Arquivos modificados (Backend — 3)
- `back/src/shared/errors.ts`
- `back/src/modules/tutor-ia/adapters/sabia.adapter.ts`
- `back/src/modules/tutor-ia/adapters/sabiazinho.adapter.ts`

## Critérios de aceite cumpridos
- [x] flutter analyze: 0 issues
- [x] tsc --noEmit: 0 erros
- [x] 0 `new Error()` em src/ backend
- [x] 0 AlertDialog inline duplicado (4 extraídos para lexConfirmDialog)
- [x] 0 bloco 401 duplicado em when(error:) (4 extraídos para handleAsyncError)
- [x] 13 catches silenciosos documentados (fire-and-forget) ou logados (debugPrint)
- [x] 3 showModalBottomSheet consolidados em LexGlassSheet.show()
- [x] 8 MediaQuery.bottom consolidados em context.bottomPad

## Pendências / Próximos passos
- Nenhuma pendência desta sessão

## Decisões tomadas
- `catch (_) {}` em fire-and-forget legítimos: mantidos com comentário explicativo (sem quebrar comportamento)
- `showDialog` em simulado_config_screen.dart com `_InProgressAction` enum: mantido inline (não é bool, não se encaixa no lexConfirmDialog)
- `dashboard_screen.dart`: error handling via `ref.listen` (não `when(error:)`) — handleAsyncError não aplicável aqui
- `Errors.upstream()`: retorna HTTP 502 (semanticamente correto para falha de API Maritaca)
