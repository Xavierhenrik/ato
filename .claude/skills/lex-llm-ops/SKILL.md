---
name: lex-llm-ops
description: |
  Operações de LLM do LEX. Ative esta skill para qualquer tarefa envolvendo os modelos do projeto — roteamento Sabiá-4 / Sabiázinho-4 / Claude Sonnet, custo por chamada, qualidade do Tutor IA, anti-alucinação via Tool Use, evals, prompts do sistema, ou contexto de sessão.

  Acione com: "custo de LLM", "qual modelo usar", "roteamento de modelo", "Sabiá", "Sabiázinho", "Sonnet", "Tutor IA", "Tool Use", "alucinação", "prompt do sistema", "eval", "qualidade da resposta", "selectLLM", "llm.router", "adapter", ou qualquer decisão sobre modelos, custo ou qualidade de IA no LEX.

  Conhece o roteamento real do LEX e as decisões fixadas (Tool Use obrigatório, BM25 sem RAG/pgvector). NÃO propõe embeddings/vector DB no MVP. Substitui qualquer skill genérica de LLM-ops.
---

# LCF LLM-Ops

Você cuida da economia e da qualidade dos LLMs do LEX. O produto é jurídico: **alucinação = credibilidade destruída**. Toda decisão equilibra custo × qualidade × risco de alucinação — nessa ordem de prioridade quando há conflito.

---

## Passo 1 — Carregar Contexto

> Caminhos relativos à raiz do repositório (`lcf/`).

1. `CLAUDE.md` — decisões fixadas de IA (roteamento, Tool Use, sem pgvector)
2. `back/src/modules/tutor-ia/` — loop agêntico, adapters, tools, prompts
   - `adapters/llm.interface.ts`, `adapters/sabia.adapter.ts`, `adapters/claude.adapter.ts`
   - `prompts/system.prompt.ts`, `prompts/context-*.ts`
   - `tools/lookup-article.tool.ts`, `tools/search-legislation.tool.ts`
   - `services/` — `tutor.service.ts`, `context.service.ts`, `session.service.ts`, `citation.service.ts`
3. `docs/specs/LCF_ArquiteturaIA_MVP.txt` — arquitetura de IA

---

## Passo 2 — Roteamento (decisão fixada)

| Uso | Modelo | Razão |
|-----|--------|-------|
| Tutor IA (Free + PRO), pipelines, validações | **Sabiá-4 / Sabiázinho-4** (Maritaca) | ~16× mais barato; suficiente com Tool Use |
| Análise de perfil: nivelamento, study plan, weak areas | **Claude Sonnet** | chamadas raras, alta importância, personalização persistida |

Sonnet **não** é usado no Tutor. Não proponha mudar isso sem tratar como decisão de arquitetura (ADR). Roteamento vive em `selectLLM()` / `llm.router.ts`.

---

## Passo 3 — Princípios inegociáveis

1. **Anti-alucinação por Tool Use, não RAG.** O tutor cita dispositivo legal só após `lookup_article` / `search_legislation` consultarem `legal_articles`. Nunca citação direta do parâmetro do modelo.
2. **Sem pgvector / embeddings no MVP.** Busca é BM25 (`portuguese_unaccent`). RAG entra só na v1.1, como camada adicional, após validação.
3. **Sessão enxuta.** Redis TTL 4h, últimas 8 mensagens no contexto. Não inflar o contexto — custo e latência.
4. **Custo medido.** Estimar tokens/custo por chamada antes de mudar prompt ou modelo. Mudança que sobe custo precisa de justificativa de qualidade.
5. **Evals antes de trocar.** Qualquer mudança de modelo/prompt do Tutor passa por um conjunto de evals (acurácia jurídica, fidelidade da citação, ausência de alucinação) antes de ir para produção.

---

## Passo 4 — Análise e Entrega

Para pedidos de custo/qualidade: meça o real (tokens, modelo, frequência), aponte o trade-off, recomende. Para virar implementação, **delegue a `/lex-forge`** (padrão único). Não invente formato de prompt.

---

## Regra de ouro

Barato por padrão (Sabiá), caro só onde importa (Sonnet em perfil), e nunca ao custo de alucinação. Toda citação jurídica passa por Tool Use. Decisões de modelo são auditáveis (ADR + evals). Baseie tudo no código e nos números reais.
