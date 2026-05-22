# Sessão 2026-05-19

## O que foi feito

- Criado `corpus/etl-questions/scripts/enrich_topics_llm.py` — pipeline Fase 2 do Manual do Direito
- Atualizado `corpus/etl-questions/TOPICS_PIPELINE.md` com spec completa da Fase 2
- Atualizado `.claude/PROJECT_STATE.md` com status do novo script

## Arquivos modificados

- `corpus/etl-questions/scripts/enrich_topics_llm.py` — novo script (criado)
- `corpus/etl-questions/TOPICS_PIPELINE.md` — seção Fase 2 substituída pela spec completa
- `.claude/PROJECT_STATE.md` — linha do script enriquecimento adicionada na tabela de pipeline

## Decisões tomadas

- **Modelo:** Sabiá-4 (Maritaca AI) em vez de Claude Sonnet — consistente com a decisão de LLM routing do projeto (Sonnet reservado para análise de perfil; Sabiá-4 para pipelines de geração)
- **1 tópico por chamada:** simplicidade e melhor controle de qualidade por tópico (sem batching)
- **Validator temperatura 0.1:** avaliação determinística; Generator temperatura 0.4: variação criativa controlada
- **Original content no checkpoint antes de qualquer LLM call:** segurança — se o banco for atualizado e o script falhar, o conteúdo original está preservado
- **ST_FAILED → ST_PLANNED no load_checkpoint:** retry automático idêntico ao generate_review_questions.py

## Arquitetura do script

```
Agente 0 — Planner (sem LLM)
  ↓ query topics WHERE content > 100 chars
  ↓ filtra done_ids do checkpoint
  ↓ Rich table: contagem por matéria + tempo est.

Agente 1 — Generator (Sabiá-4, temp=0.4)
  input: título + law_code + content[:6000]
  output: markdown Estrutura Canônica v1.0 (6 seções)

Agente 2 — Validator (Sabiá-4, temp=0.1)
  input: resumo gerado + conteúdo original
  scoring: 0-10 pts (fidelidade 0-3 com veto se < 2)
  output: JSON { score, verdict, fidelity_score, issues }
  approved → UPDATE topics SET content = resumo WHERE id = topic_id
  reprovado → ST_FAILED → retry no próximo run
```

## Pendências / Próximos passos

- **AGUARDANDO AUTORIZAÇÃO EXPLÍCITA** para executar o script
- Comando sugerido para primeiro teste:
  ```bash
  cd corpus/etl-questions
  python scripts/enrich_topics_llm.py --target staging --dry-run
  ```
- Após dry-run validado: rodar com `--law-code CC` em staging para testar qualidade dos resumos
- Se qualidade OK: rodar completo em staging → live

## Critérios de aceite cumpridos

- [x] Script segue padrão checkpoint/resume idêntico ao `generate_review_questions.py`
- [x] State machine: planned → generating → generated → validating → done | failed
- [x] Original content salvo no checkpoint antes de qualquer chamada LLM
- [x] Validator com veto de fidelidade (fidelity_score < 2 rejeita independente do score total)
- [x] Estrutura Canônica v1.0 no system prompt do Generator (6 seções obrigatórias)
- [x] DB operation: UPDATE (não INSERT) — sem migration necessária
- [x] CLI: --target, --dry-run, --law-code, --reset, --only-plan
- [x] Rich output: painel, tabela por matéria, stats finais
- [x] Preflight: MARITACA_API_KEY, conexão DB, topics > 0, legal_articles > 0
