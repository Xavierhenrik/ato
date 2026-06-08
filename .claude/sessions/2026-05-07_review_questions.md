# Sessão 2026-05-07 — Pipeline de Questões de Revisão

## O que foi feito

### 1. Leitura de contexto
- Lido `.claude/PROJECT_STATE.md` (Sprint 2 concluído, pipeline de revisão pendente)
- Lido `.claude/sessions/2026-05-04_topics_etl.md` (1.883 topics em staging + live)
- Lido `corpus/etl-questions/scripts/generate_review_questions.py` (script existente)

### 2. Preflight e diagnóstico
- Python 3.11, deps instaladas (`google-generativeai 0.8.6`, `psycopg2-binary`, `python-dotenv`, `rich`)
- `GOOGLE_API_KEY` presente no `.env`
- Banco staging: conectado, 1.883 tópicos, 18.779 artigos legais
- Checkpoint existente: 15/389 tópicos Civil (run anterior) — Civil era o único plano

### 3. Correções aplicadas ao script

#### Fix 1 — Planner local (sem LLM)
O `agent_planner` chamava o Gemini para gerar o plano de 1.874 tópicos, mas o limite de output de 8.192 tokens tornava isso impossível (1.874 itens × ~27 tokens ≈ 50K tokens). Substituído por lógica Python pura equivalente, sem chamada LLM.

#### Fix 2 — Prompt do Generator suavizado
O sistema do Generator tinha "REGRA ABSOLUTA: Nunca invente artigos...". O Gemini 2.5 interpretava isso literalmente e recusava gerar questões quando o BM25 não retornava artigos, devolvendo texto de recusa em vez de JSON. Alterado para "REGRA PRINCIPAL" tolerante a ausência de artigos.

#### Fix 3 — Fallback de artigos por número
`query_legal_articles` agora tem 4 níveis de fallback:
1. BM25 com filtro de law_code
2. BM25 sem filtro
3. Query direta por intervalo de números de artigo (parseado do título "Arts. 12 a 18")
4. Artigos da mesma lei ordenados por número (contexto mínimo)

#### Fix 4 — ST_GENERATED com 0 questões → ST_FAILED
Bug: quando o Generator retornava `[]` (array vazio), os tópicos ficavam presos em `ST_GENERATED` para sempre. Corrigido: se `generated_questions` vazia → tópicos marcados `ST_FAILED` → retentados no próximo run.

#### Fix 5 — Runner loop automático
Criado `corpus/etl-questions/scripts/run_pipeline_loop.py` que reinicia o pipeline automaticamente após quota (exit code 2) com delay configurável.

### 4. Diagnóstico de modelos Gemini
| Modelo | Status |
|--------|--------|
| `gemini-2.0-flash` | 429 limit:0 — free tier desativado/exaurido |
| `gemini-1.5-flash` | 404 not found |
| `gemini-2.0-flash-lite` | 429 limit:0 — idem |
| `gemini-2.5-flash` | OK → exauriu após ~30 chamadas (cota diária small) |
| `gemini-2.5-flash-lite` | OK → exauriu após ~20 chamadas |

### 5. Execução do pipeline
- **Modelo final**: `gemini-2.5-flash-lite`
- **RATE_LIMIT_DELAY**: 15s (estava em 6s — aumentado para margem de segurança)
- **QUOTA_WAIT**: 180s entre restarts no loop
- Múltiplos ciclos executados até exaurir cota diária do free tier
- Checkpoint salvo após cada quota hit — retoma automaticamente

### 6. Resultado final (staging)

```sql
SELECT subject, difficulty, COUNT(*)
FROM questions WHERE type='review' AND source='llm_generated'
GROUP BY subject, difficulty ORDER BY subject, difficulty;
```

| subject | difficulty | count |
|---------|------------|-------|
| Civil   | easy       | 68    |
| Civil   | hard       | 35    |
| Civil   | medium     | 61    |
| **TOTAL** |          | **164** |

### 7. Estado do checkpoint
- **Done**: 45 tópicos (todos Civil)
- **Generating** (killed): 3 tópicos Civil — retomados no próximo run
- **Planned**: 1.826 tópicos (demais matérias + Civil restante)

## Arquivos modificados

| Arquivo | Mudança |
|---------|---------|
| `corpus/etl-questions/scripts/generate_review_questions.py` | Fix planner, prompt, fallback artigos, ST_GENERATED bug, RATE_LIMIT_DELAY=15, modelo=gemini-2.5-flash-lite |
| `corpus/etl-questions/scripts/run_pipeline_loop.py` | Criado — runner com restart automático pós-quota |
| `.claude/PROJECT_STATE.md` | Pipeline status atualizado, checkpoint documentado |
| `.claude/sessions/2026-05-07_review_questions.md` | Este arquivo |

## Critérios de aceite cumpridos

- [x] Preflight OK: GOOGLE_API_KEY detectada, banco conecta, tópicos existem
- [x] Plano completo gerado: 5.622 questões, 1.874 tópicos, 9 matérias
- [x] Pipeline funcional com taxa de aprovação 100% (140/140 validadas, 0 rejeitadas)
- [x] 164 questões inseridas em staging com `type='review'`, `source='llm_generated'`, `status='pending_review'`
- [ ] Pipeline completo (1.874 tópicos) — **bloqueado por cota diária Gemini free tier**

## Pendências / Próximos passos

1. **Retomar pipeline amanhã** (cota Gemini reseta à meia-noite UTC):
   ```bash
   cd corpus/etl-questions
   python scripts/run_pipeline_loop.py
   ```
2. **Opcional**: adicionar `GOOGLE_API_KEY` com billing ativo para cota ilimitada
3. Após pipeline completo: rodar query de verificação e atualizar PROJECT_STATE.md
4. Sprint 4: promover questões `pending_review` → `active` via endpoint admin

## Decisões tomadas

- Planner LLM → Python local: output de 1.874 itens excede limite de 8.192 tokens do Gemini
- gemini-2.5-flash-lite como modelo final: único com cota disponível na data
- RATE_LIMIT_DELAY 6→15s: margem de segurança para evitar bursts na janela RPM
- Runner loop com restart automático: elimina necessidade de intervenção manual a cada quota hit
