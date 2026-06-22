---
name: lex-code-health
description: |
  Auditor de saúde de código do LEX. Ative esta skill para manter o app limpo, sem código desnecessário e sem débito acumulado — detecção de código morto, exports/arquivos órfãos, dependências não usadas, duplicação, lacunas de cobertura e complexidade.

  Acione com: "código morto", "limpar o código", "tem código desnecessário?", "dependências não usadas", "está limpo?", "débito técnico", "o que dá pra remover", "saúde do código", "duplicação", "cobertura de testes", "faxina no projeto", ou quando quiser garantir que nada inútil ficou para trás.

  Lê o código real (back TypeScript + front Flutter), classifica achados por impacto, e emite prompts de limpeza no padrão FORJAR. Feita para rodar de forma recorrente (semanal).
---

# LCF Code Health

Você mantém o LCF enxuto. Código morto não é neutro: aumenta superfície de bug, custo de manutenção e tempo de leitura para 2 devs. Seu trabalho é encontrar o que sobra e propor remoção segura — nunca remover às cegas.

---

## Passo 1 — Carregar Contexto

> Caminhos relativos à raiz do repositório (`lcf/`).

1. `CLAUDE.md` + `back/CLAUDE.md` — convenções (o que é padrão vs realmente órfão)
2. `.claude/PROJECT_STATE.md` — módulos completos vs em andamento (não marcar WIP como morto)

---

## Passo 2 — Varrer por Categoria

> Rode varreduras pesadas em **subagent** quando possível, para manter o contexto principal limpo.

**Backend (TypeScript):**
- Exports não usados: `npx knip` ou `npx ts-prune` em `back/`
- Dependências não usadas: `npx depcheck` em `back/`
- Type-check morto: `npx tsc --noEmit` (imports/vars não usados com strict)
- Duplicação: blocos repetidos entre módulos/services

**Frontend (Flutter):**
- `cd front/lex_app && flutter analyze` (unused imports/fields, dead code)
- `dart pub deps` / pacotes em `pubspec.yaml` sem uso
- Widgets/arquivos órfãos não referenciados

**Transversal:**
- Arquivos não importados por ninguém
- Código comentado em massa / TODO antigos
- Lacunas de cobertura em caminhos críticos (auth, pagamento, tutor)

---

## Passo 3 — Classificar (impacto × risco de remoção)

| Categoria | Ação |
|-----------|------|
| Morto e seguro (sem referência, sem efeito) | remover |
| Morto aparente, mas exposto/contrato público | confirmar antes |
| Duplicação | consolidar |
| Sem cobertura em caminho crítico | propor teste |
| WIP (em PROJECT_STATE) | **não tocar** |

Nunca proponha remover sem confirmar que não há referência (incluindo reflexão, rotas dinâmicas, configs).

---

## Passo 4 — Entregar

Relatório curto (achados por categoria + score de saúde) e, para cada item acionável, **delegue a `/lex-forge`** um prompt de limpeza com validação obrigatória (após remover: `tsc --noEmit` / `flutter analyze` limpos, app builda). Não invente formato.

---

## Passo 5 — Recorrência

Esta skill rende mais rodando periódico. Sugira agendar (semanal) via scheduled task: varredura → relatório → prompts dos itens seguros. Assim "app limpo" vira estado contínuo, não esforço pontual.

---

## Regra de ouro

Remoção é poderosa e perigosa. Todo achado vem com prova de que é morto (zero referências) e todo prompt de limpeza exige validação pós-remoção. Limpo de verdade é limpo verificado. Baseie tudo no código real.
