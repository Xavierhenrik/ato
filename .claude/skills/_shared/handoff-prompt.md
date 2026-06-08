# Padrão FORJAR — Prompt de Handoff do LCF

> Fonte única do formato de prompt de implementação do LCF.
> Toda skill que SENTE (audita) ou DECIDE emite neste formato — diretamente, via `/lcf-forge`.
> Nunca criar arquivo com o prompt; entregar sempre no chat para o usuário copiar.

```
## [TIPO/ID] — título (≤6 palavras)
Origem: <skill> · Prioridade: CRÍTICO | ALTO | MÉDIO · Data: YYYY-MM-DD

### Contexto
Onde estamos no projeto; por que isso importa agora. 1–3 frases.

### Objetivo
Uma frase. Resultado observável e verificável.

### Escopo
Arquivos-alvo: caminhos relativos reais (à raiz `lcf/`).
Não tocar: o que está fora do escopo / não pode mudar.

### Implementação
Passos numerados, com arquivos e funções REAIS (lidos do código, não supostos).
Comandos exatos quando aplicável.

### Restrições
Decisões fixadas aplicáveis (citar a decisão / ADR). Ex.: Tool Use obrigatório,
BM25 sem pgvector, RevenueCat sem Stripe, monolito modular, staging antes de live.

### Validação (EVIDÊNCIA OBRIGATÓRIA)
- comando: `npx tsc --noEmit` | `flutter analyze` | `npm test` | `python main.py --phase validate-post`
- saída esperada: <descrição objetiva do que comprova sucesso>

### Critérios de aceite
- [ ] verificável objetivamente

### Fechamento OBRIGATÓRIO
- [ ] atualizar `.claude/PROJECT_STATE.md`
- [ ] criar `.claude/sessions/YYYY-MM-DD_<slug>.md`
- [ ] commit + push seguindo `lcf-versioning` (segredos nunca entram)
```

## Regras do padrão

1. **Autocontido** — quem recebe o prompt não precisa perguntar nada.
2. **Baseado no código real** — nomes de arquivo/função vêm de leitura, nunca de suposição.
3. **Evidência sempre** — sem a seção Validação com comando + saída esperada, o prompt está incompleto.
4. **Fechamento sempre** — todo prompt termina mandando atualizar estado, logar e commitar.
5. **Impacto holístico** — se a mudança toca mais de uma camada (Flutter / back / dados / IA), o Escopo lista todos os pontos.
6. **Prioridade honesta** — CRÍTICO só para o que quebra produção, segurança ou credibilidade jurídica.
