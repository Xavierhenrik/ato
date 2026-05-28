# Sessão 2026-05-27 — Sprint F8 Offline-First (Isar)

## O que foi feito

- **Diagnóstico**: infraestrutura Isar já existia (`isar_service.dart`, `isar_schemas.dart`, integração nos repositories) — faltavam apenas: fallback para cache stale + `invalidateCache()` + pull-to-refresh nas telas
- **ManualRepository**: adicionado try-catch em `getTopics()` para fallback ao cache stale (qualquer TTL) quando `DioException`; adicionado `invalidateCache({String? lawCode})` que deleta entradas do Isar
- **DashboardRepository**: adicionado try-catch com fallback stale nos 3 métodos (`getHomeData`, `getRevisionCards`, `getPerformance`); adicionado `invalidateCache()` que deleta o registro id=1
- **DashboardScreen**: corrigido `_onRefresh()` para chamar `repo.invalidateCache()` antes de `ref.invalidate(...)` — sem isso o pull-to-refresh servia dados do cache Isar em vez de buscar da rede
- **ManualListScreen**: adicionado `_onRefresh()` + `RefreshIndicator` wrapping `_TopicsListView`
- **AnotacoesScreen**: adicionado `_onRefresh()` + `RefreshIndicator` wrapping `_AnotacoesListView`
- **Bugfix**: `manual_detail_screen.dart` usava `ref.read(manualRepositoryProvider)` (síncrono) em provider assíncrono — corrigido para `.future.then()`
- **build_runner**: rodado — 144 outputs gerados (Isar schemas, Riverpod codegen, JSON)

## Arquivos modificados

- `lib/features/manual/data/manual_repository.dart` — fallback stale + `invalidateCache()`
- `lib/features/dashboard/data/dashboard_repository.dart` — fallback stale em 3 métodos + `invalidateCache()`
- `lib/features/dashboard/presentation/screens/dashboard_screen.dart` — `_onRefresh()` limpa Isar antes de re-fetch; import `dashboard_repository.dart`
- `lib/features/manual/presentation/screens/manual_list_screen.dart` — `_onRefresh()` + `RefreshIndicator`; import `manual_repository.dart`
- `lib/features/anotacoes/presentation/screens/anotacoes_screen.dart` — `_onRefresh()` + `RefreshIndicator`
- `lib/features/manual/presentation/screens/manual_detail_screen.dart` — bugfix `markAsRead` async

## Critérios de aceite cumpridos

- [x] Manual lista funciona offline se já carregado antes (Isar cache TTL 24h + fallback stale)
- [x] Dashboard funciona offline com dados em cache (TTL 1h + fallback stale)
- [x] flutter analyze retorna zero issues
- [x] Pull-to-refresh atualiza dados e invalida cache Isar (Manual, Dashboard, Anotações)
- [x] App não crasha ao abrir em modo offline sem cache (DioException → AsyncError → LcfErrorState)

## Decisões tomadas

- `invalidateCache()` sem `lawCode` limpa TODOS os caches de topics (mais consistente para pull-to-refresh global)
- Fallback stale serve qualquer age de cache (sem TTL check) — quando a rede falha, preferível mostrar dado antigo a crash/error
- `AnotacoesScreen._onRefresh` não tem Isar (por design) — apenas `ref.invalidate(anotacoesProvider)` + re-fetch

## Pendências (não bloqueantes)

- Migration sprint4_simulado_indexes: `npx prisma migrate dev --name sprint4_simulado_indexes`
- Push notifications: bloqueado em OneSignal App ID + API Key
- Deploy Railway: alterar Root Directory de `/` para `back`
- Scaffold de plataformas: `flutter create --org com.lcf ...` se não feito
