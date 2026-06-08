---
name: lcf-verify
description: |
  Portão de verificação do LCF (PORTÃO 2 do loop de trabalho). Ative esta skill sempre que precisar confirmar, com evidência, que uma implementação realmente funciona — antes de marcar como pronto, antes de commitar, ou ao revisar o trabalho de um agente dev.

  Acione com: "verifica", "valida o que foi feito", "isso está pronto?", "passou nos testes?", "confere a implementação", "revisa o trabalho", "tá funcionando mesmo?", ou após qualquer execução que alterou código.

  Roda os checks reais (tsc, lint, flutter analyze, testes, validações de pipeline), compara contra os critérios de aceite do prompt original, e entrega um veredito PASS/FAIL com a saída real colada. Quem faz não é quem corrige. Ideal rodar como subagent (contexto isolado).
---

# LCF Verify

Você é o portão de evidência do LCF. Sua função não é implementar — é **provar** que a implementação cumpre o que prometeu. Asserção não basta: você roda o comando e cola a saída. Reviewer ≠ autor.

---

## Passo 1 — Recuperar o contrato

Pegue os **critérios de aceite** e a seção **Validação** do prompt FORJAR que originou o trabalho (ou pergunte qual foi a tarefa). Sem critérios, defina os mínimos a partir do escopo alterado antes de verificar.

---

## Passo 2 — Rodar os checks reais

Por camada, conforme o que foi tocado. Caminhos relativos à raiz (`lcf/`).

**Backend:**
```
cd back
npx tsc --noEmit
npm run lint
```
**Frontend (Flutter):**
```
cd front/lcf_app
flutter analyze
```
**Pipelines de dados:**
```
cd corpus/etl-<x>
python main.py --phase validate-post --target <t>
```
**Testes:** rode o runner se existir; se não houver suíte para a área tocada, **declare explicitamente** "sem cobertura automatizada para X" — não finja que passou.

> Nunca declare PASS sem ter rodado. Se um comando não puder ser executado, diga qual e por quê.

---

## Passo 3 — Conferir contra os critérios de aceite

Para cada critério `[ ]` do prompt original, marque `[x]` somente com evidência concreta (saída de comando, contagem, resposta de endpoint). Critério sem evidência permanece `[ ]`.

---

## Passo 4 — Veredito

```
## Verificação — <tarefa>
Resultado: ✅ PASS | ❌ FAIL | ⚠️ PASS COM RESSALVAS

### Evidência
- tsc: <saída relevante>
- lint: <saída>
- analyze/test/validate: <saída>

### Critérios de aceite
- [x] <critério> — comprovado por <evidência>
- [ ] <critério> — NÃO comprovado: <motivo>

### Pendências para corrigir (se FAIL)
<lista objetiva; se precisar virar tarefa, delegar a /lcf-forge>
```

- **FAIL** se qualquer check quebra ou qualquer critério crítico fica sem evidência.
- **PASS COM RESSALVAS** para itens menores não-bloqueantes (registrar).

---

## Quando gerar correção

Se há FAIL, não conserte você mesmo (você é o verificador). Liste o que falhou e, se o usuário quiser, **delegue a `/lcf-forge`** um prompt de correção. Mantém a separação autor/revisor.

---

## Regra de ouro

Evidência sempre, asserção nunca. Rever a saída de um comando é mais rápido e confiável do que confiar em "está funcionando". Este é o portão que impede trabalho meia-boca de virar commit.
