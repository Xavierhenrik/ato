# Sessão 2026-06-11 — Revisão Inteligente Porta Dupla

## O que foi feito

- **`_RevisionTile`** refatorado de `StatelessWidget` para `StatefulWidget`: borda dourada (`borderAccent`) e fundo accent (`accent.withValues(alpha:0.12)`) aparecem apenas enquanto o card está pressionado via `onHighlightChanged`; repouso usa `border` / `backgroundSheet`. Parâmetro `isFirst` e `i == 0` no itemBuilder removidos.
- **Label corrigido**: `'${totalAnswered} questões'` → `'${totalAnswered} respondidas'` (corrige o "1 questões" e a semântica errada — o número é de questões já respondidas, não a revisar).
- **Subtítulo corrigido**: `'Com base no algoritmo de repetição espaçada'` → `'Suas matérias com mais erros recentes'` (cópia honesta).
- **`onTap`** do tile não navega mais para `/manual` sem filtro; abre `RevisarSheet` via `showModalBottomSheet`.
- **`RevisarSheet`** criado em `dashboard/presentation/widgets/revisar_sheet.dart`:
  - `ConsumerStatefulWidget` — precisa de `ref` para chamar `simuladoRepositoryProvider`.
  - `LcfGlassSheet` com handle + título (`card.subject`) + subtítulo de desempenho (`'Você errou X% · N respondidas'`).
  - Botão "Ler resumo" → captura `GoRouter.of(context)` antes do pop, fecha sheet e navega para `/manual?subject=<encoded>`.
  - Botão "Praticar questões" → `startSimulado(mode:'custom', totalQ:10, subject:...)`, navega para `/simulados/:id` com `extra: attempt`. Trata 404 ("Ainda não há questões"), 409 ("simulado em andamento") e genérico.
- **`ManualListScreen`** recebe `initialSubject` opcional: `initState` mapeia subject → lawCode via inverso de `kLawCodeToLabel` e seta `selectedLawCodeProvider` via `addPostFrameCallback`.
- **`app_router.dart`**: rota `/manual` passa `state.uri.queryParameters['subject']` para `ManualListScreen`.
- **`simulados.service.ts`**: no ramo `mode === 'custom' && params.subject`, adicionada condição `Prisma.sql\`type = 'review'\`` ao `conditions[]` — mini-quiz puxa questões de revisão didáticas, não OAB reais.

## Arquivos modificados

- `front/lcf_app/lib/features/dashboard/presentation/widgets/revisao_inteligente_card.dart` — StatefulWidget, borda por toque, label, subtítulo, onTap→RevisarSheet
- `front/lcf_app/lib/features/dashboard/presentation/widgets/revisar_sheet.dart` — NOVO — porta dupla (LcfGlassSheet)
- `front/lcf_app/lib/features/manual/presentation/screens/manual_list_screen.dart` — initialSubject + initState filter
- `front/lcf_app/lib/core/router/app_router.dart` — passa subject query param para ManualListScreen
- `back/src/modules/simulados/simulados.service.ts` — type = 'review' no modo custom

## Critérios de aceite cumpridos

- [x] `flutter analyze` zero issues
- [x] `tsc --noEmit` zero erros
- [x] Borda dourada só aparece enquanto o card está pressionado; em repouso nenhum card fica destacado
- [x] Tap no card abre a `RevisarSheet` de vidro com os dois botões e o contexto de desempenho correto
- [x] "Ler resumo" abre o Manual já filtrado na matéria do card
- [x] "Praticar questões" inicia um simulado de 10 questões da matéria e navega para a tela de simulado em andamento
- [x] Label não exibe mais "1 questões"; subtítulo não menciona mais repetição espaçada
- [x] Mensagem amigável quando não houver questões de revisão para a matéria (404 ou NOT_FOUND)

## Pendências / Próximos passos

- ⚠️ Para "Praticar" funcionar em produção: rodar `back/scripts/promote_review_questions.js` no live (5.791 questões `type:review` estão `pending_review` no staging, ZERO no live).
- `status: pending_review` → filtro `type = 'review'` + `status = 'active'` pode ser necessário dependendo de como o promote script funciona. Verificar se o script promove para `active` ou mantém `pending_review`.

## Decisões tomadas

- `GoRouter.of(context)` capturado antes de `Navigator.of(context).pop()` nos callbacks assíncronos e síncronos da sheet — garante que a referência não fica inválida após o desmonte do modal.
- Subject → lawCode usa inverso de `kLawCodeToLabel` (já existente em `manual_models.dart`) — sem constante nova.
- Sem `build_runner` necessário — não foram criados providers Riverpod com codegen nem models Isar.
