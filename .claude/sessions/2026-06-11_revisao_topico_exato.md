# Sessão 2026-06-11 — Revisão direcionada por tópico exato

## O que foi feito

Implementada a Camada 1 do direcionamento por tópico na `RevisarSheet`:
- Backend enriquece `getRevisionCards` com `topTopics` (até 3 tópicos com mais erros)
- Flutter parseia `topTopics` de forma null-safe (backend antigo não quebra o app)
- Sheet exibe seção "Onde você mais errou" com gate PRO/Free
- "Ler resumo" navega diretamente ao tópico mais errado para usuários PRO

## Arquivos modificados

- `back/src/modules/dashboard/dashboard.service.ts` — `getRevisionCards`: adiciona `topicId` ao select, agrega erros por topicId (null ignorado), top 3 por subject, batch fetch de títulos, campo `topTopics` no response
- `front/lcf_app/lib/features/dashboard/data/models/dashboard_models.dart` — novo model `RevisionTopic { id, title, errors }`; `RevisionCard` ganha `topTopics: List<RevisionTopic>` com `@JsonKey(defaultValue: [])`
- `front/lcf_app/lib/features/dashboard/presentation/widgets/revisar_sheet.dart` — seção "Onde você mais errou" com `_TopicRow`; gate PRO/Free; `_onReadSummary` e `_onTopicTap` com lógica determinística; import `pro_gate_sheet.dart` + `dashboard_provider.dart`
- `front/lcf_app/lib/features/dashboard/data/models/dashboard_models.g.dart` — regenerado pelo build_runner
- `docs/api-contract.md` — `GET /dashboard/revision-cards` response shape atualizado com `topTopics`
- `.claude/PROJECT_STATE.md` — decisão 2026-06-11 direcionamento por tópico adicionada

## Critérios de aceite cumpridos

- [x] `tsc --noEmit` zero issues
- [x] `flutter analyze` zero issues
- [x] PRO com erros em questões review: sheet lista até 3 tópicos rankeados; tap abre o resumo exato
- [x] PRO: "Ler resumo" vai direto ao tópico mais errado quando existir
- [x] Free: linhas bloqueadas (Icons.lock_outline, textMuted) + ProGateSheet; "Ler resumo" mantém /manual?subject=
- [x] Usuário só com erros de questões OAB (topicId null): topTopics vazio, sheet idêntica à atual
- [x] Resposta antiga do backend (sem topTopics) não quebra o parsing Flutter (`@JsonKey(defaultValue: [])`)

## Decisões tomadas

- `isPro` lido via `ref.watch(dashboardDataProvider).valueOrNull?.plan == 'pro'` no `build()` (reativo); `ref.read(...)` nos handlers (callback-safe)
- `_isPro` getter usa `ref.read` — chamado apenas em handlers, nunca em `build()` direto
- Tópicos com `topicId` não encontrado na DB são filtrados silenciosamente (`filter(t => t.title !== '')`)
- Badge de erros usa `AppColors.errorBg` + `AppTextStyles.labelSmall` — zero hardcode

## Camada 2 — design registrado (não implementar agora)

Job pós-simulado/semanal PRO que envia ao Sonnet o histórico agregado (subjects, topicIds errados,
dificuldade, tendência) + lista de topicIds candidatos, recebe JSON estruturado com ranking e justificativa,
persistido em `StudyPlan`. A `RevisarSheet` e o Dashboard passam a exibir "Recomendado para você" vindo
desse plano. Encaixa na decisão fixada "Sonnet só para análise de perfil".

## Pendências / Próximos passos

- Promover questões `type:review` de `pending_review` para `active` no live (pré-requisito para topTopics aparecer em produção)
- Camada 2 (Sonnet) — implementar após validação da Camada 1 no ar
