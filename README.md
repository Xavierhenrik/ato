# ATO

App de preparação para a OAB e para estudantes de Direito: manual curado, simulados, dashboard e a Lexia, tutora com IA que só cita artigo de lei que existe no corpus.

Produto jurídico: alucinação é perda de credibilidade imediata. Toda decisão de arquitetura parte disso.

Nomes antigos: LCF (até 18/06/2026) e LEX (até 03/10/2026). Logs e fases antigas usam o nome da época.

## Mapa do repositório

```
.
├── back/              API Node 20 + TypeScript + Fastify + Prisma (monolito modular)
├── front/ato_app/     App Flutter (Riverpod, Isar offline-first, Dio, GoRouter)
├── front/docs/        Telas, tokens de design, blueprint do front
├── docs/              Arquitetura, contrato da API, roadmap, specs, checklist de env
├── scripts/           setup.ps1 (primeira vez) e run.ps1 (rodar o app)
├── CLAUDE.md          Contexto e regras para o Claude Code
└── .claude/           Setup completo do Claude (ver abaixo)
```

Fora deste repositório:

| Peça | Onde | Estado |
|---|---|---|
| ETL do corpus de lei (Planalto/LexML para Postgres) | `Xavierhenrik/ETL-pipeline` | repo próprio |
| ETL de questões OAB (dataset `eduagarcia/oab_exams`) | só na máquina do Henrique | sem git, pedir a ele |

Os dois ETLs já rodaram: 18.779 artigos de 9 diplomas e 2.210 questões estão nos bancos.

## Stack e infraestrutura

| Camada | Tecnologia |
|---|---|
| App | Flutter 3.x (Android, iOS, web, Windows) |
| API | Node 20, Fastify 4, Prisma 5, TypeScript strict |
| Banco | Supabase Postgres (projetos `live` e `staging`), busca BM25 nativa |
| Cache e sessão | Upstash Redis (`REDIS_MODE=memory` para dev local sem Upstash) |
| LLM | Sabiá-4 (Maritaca) na maior parte, Claude Sonnet no resto, com Tool Use para citar artigos |
| Deploy da API | Railway (`back/railway.json`) |
| Pagamento | RevenueCat (exigência da App Store) |

Detalhes: `docs/architecture-overview.md` e `docs/api-contract.md`.

## Rodando

**App:** na raiz, `.\scripts\setup.ps1` uma vez e depois `.\scripts\run.ps1`. O setup pede dois valores que o Henrique precisa te passar.

**API:**

```bash
cd back
npm install
cp .env.example .env    # preencher conforme docs/env-checklist.md
npm run db:generate
npm run dev
```

Segredos que você precisa receber (nunca vão para o git): `DATABASE_URL`, chaves do Supabase, Upstash, `ANTHROPIC_API_KEY`, `MARITACA_API_KEY`, RevenueCat. Lista completa em `docs/env-checklist.md`.

**Verificação antes de commitar:**

```bash
cd back && npx tsc --noEmit && npm run lint
cd front/ato_app && dart run build_runner build --delete-conflicting-outputs && flutter analyze
```

## Trabalhando com o Claude Code

O setup do Claude está todo versionado em `.claude/`, em 4 camadas:

```
commands/  entrada: /start, /sprint, /infra, /review, /launch  (orquestram, não implementam)
agents/    especialistas: ato-tech-lead, ato-backend, flutter-ato, ato-infra, ato-security, ato-llm-ops
skills/    execução: ato-forge, ato-verify, ato-versioning, ato-code-health, ato-qa, ato-data, ato-apple-compliance
memory/    contexto por domínio (backend, frontend, infra, llm, security, launch), atualizado pelos agents
```

Fluxo de uma sessão:

1. Abrir o Claude Code na raiz e rodar `/start`: ele lê `CLAUDE.md`, `.claude/PROJECT_STATE.md` e o último log.
2. Para implementar, `/sprint`: tech-lead classifica, o especialista executa, `ato-verify` valida, `ato-versioning` commita.
3. Ao fechar, o hook `Stop` cobra log em `.claude/sessions/` e árvore limpa.

| Arquivo | Para quê |
|---|---|
| `.claude/PROJECT_STATE.md` | estado vivo do projeto, fase por fase. Comece por aqui |
| `.claude/sessions/` | log de cada sessão desde maio/2026, histórico de como cada decisão nasceu |
| `.claude/settings.json` | permissões e hook compartilhados. `settings.local.json` é por máquina e fica fora do git |

## Branches

| Branch | O quê |
|---|---|
| `main` | linha principal; push pode disparar deploy no Railway, combinar antes |
| `chore/rename-ato-identidade` | troca o identificador do app para `com.bx.ato.app`. Só aplicar depois de criar o app no Firebase (`google-services.json` novo) e o redirect `com.bx.ato.app://auth-callback` no Supabase |

## Pendências abertas

- Preço do PRO não decidido (bloqueia RevenueCat e o módulo PRO).
- Identidade do app (branch acima).
- Deploy por push no Railway: confirmar comportamento antes de mexer na `main`.
- Roadmap completo: `docs/ROADMAP.md`.

Contato: Henrique, dev.henriquexavier@gmail.com.
