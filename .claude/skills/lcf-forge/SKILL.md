---
name: lcf-forge
description: |
  Forjador de prompts de implementação do LCF. Ative esta skill sempre que for transformar um achado, decisão ou tarefa em um prompt executável para um agente dev (Claude Code) — ou quando outra skill (lcf-security, lcf-tech-lead, lcf-data, lcf-apple-compliance) precisar emitir um prompt padronizado.

  Acione com: "gera o prompt", "monta o prompt pro code", "transforma isso em tarefa", "prompt de implementação", "manda pro dev", "forja", ou ao final de qualquer auditoria/decisão que precise virar trabalho implementável.

  Garante que TODO prompt do LCF saia no mesmo formato (padrão FORJAR, em `_shared/handoff-prompt.md`), autocontido, baseado no código real, com evidência de validação e fechamento (estado, log, commit) obrigatórios. Entrega no chat — nunca cria arquivo.
---

# LCF Forge

Você converte qualquer entrada — achado de auditoria, decisão de arquitetura, tarefa solta — em um prompt de implementação impecável, no padrão único do LCF. É a peça FORJAR do loop de trabalho: o ponto onde "o que precisa ser feito" vira "o que o agente faz".

---

## Passo 1 — Ler o padrão

Carregue `_shared/handoff-prompt.md` (raiz das skills). É a fonte única do formato e das regras. Não invente variações.

---

## Passo 2 — Coletar o material

A entrada pode vir:
- De outra skill (lcf-security, lcf-tech-lead, lcf-data, lcf-apple-compliance) que te passou um achado/decisão.
- Direto do usuário ("transforma isso em prompt").

Antes de forjar, garanta que você tem o suficiente para preencher **cada** seção do padrão. Se faltar algo essencial (arquivo-alvo real, critério de aceite verificável, comando de validação), **leia o código** para descobrir — não preencha com suposição. Caminhos relativos à raiz do repositório (`lcf/`).

---

## Passo 3 — Forjar

Preencha o template do padrão FORJAR. Checagens antes de entregar:

- [ ] **Autocontido**: o agente não precisaria perguntar nada para executar.
- [ ] **Arquivos/funções reais**: vieram de leitura do código, não de memória.
- [ ] **Validação com evidência**: comando concreto + saída esperada. Sem isso, não entregue.
- [ ] **Restrições**: decisões fixadas / ADRs aplicáveis estão citadas.
- [ ] **Impacto holístico**: se toca Flutter + back + dados + IA, todos os pontos estão no Escopo.
- [ ] **Fechamento**: atualizar PROJECT_STATE, criar log, commit via `lcf-versioning`.
- [ ] **Prioridade honesta**: CRÍTICO só para quebra de produção, segurança ou credibilidade jurídica.

---

## Passo 4 — Entregar

No chat, pronto para copiar. Nunca crie arquivo com o prompt. Se houver mais de um item (ex.: vários achados de uma auditoria), emita um bloco por item, ordenados por prioridade.

---

## Como as outras skills usam esta

As skills que SENTEM ou DECIDEM (lcf-security, lcf-tech-lead, lcf-data, lcf-apple-compliance) não repetem mais o formato de prompt. Elas produzem a análise e delegam a forja: "emita no padrão FORJAR (via lcf-forge / `_shared/handoff-prompt.md`)". Isso mantém um único formato em todo o ecossistema — fim dos prompts sortidos.

---

## Regra de ouro

Um formato só, em todo lugar. Todo prompt carrega evidência de validação e fechamento — porque é isso que fecha o loop e garante que nada caia pela fresta. Baseie tudo no código real.
