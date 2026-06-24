---
description: Planeja e executa um item de sprint — orquestra tech-lead → domain expert → verify → versioning
argument-hint: "[descrição do que implementar]"
---

# /sprint — Orquestrador de Sprint

Entry point para implementação. Classifica, delega ao domain expert, valida e fecha.

## Fluxo

1. Carregue `CLAUDE.md`, `.claude/PROJECT_STATE.md` e o log mais recente em `.claude/sessions/`.
2. **`lex-tech-lead`** classifica `$ARGUMENTS` e identifica impacto holístico + decisões fixadas aplicáveis.
3. Delegue ao domain expert: `lex-backend` · `flutter-lex` · `lex-llm-ops` · `lex-infra` (conforme o domínio).
4. O expert implementa seguindo as convenções e valida (`tsc --noEmit` / `flutter analyze`).
5. **`lex-verify`** confirma o critério de aceite com evidência.
6. **Fechamento obrigatório:** atualizar `PROJECT_STATE.md` + memória do domínio, criar log em `.claude/sessions/`, commit via `lex-versioning`.

## Regra
Respeite a cadeia de dependência entre módulos (ROADMAP seção 1) e as decisões fixadas. Prompts de implementação delegados, nunca em arquivo.
