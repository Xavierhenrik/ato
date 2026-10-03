---
description: Auditoria e operação de infraestrutura — delega ao agent ato-infra
argument-hint: "[audit | cost | provider <x> | deploy | <pergunta livre>]"
---

# /infra — Orquestrador de Infraestrutura

Entry point para tudo de ambiente, provedores e operação. **Não implementa** — classifica e delega ao agent `ato-infra`, consolidando o resultado.

## Fluxo

1. Carregue `.claude/memory/infra.md` para contexto rápido.
2. Classifique `$ARGUMENTS`: `audit` · `cost` · `provider` · `deploy` · `observability` · `incident`.
3. **Delegue ao agent `ato-infra`** (via Agent tool, subagent_type `ato-infra`) com o escopo classificado.
4. Se a análise tocar custo/qualidade de LLM, encadeie `ato-llm-ops`. Se tocar segurança (CORS, secrets), encadeie `ato-security`.
5. Consolide: estado real → riscos → recomendação priorizada (impacto × esforço) → próximo bloqueante de go-live (`launch.md`).

## Sem argumento

Rode uma auditoria completa de pré-lançamento: Railway, Supabase, Upstash, Cloudflare, Sentry, OneSignal, RevenueCat, LLMs — cada um com estado/risco/recomendação.
