# Sessão 2026-10-03: limpeza do workspace e rename para ATO

## O que foi feito
- Auditoria arquivo a arquivo do workspace antigo (`D:\projetos\BX\LCF`); dossiê em `D:\projetos\vida\pesquisa\ato-2026-10\`
- Main local avançada por fast-forward com o setup de 4 camadas (`657968d`)
- Limpeza no repo: 5 skills que duplicavam os agents, `back/scripts` e `apply_sprint4.js` (uso único, 3 com senha do banco), `ManualTutorSheet` sem import, captura e relatório de build rastreados, README template, prompt da F8, launch aninhado
- Rename LCF/LEX para ATO no conteúdo, nos arquivos, nos agents e skills, nas specs e no nome exibido do app; Lexia continua como nome da tutora
- Identidade do app (`com.bx.ato.app`, deep link) commitada em branch própria, sem aplicar
- `setup.ps1` e `run.ps1` trazidos para `scripts/`
- Pastas: repositório para `D:\projetos\ato\main`, ETL para `D:\projetos\ato\etl\`, documentos históricos e de negócio para `D:\projetos\ato\_acervo\`; camada de setup antiga da raiz e lixo para a Lixeira do Windows

## Arquivos modificados
- `front/lex_app/` → `front/ato_app/` (package `ato_app`, 13 arquivos `lex_*.dart` → `ato_*.dart`, classes `Lex*` → `Ato*`)
- `.claude/agents/*`, `.claude/skills/*`: `lex-*` → `ato-*`, `flutter-lex` → `flutter-ato`; `ato-qa` ganhou frontmatter
- `docs/specs/LCF_*.txt` → `docs/specs/ATO_*.txt`
- `back/package.json`, `back/src/server.ts`, `back/src/modules/tutor-ia/prompts/system.prompt.ts`: nome ATO
- `back/test-llmops.ts` → `back/test/test-llmops.ts`
- `.claude/launch.json`: `cwd` relativos à raiz do repo
- `scripts/setup.ps1`, `scripts/run.ps1`: novos no repo, apontando para `front/ato_app` e `.ato-env`

## Critérios de aceite cumpridos
- [x] `dart run build_runner build --delete-conflicting-outputs` sem erro
- [x] `flutter analyze`: zero erro (1 info de `anonKey` depreciado, anterior ao rename)
- [x] `npx tsc --noEmit` e `npm run lint` zero
- [x] `npx tsx test/test-llmops.ts`: 37/37
- [x] grep de `LCF`/`LEX`/`lcf_`/`lex_` vivo zero fora de histórico, IDs da R2b e URLs externas
- [ ] build Android com a identidade nova: depende do `google-services.json` de `com.bx.ato.app`

## Pendências / Próximos passos
- Firebase: app Android `com.bx.ato.app` com SHA-1; trocar `google-services.json`; aí juntar `chore/rename-ato-identidade`
- Supabase (2 projetos): redirect `com.bx.ato.app://auth-callback`; rotacionar a senha do Postgres
- Push das branches e rename do repositório no GitHub (`lex` → `ato`), só com OK do Henrique
- Privacy URL do app (`github.io/LCF/privacy/`) responde 404: escolher hospedagem
- WIP fora dos commits: Redis em memória (`back/src/shared/redis.ts`, `memory-redis.ts`), `.metadata`, `pubspec.lock`, gerados do Windows

## Decisões tomadas
- LCF e LEX viram ATO; histórico (sessões, git, linhas datadas do PROJECT_STATE) fica com o nome da época
- Identidade `com.bx.ato.app` nas duas plataformas, aplicada só depois dos passos externos para não quebrar o build
