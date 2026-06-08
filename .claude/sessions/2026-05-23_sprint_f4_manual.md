# Sessão 2026-05-23 — Sprint F4 Manual

## O que foi feito

- Implementação completa da feature Manual para o app Flutter LCF
- 10 arquivos novos criados + app_router.dart atualizado
- build_runner executado com sucesso (11 outputs, 51 actions)
- flutter analyze: zero issues

## Arquivos criados

- `features/manual/data/models/manual_models.dart` — Topic, TopicSection, TopicDetail, ManualSearchResult; kLawCodeToLabel, kSectionKeyToLabel
- `features/manual/data/manual_repository.dart` — Dio puro: getTopics, getTopicDetail, markAsRead, searchTopics + @riverpod provider
- `features/manual/providers/manual_provider.dart` — manualTopicsProvider (family lawCode), manualTopicDetailProvider, manualSearchProvider, SelectedLawCode notifier, filteredTopicsProvider
- `features/manual/presentation/widgets/filter_chips_row.dart` — ConsumerWidget com 7 chips + seleção gold, lê selectedLawCodeProvider
- `features/manual/presentation/widgets/manual_search_bar.dart` — TextField colapsável com botão X
- `features/manual/presentation/widgets/topic_card.dart` — CategoryTag + título + metarow (timer + data) + indicador isRead
- `features/manual/presentation/widgets/topic_section_tile.dart` — Bullet gold numerado + título + conteúdo + divider
- `features/manual/presentation/widgets/sobre_este_resumo_card.dart` — Card dark fixo com metodologia LCF
- `features/manual/presentation/screens/manual_list_screen.dart` — ConsumerStatefulWidget: modo lista (filteredTopics) + modo busca (manualSearch, debounce 400ms)
- `features/manual/presentation/screens/manual_detail_screen.dart` — ConsumerStatefulWidget: carrega detalhe, mark-as-read fire-and-forget no initState, 401→/login, 404→error sem retry

## Arquivos modificados

- `core/router/app_router.dart` — substituiu _PlaceholderScreen para /manual e /manual/topic/:id pelas telas reais

## Critérios de aceite cumpridos

- [x] Lista exibe tópicos com CategoryTag colorida por matéria
- [x] Filter chips filtram por matéria (lawCode) via selectedLawCodeProvider + server-side
- [x] Search com debounce 400ms chama /manual/search
- [x] Tópico lido exibe indicador visual (✅ + borda gold sutil)
- [x] POST /manual/topics/:id/read chamado ao abrir detalhe (fire-and-forget, idempotente)
- [x] Detalhe exibe 6 seções da estrutura canônica v1.0 (fundamento → resumo)
- [x] SobreEsteResumoCard exibido no topo do detalhe
- [x] Loading shimmer na lista (LcfListShimmer) e no detalhe (_DetailShimmer)
- [x] Error state 401 → redirect /login
- [x] Error state 404 → mensagem sem retry
- [x] Error state 5xx → mensagem + botão retry
- [x] Zero Color/TextStyle hardcoded (exceto categoria_tag.dart que já tinha as cores)
- [x] @riverpod codegen em todos os providers e repository
- [x] CategoryTag existente (shared) usado sem modificação — aceita lawLabel auto-resolve color

## Decisões tomadas

- Cores de matéria NÃO duplicadas em manual_models.dart — já existiam em category_tag.dart (_subjectColors). Passou lawLabel para CategoryTag que resolve a cor automaticamente.
- `ManualListScreen` usa ConsumerStatefulWidget para gerenciar TextEditingController + debounce Timer
- `ManualDetailScreen` usa ConsumerStatefulWidget para acessar ref em initState (fire-and-forget markAsRead)
- Após markAsRead: invalida `manualTopicsProvider(lawCode: selectedCode)` + `filteredTopicsProvider` para atualizar o card na lista sem bloquear a UI do detalhe
- FilterChipsRow gerencia seleção diretamente via selectedLawCodeProvider (sem callback externo obrigatório)
- Chips de busca: estado local no ConsumerState (_searchQuery), não em provider (ephemeral)

## Pendências / Próximos passos

- Sprint F5 — Simulados
- Sprint F6 — Anotações
- Sprint F7 — Perfil + Assinatura
