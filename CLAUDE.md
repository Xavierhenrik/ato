# LEX — Contexto para Claude Code

> Leia este arquivo e `.claude/PROJECT_STATE.md` antes de começar qualquer trabalho.
> Se existir um log recente em `.claude/sessions/`, leia também.

## Arquitetura do Ambiente de IA — 4 Camadas

O setup `.claude/` segue 4 camadas (engenharia replicada do projeto Maida, 2026-06-24):

```
.claude/
├── commands/   ← 1. Entry points — orquestram, nunca implementam
├── agents/     ← 2. Domain experts isolados — model + tools + permissionMode próprios
├── skills/     ← 3. Infra de execução — chamadas pelos agents
└── memory/     ← 4. Contexto persistente por domínio — injetado nos agents
```

### 1 · Commands (`.claude/commands/`)
| Command | Orquestra |
|---------|-----------|
| `/start` | Início de sessão: carrega estado, classifica, delega |
| `/sprint` | Implementação: tech-lead → domain expert → verify → versioning |
| `/infra` | Infra: audita provedores, custo, deploy → `lex-infra` |
| `/review` | Review multidimensional: security + tech-lead + code-health |
| `/launch` | Checklist go/no-go: infra + security + apple-compliance + qa |

### 2 · Agents (`.claude/agents/`)
| Agent | Model | Mode | Domínio |
|-------|-------|------|---------|
| `lex-tech-lead` | opus | plan | Arquitetura, decisões cross-domain, orquestração |
| `lex-infra` | sonnet | plan | Railway, Supabase, Redis, LLMs (config), deploy, custo, observabilidade |
| `lex-backend` | sonnet | auto | Node/Fastify/Prisma/Redis |
| `flutter-lex` | sonnet | auto | Flutter/Riverpod/Isar/GoRouter |
| `lex-security` | opus | plan | Auth, IDOR, rate limit, LGPD |
| `lex-llm-ops` | sonnet | auto | Roteamento LLM, custo/qualidade, anti-alucinação |

### 3 · Skills (`.claude/skills/`) — execução, chamadas pelos agents
`lex-forge` (padrão FORJAR de prompts) · `lex-verify` (portão de validação) · `lex-versioning` (git) ·
`lex-code-health` · `lex-qa` · `lex-apple-compliance` · `lex-data` (ETL).

### 4 · Memory (`.claude/memory/`) — contexto persistente por domínio
`infra.md` · `backend.md` · `frontend.md` · `llm.md` · `security.md` · `launch.md`.
Cada agent carrega só a memória do seu escopo. **Memória é viva** — agents atualizam ao fim de cada trabalho.

> **Princípios:** command orquestra (nunca implementa) · model routing (opus análise / sonnet execução) ·
> permissionMode por agent (análise em `plan`, execução em `auto`) · handoff explícito (cada agent declara o que o próximo verifica) · memória de domínio isolada.

---

---

## O Projeto

**LEX** — EdTech jurídica mobile-first para estudantes de Direito e candidatos ao Exame da OAB.
Modelo freemium (Free vs PRO). MVP em ~2 meses. Alvo: 100–500 assinantes nos primeiros 6 meses.

Produto jurídico: **alucinação = perda de credibilidade imediata**. Toda decisão de arquitetura parte desse princípio.

---

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Frontend | Flutter, Riverpod, Isar (offline-first), Dio |
| Backend | Node.js 20 + TypeScript strict, Fastify 4 |
| ORM / DB | Prisma 5, PostgreSQL via Supabase |
| Cache | Redis (Upstash) |
| Auth | Supabase Auth — Google OAuth + e-mail/senha |
| LLM Análise de Perfil | Claude Sonnet — nivelamento, study plan, weak areas (chamadas raras, alta importância) |
| LLM Padrão | Sabiá-4 (Maritaca AI) — Lexia (Tutora IA), pipelines, validações (~16× mais barato) |
| Anti-alucinação | Tool Use obrigatório (`lookup_article`) — não RAG passivo |
| Sessão Lexia | Redis TTL 4h, últimas 8 mensagens |
| Busca legal | BM25 nativo PostgreSQL (`portuguese_unaccent`) — sem pgvector no MVP |
| Pagamento | RevenueCat (Apple IAP + Google Play Billing) |
| Notificações | OneSignal |
| Infra | Railway, Cloudflare CDN, GitHub Actions CI/CD, Sentry |

