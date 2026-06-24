---
description: Review multidimensional do diff/módulo — segurança + code health + arquitetura
argument-hint: "[arquivo, módulo ou diff a revisar]"
---

# /review — Orquestrador de Review

Review cross-domain antes de merge/lançamento.

## Fluxo

1. Identifique o alvo (`$ARGUMENTS` ou o diff atual via `git diff`).
2. Em paralelo, acione as lentes relevantes:
   - **`lex-security`** — auth, injeção, IDOR, rate limit, LGPD, CORS/secrets.
   - **`lex-tech-lead`** — arquitetura, decisões fixadas violadas, impacto holístico.
   - skill **`lex-code-health`** — anti-padrões, duplicação, utilities compartilhadas.
3. Consolide os achados deduplicados, ordenados por severidade. CRÍTICO só para o que quebra produção/segurança/credibilidade jurídica.
4. Para cada achado acionável, gere o prompt de correção via **`lex-forge`** (padrão FORJAR).

## Saída
Lista priorizada de achados (severidade, arquivo:linha, correção sugerida). Não aplica correções automaticamente — entrega para decisão.
