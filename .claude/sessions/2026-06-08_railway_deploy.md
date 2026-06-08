# Sessão 2026-06-08 — Railway: Deploy do Backend

## O que foi feito

### Problema 1 — apply_topics_fts.sql
Script SQL para índice BM25 (`content_tsv tsvector`) na tabela `topics` executado com sucesso no Supabase (staging + produção). Coluna criada, trigger ativo, índice GIN criado.

### Problema 2 — Railway Root Directory
Alterado de `/` para `/back` em Settings → Source no Railway. Sem alteração em arquivos do repo.

### Problema 3 — railway.json com builder nixpacks
Removida a linha `"builder": "nixpacks"` do `back/railway.json`. Railpack agora é o builder padrão.

### Problema 4 — Arquivos ausentes no repo
`back/` inteiro (package.json, src/, prisma/, etc.) não estava comitado. Arquivos adicionados ao git e push feito. Railpack passou a detectar o projeto corretamente.

### Problema 5 — JWT: regressão de 2026-06-07
Sessão anterior havia alterado `app.ts` de `{ public: SUPABASE_JWT_PUBLIC_KEY }` para `secret: SUPABASE_JWT_SECRET` com base na premissa incorreta de que "Supabase usa HS256". O Supabase do projeto usa ECC P-256 como algoritmo atual. Revertido para `{ public: process.env.SUPABASE_JWT_PUBLIC_KEY! }`. `SUPABASE_JWT_PUBLIC_KEY` (PEM da chave EC pública) setado no Railway.

### Problema 6 — Crash no startup: WebSocket / Node 18→20→22
`@supabase/supabase-js` inicializa `RealtimeClient` no construtor do `SupabaseClient`, que exige WebSocket nativo. Node 18 e 20 não têm WebSocket nativo estável (disponível apenas no Node 22 LTS). `package.json` alterado de `"node": ">=18.0.0"` para `"node": ">=22.0.0"`. Railpack passou a usar Node 22.x. Servidor subiu e healthcheck passou.

## Arquivos modificados

- `back/railway.json` — removido `"builder": "nixpacks"`
- `back/src/app.ts` — JWT revertido para `{ public: SUPABASE_JWT_PUBLIC_KEY }`
- `back/package.json` — `engines.node` atualizado para `>=22.0.0`

## Critérios de aceite cumpridos

- [x] Railway build passa (npm ci + prisma generate + tsc)
- [x] Servidor sobe no Node 22 sem crash
- [x] Healthcheck `/health` responde 200
- [x] Backend deployed e rodando em produção

## Pendências / Próximos passos

- Deploy da Privacy Policy em URL pública (`docs/privacy/index.html` existe)
- Obter credenciais OneSignal (App ID + API Key)
- Registrar App ID no Google Play Console

## Decisões tomadas

- **Node 22 (não ws package):** upgrade de runtime é a solução limpa. `ws` seria patch para sintoma de runtime EOL. Node 22 é LTS atual, zero custo de mudança via Railpack.
- **JWT com SUPABASE_JWT_PUBLIC_KEY:** ECC P-256 é o algoritmo atual do Supabase. Legacy HS256 existe apenas para tokens antigos. `{ public: PEM }` é o formato correto para `@fastify/jwt` com chave assimétrica.
