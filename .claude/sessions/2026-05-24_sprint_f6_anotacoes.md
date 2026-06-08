# Sessão 2026-05-24 — Sprint F6 Anotações

## O que foi feito

Sprint F6 completo: feature de Anotações implementada do zero seguindo o padrão dos sprints anteriores (F4 Manual + F5 Simulados como referência).

## Arquivos criados

- `lib/features/anotacoes/data/models/anotacao_models.dart` — classe `Anotacao` com `fromJson` + constante `kAnnotationSubjects`
- `lib/features/anotacoes/data/anotacao_repository.dart` — `AnotacaoRepository` com `getAnnotations`, `createAnnotation`, `updateAnnotation`, `deleteAnnotation` + `@riverpod` factory
- `lib/features/anotacoes/providers/anotacao_provider.dart` — `anotacoesProvider` (family por `subject?`/`q?`) + `SelectedSubjectFilter` notifier
- `lib/features/anotacoes/presentation/widgets/anotacao_card.dart` — card com título, data, tags pills (accent border), preview 2 linhas, subject pill, ícone robô se `autoSaved`
- `lib/features/anotacoes/presentation/widgets/anotacao_filter_chips.dart` — chips "Todas" + 9 matérias, conectados ao `SelectedSubjectFilter`
- `lib/features/anotacoes/presentation/widgets/anotacao_search_bar.dart` — campo de busca com debounce, mesmo padrão do ManualSearchBar
- `lib/features/anotacoes/presentation/screens/anotacoes_screen.dart` — lista com AppBar (busca + nova anotação), filtros, `Dismissible` swipe-to-delete com confirmação, FAB gold, EmptyState com CTA
- `lib/features/anotacoes/presentation/screens/anotacao_editor_screen.dart` — criação/edição com TitleField sem borda, SubjectSelector dropdown, TagsInput com chips inline (Enter ou vírgula), ContentField multiline

## Arquivos modificados

- `lib/core/router/app_router.dart` — `/anotacoes` substituído (placeholder → `AnotacoesScreen`); `/anotacoes/nova` e `/anotacoes/:id/editar` adicionados como push routes fora do ShellRoute (sem bottom nav); `_PlaceholderScreen` removido
- `lib/features/perfil/presentation/screens/subscription_screen.dart` — `const` fix (pre-existing warning)
- `lib/features/perfil/presentation/widgets/preferencias_card.dart` — `const` fix (pre-existing warning)

## Critérios de aceite cumpridos

- [x] Lista exibe anotações com título, tags, preview e data
- [x] Filtro por matéria (subject) via chips
- [x] Busca em título e conteúdo com debounce 400ms
- [x] FAB navega para criação
- [x] Criação persiste com título, subject, tags e content
- [x] Edição carrega dados existentes e atualiza (via `state.extra as Anotacao`)
- [x] Swipe-to-delete com confirmação dialog
- [x] Anotações auto-salvas pelo Tutor (PRO) exibem ícone `Icons.smart_toy_outlined`
- [x] Empty state com CTA "Criar primeira anotação"
- [x] Ao salvar: `ref.invalidate(anotacoesProvider)` + `context.pop()`
- [x] `build_runner build` — zero erros
- [x] `flutter analyze` — zero issues

## Decisões tomadas

- Editor fora do ShellRoute (push route) — sem bottom nav, padrão UX correto para modais de criação/edição; mesmo padrão dos simulados e manual
- Tags aceitam vírgula além de Enter (split by comma no `_addTag`)
- `subject` é passado como `null` no `updateAnnotation` quando vazio — backend preserva o valor existente; para limpar, usuário seleciona "Nenhuma" no dropdown
- Routing de edição usa `state.extra as Anotacao?` — não há endpoint `GET /annotations/:id` na API; a annotation é sempre passada via navegação

## Pendências / Próximos passos

- F8 Hardening: pull-to-refresh na lista de anotações, cache Isar (se necessário)
- Tag input com separador vírgula funciona no `onSubmitted` mas não intercepta vírgula mid-typing — melhorar no F8 se necessário
