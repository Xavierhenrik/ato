# Sessão 2026-05-27 — Sprint Quiz Diagnóstico

## O que foi feito

Implementação end-to-end do Quiz Diagnóstico — único fluxo funcional ausente no LCF.

## Arquivos modificados

### Backend
- `back/src/modules/onboarding/onboarding.service.ts` — adicionado import `Prisma`, tipo `QuestionRow`, método `getQuestions()` com `$queryRaw ORDER BY RANDOM() LIMIT 10`
- `back/src/modules/onboarding/onboarding.controller.ts` — adicionado handler `getQuestions()`
- `back/src/modules/onboarding/onboarding.routes.ts` — registrada rota `GET /diagnostic/questions` com `requireAuth`

### Flutter
- `front/lcf_app/lib/features/onboarding/data/onboarding_repository.dart` — adicionados modelos `DiagnosticoQuestion`, `DiagnosticoQuestionsResponse` e método `getDiagnosticQuestions()`
- `front/lcf_app/lib/features/onboarding/providers/onboarding_provider.dart` — adicionados `DiagnosticoQuizState`, `DiagnosticoQuizNotifier`; corrigido `DiagnosticoNotifier.complete()` para swallow de erro (sempre avança para `done`)
- `front/lcf_app/lib/features/onboarding/presentation/screens/diagnostico_screen.dart` — `_AnsweringState` substituído (ConsumerWidget → ConsumerStatefulWidget); implementada UI funcional com progress bar, QuestionCard, AnswerOption, botão avançar; adicionado `_QuestionCard` inline

## Critérios de aceite cumpridos

- [x] `GET /onboarding/diagnostic/questions` retorna `{ nivelamentoPath, questions[] }` com 10 questões
- [x] Questões filtradas por `nivelamentoPath` do perfil (`'oab'` → `type: 'simulado'`, `'graduation'` → `type: 'review'`)
- [x] `npx tsc --noEmit` → zero erros
- [x] `_AnsweringState` exibe questões reais (enunciado + 4 opções A/B/C/D)
- [x] Barra de progresso reflete posição atual (questão X de 10)
- [x] Botão desabilitado (`onPressed: null`) até o usuário selecionar uma opção
- [x] Última questão: chama `diagnosticComplete()` → navega para `DiagnosticoStep.done`
- [x] Erro de rede em `complete()` não bloqueia (try/catch swallow + `state = DiagnosticoStep.done` sempre executado)
- [x] `flutter analyze` → zero issues
- [x] `dart run build_runner build --delete-conflicting-outputs` executado

## Decisões tomadas

- `ORDER BY RANDOM() LIMIT 10` via `$queryRaw` + `Prisma.sql` — Prisma ORM não suporta `ORDER BY RANDOM()` nativamente; uso de raw query com parametrização correta mantém a regra de não usar interpolação de string
- `AnswerOption` (simulados) reutilizado diretamente em `diagnostico_screen.dart` — widget é genérico (letter/text/state/onTap); cross-feature import é aceitável neste caso. Apenas os estados `idle` e `selected` são usados no diagnóstico (sem feedback de correto/errado)
- `_QuestionCard` inline no arquivo da tela — não duplica `QuestionCard` de simulados porque depende de `DiagnosticoQuestion`, não de `simulado_models.Question`; o widget é simples o suficiente para não justificar extração para `shared/`
- `DiagnosticoNotifier.complete()` agora tem try/catch com swallow — alinha com critério "erro de rede não bloqueia"
- `DiagnosticoQuizNotifier` usa `AutoDisposeNotifier` (padrão gerado pelo codegen `@riverpod`) — estado do quiz é descartado ao sair da tela

## Pendências / Próximos passos

- Nenhuma pendência neste módulo
- Próximo sprint sugerido: promover questões `pending_review` via admin endpoint (Sprint 4 backlog), ou iniciar integração de notificações push (aguardando OneSignal credentials)
