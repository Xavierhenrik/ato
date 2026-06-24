---
description: Início de sessão — carrega estado, classifica o pedido e delega ao agent certo
argument-hint: "[opcional: o que você quer fazer nesta sessão]"
---

# /start — Início de Sessão

Onboarding de qualquer sessão de trabalho no LEX.

## Fluxo

1. Leia `CLAUDE.md`, `.claude/PROJECT_STATE.md` e o log mais recente em `.claude/sessions/`.
2. Resuma em 3–5 linhas: onde o projeto está, pendências bloqueantes, último trabalho.
3. Se `$ARGUMENTS` descreve uma tarefa, **`lex-tech-lead`** classifica e roteia ao domain expert (`lex-infra`, `lex-backend`, `flutter-lex`, `lex-llm-ops`, `lex-security`).
4. Se não há tarefa, ofereça os próximos passos priorizados a partir do PROJECT_STATE.

## Protocolo de sessão
Início: ler estado. Fim: atualizar `PROJECT_STATE.md` + memória do domínio tocado, criar `.claude/sessions/YYYY-MM-DD_<slug>.md`, commit via `lex-versioning`.
