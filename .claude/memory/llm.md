---
domain: llm
updated: 2026-06-24
owner: ato-llm-ops
---

# Memória de LLM-Ops — ATO

> Roteamento, custo e qualidade dos modelos. Produto jurídico: **alucinação = credibilidade destruída**.
> Prioridade em conflito: qualidade/anti-alucinação > custo.

---

## Roteamento (decisão fixada)

| Uso | Modelo | Razão |
|-----|--------|-------|
| Tutor IA (Free + PRO), pipelines, validações | **Sabiá-4 / Sabiázinho-4** (Maritaca) | ~16× mais barato; suficiente com Tool Use |
| Queries diretas simples (>200 chars, verbos analíticos, art. N, nome de lei → Sabiá-4; resto → Sabiázinho-4) | heurístico em `selectLLM()` | ~5× mais barato no caso simples |
| Análise de perfil: nivelamento, study plan, weak areas | **Claude Sonnet 4.6** | chamadas raras, alta importância, personalização persistida |

- Roteamento real em `back/src/modules/tutor-ia/.../llm.router.ts` (`selectLLM()`).
- **Sonnet NÃO entra no Tutor.** Mudar isso = ADR + evals.
- Camada 2 (perfil Sonnet): `runProfileAnalysis(userId)` fire-and-forget em `POST /simulados/:id/complete` (PRO only) → persiste `weakTopics` + `analyzedAt` em `StudyPlan`.

## Custos de referência

| Modelo | Input | Output | Contexto |
|--------|-------|--------|----------|
| Sabiá-4 | R$1,00/1M | R$4,00/1M | 128k |
| Claude Sonnet 4.6 | $3,00/1M | $15,00/1M | 200k |

Custo estimado MVP do Tutor: ~$1–32/mês (30–200 MAU ativos). Maioria das queries em Sabiá.

## Anti-alucinação (inegociável)

1. **Tool Use, não RAG passivo.** Citação legal só após `lookup_article` / `search_legislation` consultarem `legal_articles` (BM25). Nunca citar do parâmetro do modelo.
2. **Sem pgvector/embeddings no MVP.** BM25 `portuguese_unaccent`. RAG só v1.1.
3. **Sessão enxuta:** Redis TTL 4h, últimas 8 mensagens. Não inflar contexto (custo + latência).
4. **Budget de tokens** por sessão: `tutor:tokens:{uuid}` (20k/sessão).
5. **Evals antes de trocar** modelo/prompt: acurácia jurídica, fidelidade de citação, ausência de alucinação.

## Arquitetura agnóstica

Ambos adapters implementam `LLMAdapter` (`adapters/llm.interface.ts`) — loop agêntico idêntico, sem bifurcação. Troca de provedor = trocar adapter, não refatorar.

## KB estática

1.883 tópicos com resumos validados (score ≥ 7/10) no modo direct — resposta instantânea, custo zero LLM para ~30% das queries. BM25 nativo (`content_tsv`); fallback silencioso se coluna ausente.

Ver também: [[infra.md]] · [[backend.md]]
