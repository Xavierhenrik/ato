# LCF — Referência Técnica dos Pipelines de Dados

> Carregado pela skill `lcf-data` quando a tarefa exige detalhe de implementação.
> `corpus/` vive fora do repo git, na raiz do workspace `BX/LCF`, ao lado de `lcf/`.

---

## Pipeline 1 — etl-lexml (corpus jurídico)

**Local:** `corpus/etl-lexml/`
**Orquestrador:** `main.py` · **Config:** `config.py`

### Fases (ordem)
```
download → parse → validate-pre → load → validate-post
```
```bash
cd corpus/etl-lexml
python main.py --phase all                      # tudo, todos os diplomas
python main.py --phase all --diploma CTN        # um diploma só
python main.py --phase download --diploma CDC
python main.py --phase load --target supabase-staging
python main.py --phase validate-post --target supabase-live
```

### Estrutura `src/`
| Camada | Arquivo | Função |
|--------|---------|--------|
| extractor | `extractors/lexml_downloader.py` | baixa HTML compilado do Planalto; cache + MD5 |
| parser | `parsers/planalto_parser.py` | HTML → estrutura de artigos |
| parser | `parsers/hierarchy_mapper.py` | mapeia para o schema (`map_to_schema`) |
| parser | `parsers/xml_parser.py` | parsing XML lexml |
| transformer | `transformers/normalizer.py` | normalização de texto |
| transformer | `transformers/reference_builder.py` | monta referência canônica do artigo |
| validator | `validators/pre_load_validator.py` | gate antes da carga |
| validator | `validators/post_load_validator.py` | reconciliação pós-carga |
| validator | `validators/bm25_tester.py` | testa buscas BM25 |
| loader | `loaders/supabase_loader.py` | `open_run`/`load_records`/`log_audit`/`close_run` |

### Config relevante
- `BATCH_SIZE = 500`, `MAX_RETRIES = 3`, `BACKOFF_BASE = 2`
- `MIN_QUALITY_THRESHOLD = 0.80`, `PARSER_VERSION = "1.0.0"`
- `DIPLOMAS` — lista com `law_code`, `urn`, `planalto_url`, `expected_min_articles`, `effective_date`

### Schema de banco (4 tabelas)
| Tabela | Função |
|--------|--------|
| `legal_document` | catálogo dos 9 diplomas (1 row cada) |
| `legal_articles` | corpus principal (~18.779) — fora do Prisma, acesso via `$queryRaw` |
| `ingestion_run` | auditoria de cada execução |
| `source_audit` | erros/alertas por item |

### Índices
- `idx_articles_fts` — GIN sobre `content_tsv` (BM25)
- `uq_article_reference` — UNIQUE expression com `COALESCE` → idempotência de upsert com NULLs
- `idx_articles_lookup` — B-tree `(law_code, article_number, paragraph, inciso)`

### Full-Text Search
- Config `portuguese_unaccent` (extensão `unaccent` + `portuguese_stem`)
- Busca insensível a acento: `salario minimo` == `salário mínimo`
- Trigger `tsvector_upd` mantém `content_tsv` a cada INSERT/UPDATE
- Scripts: `scripts/setup_database.sql`, `scripts/fix_bm25_unaccent.sql`, `scripts/migrate_to_new_dbs.py`

---

## Pipeline 2 — etl-questions (questões + tópicos)

**Local:** `corpus/etl-questions/`

### Fases
```
extract → transform → validate-pre → load → validate-post → inspect → mark-validated
```
```bash
cd corpus/etl-questions
python main.py --phase extract                  # baixa do HuggingFace
python main.py --phase transform                # raw → staging schema
python main.py --phase load --target local
python main.py --phase load --target supabase
python main.py --phase mark-validated           # draft → validated no staging
```

### Estrutura `src/`
- `extractors/huggingface_extractor.py` — dataset `eduagarcia/oab_exams` (CC BY 4.0)
- `transformers/question_normalizer.py` — `normalize_batch`
- `validators/question_validator.py` — `validate_pre_load` / `validate_post_load`
- `loaders/local_loader.py`, `loaders/supabase_loader.py`

### Scripts de geração/manutenção
| Script | Função |
|--------|--------|
| `generate_topics_from_articles.py` | gera tópicos do Manual a partir dos artigos |
| `generate_review_questions.py` | gera questões `type: review` (entram como `pending_review`) |
| `enrich_topics_llm.py` | enriquece tópicos via LLM (`--target staging\|live`, `--dry-run`) |
| `run_pipeline_loop.py` | loop de execução com checkpoint |
| `repair_checkpoint_write_db.py` | recuperação de checkpoint |

### Targets de banco (`config.py`)
- `LOCAL_DATABASE_URL`, `DATABASE_STAGING_URL`, `DATABASE_LIVE_URL`
- psycopg2 direto, `sslmode=require`
- Schemas: `scripts/001_schema.sql`, `scripts/002_setup_supabase.sql`

### Contagens (atualizar a partir do PROJECT_STATE)
- 2.210 questões OAB reais (`type: simulado`)
- 5.791 questões de revisão (`type: review`, `status: pending_review`)
- Tópicos validados (score ≥ 7/10) na tabela `topics`

---

## Regras transversais

1. **Staging → valida → live.** Nunca carregar live sem validate-post OK em staging.
2. **Idempotência** por chave natural; rodar 2× não duplica.
3. **`--dry-run` obrigatório** antes de qualquer geração/enriquecimento por LLM; logar em `logs/`.
4. **Auditoria** via `ingestion_run` + `source_audit` em toda execução.
5. **Roteamento de LLM:** Sabiá-4/Sabiázinho-4 padrão; Sonnet só onde a decisão fixada permite.
6. **Questões geradas** entram `pending_review`; promoção só após validação.
7. **Dados ficam no banco**, não no git. Versionar só o código do pipeline.
