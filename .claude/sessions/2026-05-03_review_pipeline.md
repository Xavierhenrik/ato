# Sessão 2026-05-03 — Pipeline de Geração de Questões de Revisão

## O que foi feito

### 1. Decisão arquitetural: mesma tabela, discriminadores de tipo
- Questões de revisão entram na tabela `questions` (mesma das OAB), com 4 novos campos:
  `type` ("simulado"|"review"), `source` ("oab_exam"|"llm_generated"),
  `topic_id` (FK → Topic), `status` ("active"|"pending_review"|"rejected")
- Separar em tabela distinta quebraria `UserQuestionAnswered`, Dashboard analytics e `weak_areas`
- Todos os módulos existentes (M5, Dashboard) filtram por `type` — sem interferência

### 2. Decisão arquitetural: 3 agentes Claude claude-sonnet-4-6
- Agente 0 Planner (1 chamada): plano equilibrado por subject/difficulty antes de gerar
- Agente 1 Generator (3 tópicos/chamada = 9 questões): BM25 em legal_articles + exemplares OAB
- Agente 2 Validator (mesmo batch): score 0-10, mínimo 7 para aprovação
- Todos Sonnet — sem Haiku — por exigência de precisão jurídica

### 3. Sistema de checkpoint resiliente
- Estado persiste em `data/checkpoints/review_gen_checkpoint.json`
- State machine por tópico: planned → generating → generated → validating → done | failed
- Interrupção (tokens acabam, rede cai, crash): rodar novamente sem flags retoma do ponto exato
- Tópicos em estado intermediário (generating/validating) fazem retry automaticamente

### 4. Integração com ecossistema existente
- Reutiliza padrão de conexão do `supabase_loader.py` (psycopg2 + Session Pooler)
- Reutiliza `statement_hash` do `question_normalizer.py` para deduplicação
- BM25 usa `portuguese_unaccent` — mesmo índice do Tutor IA (`lookup_article`)
- Pipeline reutilizável: novos tópicos no Manual → rodar sem `--reset` → gera só os faltantes

## Arquivos criados/modificados

- `corpus/etl-questions/scripts/generate_review_questions.py` — script principal (~430 linhas)
- `corpus/etl-questions/REVIEW_QUESTIONS_PIPELINE.md` — documentação do pipeline
- `corpus/etl-questions/requirements.txt` — adicionado `anthropic>=0.40.0`
- `.claude/PROJECT_STATE.md` — registrado pipeline e dependências

## Critérios de aceite cumpridos

- [x] Script resiliente com checkpoint/resume funcional
- [x] 3 agentes com responsabilidades distintas e prompts especializados
- [x] Preflight automático verifica migration, API key, Topics e legal_articles
- [x] Integração documentada com M3 (topicId), M5 (type filter), Dashboard (analytics)
- [x] Documentação registrada na cadeia documental do projeto

## Pendências / Próximos passos

- [ ] Aplicar migration (junto com Sprint 1): 4 campos em `Question` + FK `topicId → Topic`
- [ ] Implementar M3 Manual com Topics populados (Sprint 1)
- [ ] Rodar `--dry-run` em staging para validar plano de distribuição
- [ ] Rodar `--subject Civil --target staging` como piloto antes do run completo
- [ ] Endpoint admin de promoção `pending_review → active` (Sprint 4 Hardening)

## Decisões tomadas

- Todos os agentes usam claude-sonnet-4-6 (sem Haiku) — precisão jurídica é inegociável
- Batching: 3 tópicos por chamada Generator (9 questões) + Validator no mesmo batch → ~335 chamadas total para 1.500 questões
- Questões reprovadas pelo Validator não entram no banco (descartadas, não ficam em 'rejected')
- 'rejected' no banco é reservado para reprovação humana na revisão pós-geração
- Pipeline roda fora do Cowork (script autônomo) para não depender de sessão ativa
