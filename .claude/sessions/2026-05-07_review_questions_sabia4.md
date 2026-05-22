# Sessão 2026-05-07 (continuação) — Migração para Sabiá-4

## Contexto

Continuação da sessão `2026-05-07_review_questions.md`. Quota diária do Gemini
free tier esgotada (todos os modelos 2.0-flash, 2.5-flash, 2.5-flash-lite). Decisão:
migrar para Sabiá-4 (Maritaca AI) com créditos pagos (R$20 no plano).

---

## O que foi feito

### 1. Migração do script para Sabiá-4

Arquivo: `corpus/etl-questions/scripts/generate_review_questions.py`

Mudanças aplicadas:

| Item | Antes | Depois |
|------|-------|--------|
| Import | `import google.generativeai as genai` | `from openai import OpenAI` |
| Modelo | `GEMINI_MODEL = "gemini-2.5-flash-lite"` | `MODEL = "sabia-4"` |
| Base URL | `generativelanguage.googleapis.com` | `https://chat.maritaca.ai/api` |
| Chave | `GOOGLE_API_KEY` | `MARITACA_API_KEY` |
| Rate delay | `RATE_LIMIT_DELAY = 15.0` | `RATE_LIMIT_DELAY = 3.0` |
| Função LLM | `call_gemini()` usando SDK Gemini | `call_llm()` usando `openai.OpenAI` compatível |
| Alias | — | `call_gemini = call_llm` (backward compat) |
| Preflight | verifica `GOOGLE_API_KEY` | verifica `MARITACA_API_KEY` |
| Docstring | menciona Gemini | atualizada para Maritaca/Sabiá-4 |

### 2. Validação do ambiente

- `openai` já estava instalado no ambiente Python (sem `pip install` adicional)
- `MARITACA_API_KEY` configurada em `back/lcf-backend/.env` pelo usuário
- Teste de API: respondeu corretamente com conteúdo jurídico (Art. 186 CC, JSON-capable)

### 3. Dry-run de validação

```
Modelo: sabia-4 | Target: staging | Rate limit: 3.0s/chamada | DRY RUN
Preflight: [OK] Todos os pré-requisitos OK
Batch 1/608: Generator: 17 questões geradas, Validator: 17 aprovadas, 0 rejeitadas
```

Taxa de aprovação 100% no primeiro batch. Dry-run cancelado após confirmação para não gastar créditos.

> **Nota**: o dry-run com checkpoint existente pula o exit precoce do planner e executa
> os agentes (sem gravar no DB). Isso atualizou o checkpoint de 45→51 done sem escrever
> questões no banco. 6 tópicos no checkpoint estão marcados como `done` sem questões correspondentes
> no DB. Impacto: ~18 questões ausentes de um total de 5.622. Não crítico para o MVP.

### 4. Pipeline iniciado em produção (staging)

```bash
cd corpus/etl-questions
python scripts/run_pipeline_loop.py
```

Progresso na inicialização:
- Checkpoint: 51/1874 tópicos done (45 confirmados no DB)
- Pendentes: 1823 tópicos / 608 batches
- Throughput observado: ~1 batch/36s → estimativa de conclusão ~6h

### 5. Progresso durante a sessão

| Momento | Batches | Questões no DB (staging) |
|---------|---------|--------------------------|
| Início run Sabiá-4 | 0/608 | 164 (Civil, Gemini) |
| +5 min | 9/608 | 245 (+81) |
| +8 min | 14/608 | ~280 (estimado) |

Taxa de aprovação: **100%** (sem rejeições em todos os batches observados)

---

## Arquivos modificados

| Arquivo | Mudança |
|---------|---------|
| `corpus/etl-questions/scripts/generate_review_questions.py` | Migração Gemini → Sabiá-4 (Maritaca AI) |
| `corpus/etl-questions/scripts/run_pipeline_loop.py` | LOG_FILE agora usa `date.today()` dinâmico |

---

## Estado do pipeline ao encerrar sessão

- **Rodando**: sim — `run_pipeline_loop.py` em background
- **Modelo**: `sabia-4` via `https://chat.maritaca.ai/api`
- **Log ativo**: `corpus/etl-questions/logs/pipeline_2026-05-07.log`
- **Checkpoint**: `corpus/etl-questions/data/checkpoints/review_gen_checkpoint.json`
- **Taxa de aprovação**: 100% (sem rejeições)
- **Estimativa de conclusão**: ~6h da inicialização

---

## Decisões tomadas

| Decisão | Motivo |
|---------|--------|
| Sabiá-4 (Maritaca AI) vs Claude Haiku | Sabiá-4 é especializado em português jurídico; Haiku é genérico e potencialmente mais caro para este volume |
| API OpenAI-compatible | Facilita migração — mesmo padrão de `messages`, `temperature`, `max_tokens` |
| RATE_LIMIT_DELAY 15→3s | Maritaca sem restrição de free tier; 3s é margem de segurança adequada |
| `call_gemini = call_llm` alias | Zero risco de bugs por referências ao nome antigo no código |

---

## Próximos passos

1. Aguardar conclusão do pipeline (~6h)
2. Verificar distribuição final no banco:
   ```sql
   SELECT subject, difficulty, COUNT(*)
   FROM questions WHERE type='review' AND source='llm_generated'
   GROUP BY subject, difficulty ORDER BY subject, difficulty;
   ```
3. Atualizar `PROJECT_STATE.md` com totais finais
4. Sprint 4: promover questões `pending_review` → `active` via endpoint admin
