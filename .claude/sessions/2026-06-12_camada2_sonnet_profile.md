# Sessão 2026-06-12 — Camada 2: Análise de Perfil Sonnet

## O que foi feito

Implementada a Camada 2 do direcionamento por tópico: job pós-simulado que chama o Sonnet,
analisa o histórico de erros dos últimos 60 dias e persiste um ranking inteligente de tópicos em `StudyPlan`.
O `getRevisionCards` passa a preferir esse ranking quando está fresco (< 7 dias), mantendo a Camada 1 como fallback.

## Arquivos modificados

- `back/prisma/schema.prisma` — `StudyPlan` ganha `weakTopics Json?` + `analyzedAt DateTime?`
- `back/prisma/migrations/camada2_weak_topics.sql` — SQL migration (aplicar manualmente em staging + live)
- `back/src/modules/simulados/profile-analysis.service.ts` — novo serviço: `runProfileAnalysis(userId)`
- `back/src/modules/simulados/simulados.service.ts` — `completeAttempt` recebe `isPro` e dispara `runProfileAnalysis` fire-and-forget
- `back/src/modules/simulados/simulados.controller.ts` — `complete` passa `isPro` ao service
- `back/src/modules/dashboard/dashboard.service.ts` — `getRevisionCards` refatorado: Camada 2 path (Sonnet) e Camada 1 path (contagem); queries em `Promise.all`
- `docs/api-contract.md` — documentação das duas camadas em `GET /dashboard/revision-cards`
- `.claude/PROJECT_STATE.md` — decisão + pendências atualizadas

## Fluxo Camada 2

```
POST /simulados/:id/complete (PRO)
  → completeAttempt → mark completed → return result
  → runProfileAnalysis(userId) [fire-and-forget, não bloqueia response]
      → studyPlan.analyzedAt < 7 dias? → early return (ainda fresco)
      → SimuladoQuestion erradas dos últimos 60 dias com topicId
      → agrupa por topicId: errorCount + dominantDifficulty
      → batch fetch títulos dos topics
      → Sonnet: recebe payload (até 30 topics) → retorna { bySubject: { matéria: [{id, title, priority}] } }
      → db.studyPlan.update({ weakTopics, analyzedAt })

GET /dashboard/revision-cards
  → Promise.all([simuladoQuestions 14d, studyPlan])
  → Camada 2 fresca? → usa weakBySubject + erros reais 14d (topicErrors.get)
  → Não? → Camada 1: top3 por errorCount + batch fetch títulos
```

## Critérios de aceite

- [x] `tsc --noEmit` zero erros (após `prisma generate`)
- [x] Fire-and-forget: `runProfileAnalysis` não bloqueia response de `/complete`
- [x] Falhas silenciosas: erro Sonnet/parse/DB → função retorna sem exceção
- [x] Idempotência: `analyzedAt < 7 dias` → função retorna sem re-analisar
- [x] Camada 1 como fallback: path Camada 2 só ativo se `studyPlan.analyzedAt` é recente
- [x] Mínimo de dados: `rowsWithTopic.length < 5` → função retorna sem chamar Sonnet
- [x] Contagem de erros real: Camada 2 exibe `topicErrors.get(t.id) ?? 0` — não inventa erros
- [x] Sem mudança no contrato Flutter: `topTopics` permanece `List<RevisionTopic>` com `errors: int`

## Decisões tomadas

- Staleness de 7 dias para o perfil Sonnet — equilibra custo de API e frescor do dado
- Janela de 60 dias para o Sonnet vs 14 dias para Camada 1 — Sonnet vê padrão mais longo, Camada 1 vê recência
- Max 30 tópicos no payload Sonnet — evita context gigante; top 30 por errorCount já cobre o relevante
- `weakTopics` stored as `{ [subject]: [{id, title, priority}] }` — `title` duplicado do Topic para evitar join no read path
- Camada 2 exibe contagem real de 14 dias (não inventa "0") — UX coerente: badge mostra quanto o usuário errou recentemente

## Execução em banco (2026-06-12)

Todos os pré-requisitos de produção executados via scripts em `back/scripts/`:

| Operação | Staging | Live |
|----------|---------|------|
| Migration `weak_topics` + `analyzed_at` em `study_plans` | ✅ `apply_camada2_and_promote.ts` | ✅ |
| Questões `type:review` promovidas para `active` | ✅ 5.744 rows | ✅ 5.744 rows |
| Questões `type:review` copiadas de staging → live | — | ✅ `import_review_live_fast.ts` (282 novas, 5.462 skip) |

## Pendências / Próximos passos

- **`ANTHROPIC_API_KEY` no Railway** — já configurada (Tutor IA usa). Camada 2 ativa no próximo deploy.
- **Nenhuma pendência de código ou dados** — sistema completo end-to-end.
