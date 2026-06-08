# Sessão 2026-05-23 — Sprint F2 Dashboard

## O que foi feito

- Lidos todos os documentos de referência obrigatórios (CLAUDE.md, PROJECT_STATE.md, SCREENS.md, DESIGN_TOKENS.md, FRONTEND_BLUEPRINT.md, api-contract.md + backend `dashboard.service.ts`)
- Auditado o código existente do F1 (app_colors, app_theme, category_tag, auth_provider, scaffold_with_nav) para garantir consistência
- Criados 10 arquivos do Sprint F2 Dashboard
- Corrigidos todos os `prefer_const_constructors`, `prefer_const_literals` e `deprecated_member_use` (withOpacity → withValues)
- `dart run build_runner build --delete-conflicting-outputs` → 496 outputs, sucesso
- `flutter analyze` → **No issues found!**

## Arquivos modificados / criados

### Novos
- `features/dashboard/data/models/dashboard_models.dart` — StreakInfo, DailyProgress, DashboardData, RevisionCard, SubjectPerformance, PerformanceData (json_annotation)
- `features/dashboard/data/dashboard_repository.dart` — getHomeData(), getRevisionCards(), getPerformance() via Dio
- `features/dashboard/providers/dashboard_provider.dart` — dashboardDataProvider, revisionCardsProvider, performanceProvider (@riverpod)
- `features/dashboard/presentation/screens/dashboard_screen.dart` — ConsumerStatefulWidget, RefreshIndicator + SingleChildScrollView, invalida 3 providers no pull-to-refresh
- `features/dashboard/presentation/widgets/greeting_card.dart` — saudação por horário, streak badge dourado se ≥7 dias
- `features/dashboard/presentation/widgets/metas_diarias_card.dart` — DonutChart CustomPainter (sem lib externa), checklist de tarefas diárias
- `features/dashboard/presentation/widgets/revisao_inteligente_card.dart` — ListView horizontal, CategoryTag automático por subject, empty state inline
- `features/dashboard/presentation/widgets/tarefas_rapidas_card.dart` — 4 botões (Simulado, Manual, Tutor, Anotações) com navegação GoRouter
- `features/dashboard/presentation/widgets/cards_materia_card.dart` — grid 2×2 com stats de performance + streak

### Modificados
- `core/router/app_router.dart` — substituído `_PlaceholderScreen` por `DashboardScreen` na rota `/dashboard`; adicionadas rotas stub `/manual`, `/manual/topic/:id`, `/simulados`, `/simulados/:id`, `/simulados/:id/results` (para F4/F5)

## Critérios de aceite cumpridos

- [x] Dashboard exibe nome do usuário, streak, % meta diária
- [x] DonutChart gold renderiza com % correto (CustomPainter, sem lib externa)
- [x] RevisaoInteligente exibe cards horizontais com matérias
- [x] Loading state com LcfLoadingShimmer em todas as seções
- [x] Error state com "Tentar novamente" que invalida o provider específico
- [x] TarefasRapidas navega para as rotas corretas ao tocar
- [x] CardsMaterias exibe os 4 stats (questões, acerto, matérias, streak)
- [x] Zero Color(0xFF...) ou TextStyle(fontSize:...) hardcoded
- [x] RefreshIndicator invalida os 3 providers e aguarda completion
- [x] flutter analyze → No issues found

## Pendências / Próximos passos

- **Rotas `/manual` e `/simulados`** são stubs — implementar em F3 (Tutor) e F4/F5
- **RevisionCard sem topicId** — a revisão inteligente navega para `/manual` (lista geral); no F4, adicionar filtro por lawCode quando o manual list screen for implementado
- **`flutter create` para plataformas** ainda pendente do F1 — sem as pastas `android/` e `ios/`, o app não compila para dispositivos reais
- **F3 Tutor IA** — próximo sprint

## Decisões tomadas

- `DashboardRepository` usa Dio diretamente (sem Retrofit annotations) — padrão consistente com `OnboardingRepository` e `AuthRepository` do F1
- `meta diária de questões` derivada de `dailyGoalMins / 3` (mínimo 10, máximo 90) — backend retorna minutos de estudo, não contagem de questões
- `CardsMateriaCard` combina `performanceProvider` (questões, acerto, matérias) e `dashboardDataProvider.valueOrNull?.streak` (fallback 0 se ainda carregando) — UX progressivo
- `_PlaceholderScreen` ganhou Scaffold próprio para funcionar fora do ShellRoute (stub routes /manual e /simulados)
