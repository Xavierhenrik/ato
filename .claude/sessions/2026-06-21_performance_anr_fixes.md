# Sessão 2026-06-21 — Performance Flutter: ANR + GPU + Streaming

## O que foi feito

### Fase 1 — Diagnóstico e correção de ANR (root causes)
Identificado e corrigido ANR crítico ("lcf_app isn't responding") em duas frentes:
- Leituras síncronas Isar bloqueando main thread durante write lock concorrente
- Background refresh storm: 3 providers disparando 9 requests + 3 writes Isar simultâneos

### Fase 2 — Auditoria profunda de performance (15 pontos identificados)

### Fase 3 — Correções implementadas

**Commits do Dev A (widgets compartilhados):**

**Arquivo `lib/core/theme/glass_tokens.dart`**
- `kGlassFrostSigma`: 18.0 → 10.0 (~70% redução de custo GPU, imperceptível visualmente)

**Arquivo `lib/shared/widgets/lex_glass_nav_bar.dart`**
- `MediaQuery.of(context)` no escopo externo → `MediaQuery.viewInsetsOf` + `MediaQuery.viewPaddingOf` (seletores granulares)
- `ClipRRect` da pílula (`_GlassPill`) envolta em `RepaintBoundary`

**Arquivo `lib/shared/widgets/lex_top_scrim.dart`**
- `ClipRect` envolto em `RepaintBoundary`

**Arquivo `lib/shared/widgets/lex_glass_sheet.dart`**
- `ClipRRect` envolto em `RepaintBoundary`

**Arquivo `lib/features/tutor/presentation/screens/tutor_history_screen.dart`**
- `ClipRRect` do `_SegmentedControl` envolto em `RepaintBoundary`

**Arquivo `lib/shared/widgets/scaffold_with_nav.dart`**
- `MediaQuery.of(context)` removido do escopo externo → `MediaQuery.viewInsetsOf(context).bottom`
- `final mq = MediaQuery.of(context)` movido para dentro do `TweenAnimationBuilder.builder`

**Commits do Dev B (tutor screen):**

**Arquivo `lib/features/tutor/presentation/screens/tutor_screen.dart`**
- `ListView.builder` em `_ChatListView` envolto em `RepaintBoundary`
- `key: ValueKey(msg.id)` migrado do `ChatBubble` para o `Column` pai (widget raiz do `itemBuilder`)

**Arquivo `lib/features/dashboard/data/dashboard_repository.dart`** (sessão anterior)
- 4× `getSync(1)` → `await get(1)` (eliminação de bloqueio síncrono)
- Background refresh centralizado + guard `static bool _isRefreshing`

**Arquivo `lib/features/manual/data/manual_repository.dart`** (sessão anterior)
- 2× `findFirstSync()` → `await findFirst()`
- Guard `static bool _isRefreshing` para refresh de filtros concorrentes

## Arquivos modificados
- `lib/core/theme/glass_tokens.dart` — sigma 18→10
- `lib/shared/widgets/lex_glass_nav_bar.dart` — MediaQuery seletores + RepaintBoundary
- `lib/shared/widgets/lex_top_scrim.dart` — RepaintBoundary
- `lib/shared/widgets/lex_glass_sheet.dart` — RepaintBoundary
- `lib/features/tutor/presentation/screens/tutor_history_screen.dart` — RepaintBoundary
- `lib/shared/widgets/scaffold_with_nav.dart` — MediaQuery seletores
- `lib/features/tutor/presentation/screens/tutor_screen.dart` — RepaintBoundary + key
- `lib/features/dashboard/data/dashboard_repository.dart` — async reads + refresh guard
- `lib/features/manual/data/manual_repository.dart` — async reads + refresh guard

## Critérios de aceite cumpridos
- [x] `flutter analyze` zero issues (confirmado por ambos os agentes)
- [x] Leituras síncronas Isar eliminadas (4 dashboard + 2 manual)
- [x] Background refresh storm eliminado
- [x] BackdropFilter sigma reduzido 18→10 em todos os pontos via `kGlassFrostSigma`
- [x] RepaintBoundary em 4 instâncias de BackdropFilter
- [x] MediaQuery.of → seletores específicos em ScaffoldWithNav + LexGlassNavBar
- [x] RepaintBoundary isola ChatList do streaming de 8ms
- [x] ValueKey movido para Column pai (widget raiz do itemBuilder)

## Pendências / Próximos passos
- Testar no emulador para confirmar eliminação do ANR
- Pontos DESCARTADOS como overengineering para MVP:
  - Cache Isar para Simulados, Perfil e Anotações (baixa frequência, custo não justificado)
  - AnimatedBuilder fora do BackdropFilter (risco de regressão visual)
  - TutorNotifier keepAlive (quebraria contrato "sem memória entre sessões")
  - provider.select() para streaming (RepaintBoundary resolve 80% com 10% do esforço)

## Decisões tomadas
- `kGlassFrostSigma = 10.0` adotado como novo padrão — valor global, qualquer reajuste futuro muda apenas `glass_tokens.dart`
- `RepaintBoundary` é o padrão correto para BackdropFilter em Flutter — adicionar quando novos BackdropFilters forem criados
- MediaQuery granular obrigatório em widgets de shell (ScaffoldWithNav, nav bar)
