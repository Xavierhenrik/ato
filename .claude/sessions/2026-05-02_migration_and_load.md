# Sessão 2026-05-02 — Migração de Banco + Carga de Questões OAB

## O que foi feito

### 1. Migração legal_articles (etl-lexml → novos bancos)
- Construído `corpus/etl-lexml/scripts/migrate_to_new_dbs.py` — migra os 4 tabelas do banco antigo (DATABASE_URL) para live e staging em ordem de FK
- Diagnosticado problema de conectividade: URLs de destino usavam conexão direta Supabase (`db.[ref].supabase.co:5432`) que estava bloqueada pela rede
- Corrigido `.env` do etl-lexml para Session Pooler (`aws-1-us-west-2.pooler.supabase.com:5432`)
- Migração concluída com 0 erros — contagem verificada automaticamente ao fim

### 2. Pipeline etl-questions — ajustes e carga
- **Inspect**: schema real do dataset `eduagarcia/oab_exams` identificado — colunas `question`, `choices {text, label}`, `answerKey`, `question_type`, `nullified`
- **Fixes aplicados:**
  - `config.py`: `question_type` adicionado como primeiro candidato em `SUBJECT_FIELDS`; mapeamentos ingleses adicionados ao `SUBJECT_MAP` (`ethics`, `constitutional`, `criminal`, etc.); `international` e `environmental` adicionados após verificar 55 registros não classificados
  - `question_normalizer.py`: extração de `choices.text/label` corrigida (formato real HF); filtro de `nullified: true` adicionado
  - `supabase_loader.py` + `config.py` + `main.py`: suporte a `--target supabase-live` e `--target supabase-staging` via `_resolve_url(target)`
- **Fix de schema**: `question_import_batch` no staging não tinha coluna `source_id` (CREATE TABLE IF NOT EXISTS pulou o update) — corrigido via ALTER TABLE
- **Carga realizada**: 2.210 questões em staging e live, 0 erros

## Arquivos modificados

- `corpus/etl-lexml/.env` — URLs convertidas para Session Pooler
- `corpus/etl-lexml/scripts/migrate_to_new_dbs.py` — script criado nesta sessão
- `corpus/etl-questions/config.py` — SUBJECT_FIELDS, SUBJECT_MAP, DATABASE_LIVE_URL/STAGING_URL expostos
- `corpus/etl-questions/src/transformers/question_normalizer.py` — fix choices + nullified
- `corpus/etl-questions/src/loaders/supabase_loader.py` — _resolve_url, target param
- `corpus/etl-questions/main.py` — targets supabase-live/supabase-staging, fix encoding arrow char
- `.claude/PROJECT_STATE.md` — banco de questões marcado como ✅ Concluído

## Critérios de aceite cumpridos

- [x] 18.779 artigos legais migrados para live e staging (contagem OK em ambos)
- [x] 2.210 questões OAB carregadas em live e staging, 0 erros
- [x] Distribuição por subject verificada — 15 disciplinas cobertas
- [x] Pipeline idempotente (ON CONFLICT statement_hash DO UPDATE)
- [x] Bloqueante de M5 Simulados removido

## Estado dos bancos após sessão

| Tabela | Live | Staging |
|--------|------|---------|
| legal_document | 9 | 9 |
| ingestion_run | 12 | 12 |
| legal_articles | 18.779 | 18.779 |
| questions | 2.210 | 2.210 |

## Pendências / Próximos passos

- Sprint 1 backend: M1 Onboarding, M2 Dashboard, M3 Manual, M6 Anotações, Users (todos esqueleto)
- Configurar API Keys (Anthropic + Maritaca) para testar Tutor IA
- Estimativa de custo LLMs para fase de teste: R$ 80–200

## Decisões tomadas

- Usar Session Pooler Supabase em vez de conexão direta para ambientes com firewall corporativo
- `--target supabase-live` e `--target supabase-staging` como convenção de CLI para distinguir destinos
- 925 questões com `question_type = null` aceitas como "Não classificado" (metadado ausente no dataset original, irrecuperável)
