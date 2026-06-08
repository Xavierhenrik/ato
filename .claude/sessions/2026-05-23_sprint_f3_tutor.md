# Sessão 2026-05-23 — Sprint F3 Tutor IA

## O que foi feito

Sprint F3 completo: tela Tutor IA com estado vazio e estado de chat, integração com
backend via Dio puro, treatment de erros HTTP e ciclo de vida da sessão.

## Arquivos criados (11)

- `features/tutor/data/models/tutor_models.dart` — TutorMessage, TutorSession, SendMessageResponse (plain Dart — sem json_annotation pois repository parseia manualmente)
- `features/tutor/data/tutor_repository.dart` — Dio puro: createSession, sendMessage, deleteSession + provider @riverpod
- `features/tutor/providers/tutor_provider.dart` — TutorChatState (messages + isLoading), TutorNotifier com sendMessage (otimistic) e endSession
- `features/tutor/presentation/widgets/tutor_welcome_card.dart` — Card inicial com avatar robô gold + 3 feature badges
- `features/tutor/presentation/widgets/tutor_suggestions_card.dart` — 6 chips de perguntas sugeridas em Wrap
- `features/tutor/presentation/widgets/tutor_empty_state.dart` — Composição WelcomeCard + SuggestionsCard
- `features/tutor/presentation/widgets/chat_bubble.dart` — Balão user (direita/accent 20%) e IA (esquerda/backgroundCard) com avatar robô
- `features/tutor/presentation/widgets/chat_input_bar.dart` — TextField + botão send gold + disclaimer
- `features/tutor/presentation/widgets/chips_row.dart` — Row scrollável de chips de continuação
- `features/tutor/presentation/widgets/typing_indicator.dart` — 3 dots animados (FadeTransition com stagger 150ms)
- `features/tutor/presentation/screens/tutor_screen.dart` — ConsumerStatefulWidget: alterna TutorEmptyState / _ChatListView, LcfTutorAppBar com lixeira, tratamento 429/401/5xx

## Arquivos modificados (2)

- `core/router/app_router.dart` — import TutorScreen + substituição do _PlaceholderScreen em `/tutor`
- `.claude/PROJECT_STATE.md` — F3 → ✅ Concluído + log de sessão

## Critérios de aceite cumpridos

- [x] Estado vazio exibe WelcomeCard + 6 chips de sugestão
- [x] Tap em chip preenche o input e envia a mensagem automaticamente
- [x] Mensagem do usuário aparece imediatamente (optimistic insert antes do request)
- [x] TypingIndicator aparece enquanto isLoading (extra slot no ListView.builder)
- [x] Resposta da IA renderiza com chips de continuação abaixo (ChipsRow)
- [x] Chips de continuação enviam nova mensagem ao tocar
- [x] Snackbar "Anotação salva automaticamente ✓" se autoSavedAnnotationId presente (PRO)
- [x] 429 → ProGateSheet com feature 'Limite diário atingido'
- [x] 401 → context.go('/login')
- [x] 5xx → SnackBar "Erro ao conectar. Tente novamente."
- [x] Sessão encerrada ao sair da tela (endSession fire-and-forget em dispose)
- [x] LcfTutorAppBar: LCF box gold | "Tutor IA" | ícone lixeira (só com mensagens)
- [x] Lixeira confirma encerramento com AlertDialog
- [x] Sessão lazy: criada na primeira mensagem (POST /tutor/session/new)
- [x] build_runner: 96 outputs, 233 actions — sucesso
- [x] flutter analyze: zero issues

## Decisões técnicas

- **Sem json_annotation nos models do tutor**: Dio puro parseia manualmente — sem overhead de codegen para structs simples
- **TutorChatState wrapper**: agrupa messages + isLoading em estado único para evitar split-brain no build cycle
- **Ref capture antes de await em endSession()**: `final repo = ref.read(...)` antes do primeiro await evita acesso a ref após dispose do provider
- **withValues(alpha:) em vez de withOpacity()**: API recomendada no SDK atual (flutter analyze zero)
- **Otimistic revert no catch**: mensagem do usuário é removida do state se a API falhar, mantendo consistência

## Pendências / Próximos passos

- Sprint F4 — Manual: ManualListScreen + ManualDetailScreen + TopicCard
- Sprint F5 — Simulados: fluxo completo config → attempt → result
- Sprint F6 — Anotações: CRUD + integração com Tutor (PRO)
- Sprint F7 — Perfil + Assinatura RevenueCat
