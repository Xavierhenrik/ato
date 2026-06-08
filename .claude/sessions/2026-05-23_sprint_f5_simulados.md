# Sessão 2026-05-23 — Sprint F5 Simulados

## O que foi feito

Sprint F5 completo: 3 telas de simulado (config, em andamento, resultado) com
máquina de estados de resposta, gating Free/PRO no UI e no backend, e ciclo de vida
completo (start → answer → complete | abandon → results).

## Arquivos criados (13)

- `features/simulados/data/models/simulado_models.dart` — SimuladoMode (enum com apiValue/label), Question, SimuladoAttempt, AnswerResult, QuestionReview, SimuladoResult, SimuladoHistoryItem — todos com `fromJson` manual
- `features/simulados/data/simulado_repository.dart` — Dio puro: startSimulado, getInProgress, answerQuestion, completeSimulado, abandonSimulado, getResults, getHistory, getUserPlan + @riverpod provider
- `features/simulados/providers/simulado_provider.dart` — simuladoHistoryProvider, simuladoResultProvider (family), simuladoUserPlanProvider (fallback 'free' em erro)
- `features/simulados/presentation/widgets/mode_option_card.dart` — card de modo com lock icon, borda gold se selecionado
- `features/simulados/presentation/widgets/quantity_chip.dart` — chip de quantidade com lock icon para Free
- `features/simulados/presentation/widgets/question_card.dart` — enunciado + CategoryTag + ano
- `features/simulados/presentation/widgets/answer_option.dart` — A/B/C/D com 4 estados (idle/selected/correct/wrong), AnimatedContainer 200ms
- `features/simulados/presentation/widgets/score_header_card.dart` — percentual grande + badge Aprovado/Reprovado + stats Total/Corretas/Erradas
- `features/simulados/presentation/widgets/subject_performance_card.dart` — LinearProgressIndicator gold por matéria
- `features/simulados/presentation/widgets/question_review_item.dart` — revisão de questão com explicação ou gate PRO
- `features/simulados/presentation/screens/simulado_config_screen.dart` — ConsumerStatefulWidget: grid 2×2 de modos, chips de quantidade, histórico recente, gating Free via simuladoUserPlanProvider, tratamento 409/400/403/429/401
- `features/simulados/presentation/screens/simulado_attempt_screen.dart` — ConsumerStatefulWidget: máquina de estados local (selectedAnswer + lastResult + isLoading), barra de progresso, confirm/advance/abandon com dialogs
- `features/simulados/presentation/screens/simulado_result_screen.dart` — ConsumerWidget: ScoreHeaderCard + SubjectPerformanceCard + QuestionsReviewList com gate PRO

## Arquivos modificados (1)

- `core/router/app_router.dart` — substituiu _PlaceholderScreen em /simulados, /simulados/:id, /simulados/:id/results; passa SimuladoAttempt via GoRouter extra

## Critérios de aceite cumpridos

- [x] Modo selecionado: borda gold, fundo accent 10%
- [x] Modo PRO-locked (Free): ícone 🔒 + tap → ProGateSheet
- [x] Quantidade PRO-locked (> 15 para Free): ícone 🔒 + tap → ProGateSheet
- [x] Histórico recente: últimas 3 tentativas com score e modo
- [x] 409 SIMULADO_IN_PROGRESS → AlertDialog: Continuar (carrega in-progress) ou Iniciar Novo (abandon + retry)
- [x] Barra de progresso linear (questão X/N) no attempt screen
- [x] Opção selecionada (antes de confirmar): borda/fundo accent
- [x] Opção correta (após confirmar): verde — mesmo se o usuário errou
- [x] Opção errada do usuário: vermelho
- [x] Último questão: botão muda para "Ver resultado" → POST complete → go /results
- [x] Abandonar: AlertDialog → POST abandon → go /simulados
- [x] Resultado: percentual, badge Aprovado/Reprovado (threshold 60%)
- [x] Desempenho por matéria: LinearProgressIndicator gold
- [x] explanation == null (Free): bloco travado com 🔒 → ProGateSheet
- [x] explanation != null (PRO): texto da explicação exibido
- [x] CTAs resultado: "Novo simulado" + "Voltar ao início"
- [x] 401 → context.go('/login') em qualquer tela
- [x] 5xx → SnackBar "Erro ao conectar. Tente novamente."
- [x] build_runner: 119 outputs, 276 actions — sucesso
- [x] flutter analyze: zero issues

## Decisões técnicas

- **Attempt state é local** (`ConsumerStatefulWidget`): máquina de estados simples, não compartilhada com nenhuma outra tela — Riverpod seria overkill
- **GoRouter extra para SimuladoAttempt**: limpa, mobile-first, sem provider intermediário; fallback para config se extra nulo (deeplink)
- **simuladoUserPlanProvider** isolado na feature simulados — fallback 'free' em erro garante que o backend seja o árbitro real; F7 pode substituir com um provider global compartilhado
- **AnswerState enum** local em `answer_option.dart`: 4 estados mapeados por expressão switch para cores/bordas; verde/vermelho definidos como const no arquivo (padrão igual a `_subjectColors` em category_tag.dart)
- **prefer_const fixes**: 4 issues corrigidos após primeira passagem de analyze

## Pendências / Próximos passos

- Sprint F6 — Anotações: lista + criação/edição, FAB, swipe-to-delete
- Sprint F7 — Perfil + Assinatura: ProfileScreen + SubscriptionScreen + RevenueCat