---

## Documentação de Referência

| Documento | Caminho | Quando ler |
|-----------|---------|-----------|
| **Roadmap Backend** | `docs/ROADMAP.md` | Antes de implementar qualquer módulo — contém sprints, critérios de aceite e contratos de API |
| **Spec MVP** | `docs/specs/LCF_Especificacao_Sistema.txt` | Requisitos funcionais completos |
| **Free vs PRO** | `docs/specs/LCF_Free_vs_PRO.txt` | Sempre que implementar feature com diferenciação de plano |
| **Arquitetura IA** | `docs/specs/LCF_ArquiteturaIA_MVP.txt` | Antes de tocar no módulo tutor-ia |
| **Histórico Lexia** | `docs/specs/TUTOR_HISTORY_SPEC.md` | Antes de tocar em persistência/histórico de sessões da Lexia |
| **Stack Infra** | `docs/specs/LCF_Stack_Infraestrutura_v1.0.txt` | Decisões de infraestrutura |
| **API Contract** | `docs/api-contract.md` | Referência de contratos |
| **Arquitetura** | `docs/architecture-overview.md` | Visão geral da arquitetura do sistema |
| **Env Setup** | `docs/env-checklist.md` | Checklist de variáveis de ambiente |
| **Testes** | `docs/TESTING_STRATEGY.md` | Antes de qualquer sessão de QA — cenários por módulo, fluxos compostos, formato de bug report |
| **Refatoração** | `docs/REFACTORING_GUIDE.md` | Antes de qualquer sessão de limpeza de código — padrões obrigatórios, anti-padrões, scripts de auditoria |
| **Estado atual** | `.claude/PROJECT_STATE.md` | Início de cada sessão |
| **Última sessão** | `.claude/sessions/` | Início de cada sessão |

---

## Estrutura do Backend

```
back/
├── prisma/schema.prisma          # 12+ modelos
├── src/
│   ├── app.ts                    # Registro de plugins e rotas
│   ├── server.ts                 # Entry point
│   ├── shared/
│   │   ├── db.ts                 # Singleton PrismaClient
│   │   ├── redis.ts              # Upstash Redis + key builders
│   │   ├── errors.ts             # AppError + factory Errors
│   │   └── middlewares/auth.middleware.ts  # requireAuth, requirePro
│   └── modules/
│       ├── auth/                 # ✅ Completo
│       ├── tutor-ia/             # ✅ Completo — loop agêntico, adapters, tools
│       ├── subscriptions/        # ✅ Completo — RevenueCat webhook
│       ├── onboarding/           # ✅ Completo — Sprint 1
│       ├── dashboard/            # ✅ Completo — Sprint 1
│       ├── manual/               # ✅ Completo — Sprint 1
│       ├── anotacoes/            # ✅ Completo — Sprint 1
│       ├── users/                # ✅ Completo — Sprint 1
│       └── simulados/            # ✅ Completo — Sprint 2
```

Para convenções de código obrigatórias (Errors factory, Zod, requireAuth, Redis keys), veja `back/CLAUDE.md`.

---

## Dados em Banco

- **`legal_articles`**: 18.779 registros (CF/88, CC, CP, CLT, CPC, CPP, CTN, CDC, Estatuto OAB). Fora do Prisma — acessar via `$queryRaw`.
- **Schema Prisma migrado**: User, Profile, StudyPlan, Subscription, Topic, TutorSession, TutorMessage, Question, SimuladoAttempt, SimuladoQuestion, Annotation, UserQuestionAnswered.
- **Questões (M5)**: 2.210 questões OAB reais (`type: simulado`) + 5.791 questões de revisão geradas (`type: review`, `status: pending_review` — aguardando promoção via SQL ou endpoint admin Sprint 4).

---

## Decisões Fixadas — Não Questionar no MVP

| Decisão | Motivo |
|---------|--------|
| Tool Use, não RAG | Referências legais são exatas; BM25 supera semântica para lookup de artigos |
| Sem pgvector no MVP | Entra na v1.1 como camada adicional após validação |
| Sem memória entre sessões da Lexia | Roadmap v2.0 |
| RevenueCat, sem Stripe in-app | Removido do escopo |
| Sign in with Apple obrigatório | Guideline 4.8 — exigido pois Google OAuth está presente |
| Monolito modular | Simples para 2 devs; migração para microserviços apenas se escalar |
| LLM Routing — Sonnet só para análise de perfil | Sabiá-4 cobre Lexia (Free+PRO), pipelines e validações; Sonnet reservado para nivelamento, study plan e weak areas — chamadas raras com impacto na personalização persistida |
| Free generoso sem trial separado | Conversão por bloqueio contextual (15 questões/dia) supera timer artificial; Free usa Sabiá-4 (Lexia), PRO usa Sonnet nas análises de perfil |
| PRO: R$29,90/mês · R$249,90/ano | Grade store Apple/Google; anual em destaque (badge "Economize 30%"); break-even a ~30 assinantes |
| Textos do Manual — estrutura canônica v1.0 | 6 seções obrigatórias (fundamento → artigos centrais → exemplo prático → atenção → OAB → resumo); threshold validador 7.0/10; fidelidade veto se < 3/4 |

---

## Protocolo de Sessão

### Ao iniciar uma sessão
1. Leia `.claude/PROJECT_STATE.md`
2. Leia o log mais recente em `.claude/sessions/` (se houver)
3. Confirme com o usuário o escopo antes de codificar
4. Para qualquer módulo: leia a seção correspondente em `docs/ROADMAP.md` primeiro

### Ao finalizar uma sessão
1. **Atualize** `.claude/PROJECT_STATE.md` — tabela de status dos módulos e qualquer decisão nova
2. **Crie** `.claude/sessions/YYYY-MM-DD_HH.md` com o log da sessão

### Template de log de sessão

```markdown
# Sessão YYYY-MM-DD HH:MM

## O que foi feito
-

## Arquivos modificados
- path/to/file.ts — descrição da mudança

## Critérios de aceite cumpridos
- [ ] descrição do critério

## Pendências / Próximos passos
-

## Decisões tomadas
-
```

---

## Integração com Obsidian

A pasta `.claude/` é um vault Obsidian válido. Para ativar:
1. Abra o Obsidian → "Open folder as vault" → selecione a pasta `.claude/` na raiz do repo
2. Os arquivos `PROJECT_STATE.md` e `sessions/*.md` ficam visíveis como notas
3. Use templates do Obsidian apontando para `.claude/sessions/` para criar logs com um clique

Alternativamente, aponte o vault para a raiz do repo e todos os docs do projeto ficam navegáveis juntos.

---

## Agentes Autônomos (roadmap)

Cada módulo do backend é autocontido por design (ver seção 2 do ROADMAP). Para rodar um agente autônomo em um módulo:

```bash
# Exemplo: agente trabalhando no M1 Onboarding
claude --print "Implemente o Sprint 1 · M1 conforme docs/ROADMAP.md. \
  Leia CLAUDE.md e back/CLAUDE.md antes de codificar. \
  Ao finalizar, escreva o log em .claude/sessions/ e atualize PROJECT_STATE.md."
```

Pré-requisito para agentes autônomos: todos os critérios de aceite do módulo anterior devem estar marcados como `[x]` em PROJECT_STATE.md.
