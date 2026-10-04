---
updated: 2026-10-03
sprint: "Limpeza do workspace e rename definitivo LCF/LEX para ATO"
---

# ATO — Estado do Projeto

> Atualizado pelo Claude ao fim de cada sessão de trabalho.
> Para detalhes de implementação de cada módulo, ver `../docs/ROADMAP.md`.
> Nome do produto: ATO desde 2026-10-03 (LCF até 18/06, LEX até 03/10). As fases abaixo da 5
> mantêm o nome da época em que foram registradas.

---

## Fase 5: Limpeza e rename para ATO 🔄 Em andamento (2026-10-03)

**Objetivo:** tirar o que morreu, dar ao produto o nome definitivo e deixar o repositório
pronto para adotar o núcleo do unified.

**Resultado até aqui:**
- Main local avançada por fast-forward com o setup de 4 camadas (`657968d`); trabalho na branch `chore/rename-ato`, sem push
- Removidos: 5 skills que duplicavam os agents, `back/scripts` de uso único (3 com senha do banco), `ManualTutorSheet` sem import, captura e relatório de build rastreados
- `lex-qa` ganhou frontmatter; `test-llmops.ts` foi para `back/test/`
- Rename de conteúdo: app `front/ato_app` (package `ato_app`), widgets `Ato*`, agents e skills `ato-*`, specs `ATO_*.txt`, strings de UI; Lexia continua como nome da tutora

- Nome exibido ATO no Android, iOS, web e Windows; `setup.ps1` e `run.ps1` em `scripts/`
- Pastas: repositório em `D:\projetos\ato\main`, ETL em `D:\projetos\ato\etl\` (`lexml`, `questions`), acervo em `D:\projetos\ato\_acervo\`

**Pendente:** identidade do app pronta na branch `chore/rename-ato-identidade`, para aplicar depois do app Android `com.bx.ato.app` no Firebase (com `google-services.json` novo) e do redirect `com.bx.ato.app://auth-callback` no Supabase; senha do Postgres a rotacionar (estava em scripts commitados); push das branches.
Auditoria e plano completos: `D:\projetos\vida\pesquisa\ato-2026-10\`. Log: `sessions/2026-10-03_limpeza_rename_ato.md`.

---

## Fase 4: Setup `.claude` em 4 camadas ✅ Concluída (2026-06-24)

**Objetivo:** Replicar a engenharia do projeto Maida — commands/agents/skills/memory — e criar
um guardião de infraestrutura para o pré-lançamento.

**Resultado:**
- **Memory** (novo): 6 arquivos de contexto por domínio — `infra`, `backend`, `frontend`, `llm`, `security`, `launch`
- **Agents** (novo): 6 domain experts isolados — `lex-tech-lead` (opus), `lex-infra` (NOVO), `lex-backend`, `flutter-lex`, `lex-security` (opus), `lex-llm-ops`
- **Commands** (novo): `/start`, `/sprint`, `/infra`, `/review`, `/launch`
- **Skills**: mantidas como infra de execução (forge, verify, versioning, code-health, qa, apple-compliance, data)
- `CLAUDE.md` raiz documenta a arquitetura de 4 camadas
- `lex-infra` é o guardião de Railway/Supabase/Upstash/LLMs/observabilidade com independência para sugerir melhorias e troca de provedor; mantém análises de desempenho em `memory/infra.md`

**Próximo passo:** rodar `/infra` (auditoria de pré-lançamento) e `/launch` (checklist go/no-go).

---

## Fase 3: Skills 100% LCF ✅ Concluída (2026-06-08)

**Objetivo:** Roster de skills 100% LCF-específico, sem genéricas, versionado.

**Resultado:**
- 4 skills adicionadas: `lcf-backend`, `lcf-verify`, `lcf-llm-ops`, `lcf-code-health`
- 2 skills genéricas removidas: `senior-backend`, `llm-ops`
- Roster final (12 entradas): `_shared`, `flutter-lcf`, `lcf-apple-compliance`, `lcf-backend`,
  `lcf-code-health`, `lcf-data`, `lcf-forge`, `lcf-llm-ops`, `lcf-security`, `lcf-tech-lead`,
  `lcf-verify`, `lcf-versioning`
- Commit `6fe9a3a` — push concluído, working tree clean

---

## Fase 0: Portabilidade — Ambiente de IA ✅ Concluída (2026-06-08)

**Objetivo:** Versionar todo o working tree (`.claude/`, `front/`, `docs/`) no GitHub para que
clonar no note + copiar `.env` manualmente = ambiente completo.

**Resultado:**
- `.claude/` (skills, hooks, sessions, settings.json, PROJECT_STATE.md, launch.json) rastreado no remoto
- `front/lex_app/` e `docs/` adicionados ao repo
- `.gitignore` corrigido: cobre `android/build/` e `ios/build/` do Flutter
- Nenhum `.env` nem `settings.local.json` commitado (validado com `git ls-files`)
- 4 commits feitos, push concluído — working tree limpo

**Próximo passo:** configurar Railway (Root Directory: `back`), depois Railway deploy.

---

## Sprint Atual: Sprint 4 — Hardening & Integração ✅ Completo

**Objetivo:** Backend production-ready. Segurança, performance, health check, API contract sync.

**Pré-requisito atendido:** Sprints 1–3 concluídos.

---

## Status dos Módulos

| Módulo | Status | O que falta | Sprint |
|--------|--------|-------------|--------|
| **Auth** | ✅ Completo | — | — |
| **Tutor IA (M4)** | ✅ Completo | — | — |
| **Subscriptions** | ✅ Completo | — | — |
| **M1 — Onboarding** | ✅ Completo | — | 1 |
| **M2 — Dashboard** | ✅ Completo | — | 1 |
| **M3 — Manual** | ✅ Completo | — | 1 |
| **M6 — Anotações** | ✅ Completo | — | 1 |
| **Users** | ✅ Completo | — | 1 |
| **M5 — Simulados** | ✅ Completo (bug response field names — FIXED) | — | 2 |
| **Push Notifications** | ✅ Completo (aguardando credenciais) | NotificationsService implementado com graceful degradation. Credenciais OneSignal pendentes. | 3 |
| **Sprint 4 — Hardening** | ✅ Completo | — | 4 |
| **Histórico Tutor (M4.1 + F10a)** | ✅ Completo | Migration `tutor_history.sql` aplicada no banco live (coluna `title` + index). Flutter: tela de histórico funcionando, UI glass padronizada. | — |
| **Google Sign-In Nativo** | ✅ Funcionando no emulador | SDK nativo `google_sign_in` + `signInWithIdToken` Supabase OK. Causa raiz resolvida: Supabase tinha Web Client ID errado (`330102139110-slj...`) — corrigido para `582625704045-pvsmv7...`. SHA-1 debug registrado: `A9:03:BB:6C:8B:BB:F9:11:9B:E4:E6:51:D0:70:6A:24:F6:B3:1F:99`. | — |

---

## Critérios de Aceite — Sprint 1

### M1 Onboarding
- [x] `POST /onboarding/complete` com `graduation_start` retorna `flow: "graduation"`, `nivelamentoPendente: true`
- [x] `POST /onboarding/complete` com `oab_prep` retorna `flow: "oab"`, `nivelamentoPendente: true`
- [x] `POST /onboarding/complete` com `graduation_end` gera plano com `durationDays: 90`
- [x] `nivelamentoPendente: true` setado para TODOS os perfis (não só OAB)
- [x] `POST /onboarding/diagnostic/complete` seta `nivelamentoPendente: false` e `nivelamentoConcluido: true`
- [x] `POST /onboarding/diagnostic/dismiss` seta `nivelamentoPendente: false`, `nivelamentoConcluido` permanece `false`
- [x] Dismiss após complete não sobrescreve `nivelamentoConcluido: true` (idempotência)

### M2 Dashboard
- [x] `GET /dashboard` retorna todos os campos (name, plan, oabMode, nivelamentoPendente, streak, dailyProgress)
- [x] `oabMode: true` somente para `academicPhase === "oab_prep"`
- [x] `GET /dashboard/revision-cards` retorna cards (vazio sem histórico)
- [x] `GET /dashboard/performance` retorna `bySubject` com todos os subjects respondidos

### M3 Manual
- [x] `POST /manual/topics/:id/read` chamado 2x não duplica registro
- [x] `GET /manual/topics` retorna `progress.readCount` correto por usuário
- [x] `GET /manual/topics/:id` retorna `isRead: true` após marcar como lido
- [x] `GET /manual/search?q=contrato` retorna resultados de ambas as fontes com campo `source`

### M6 Anotações
- [x] `POST /annotations` com `title`, `tags`, `subject` persiste todos os campos
- [x] `GET /annotations?subject=Constitucional` filtra corretamente
- [x] `GET /annotations?tag=prova` filtra por tag no JSON array
- [x] `GET /annotations?q=personalidade` busca em `title` e `content`
- [x] `PUT /annotations/:id` atualiza `tags` sem perder `subject`

### Users
- [x] `PUT /users/profile` com `academicPhase: "oab_prep"` atualiza `nivelamentoPath: "oab"` (nivelamentoPendente não é alterado por design — T21)
- [x] `PUT /users/profile` com `academicPhase: "graduation_start"` não altera `nivelamentoPendente`
- [x] `GET /users/profile` retorna `nivelamentoPendente` no JSON

---

## Critérios de Aceite — Sprint 2

### M5 Simulados
- [x] `POST /simulados/start` com usuário Free e `totalQ: 30` retorna `400`
- [x] Responder 15 questões com usuário Free retorna `429` na 16ª (Redis `simulado:daily:{userId}`)
- [x] `POST /simulados/:id/abandon` seta `status: 'abandoned'`, sem `completedAt`
- [x] `GET /simulados/in-progress` retorna o simulado iniciado
- [x] `POST /simulados/start` com outro simulado `in_progress` retorna `409 SIMULADO_IN_PROGRESS` com `inProgressId`
- [x] `UserQuestionAnswered` é populado (upsert) após `submitAnswer`
- [x] `GET /simulados/:id/results` com Free não retorna campo `explanation`
- [x] `GET /simulados/:id/results` com PRO retorna `explanation` em cada questão

---

## Critérios de Aceite — Sprint 3

### M4 Tutor IA (gaps PRO)
- [x] `POST /tutor/message` sempre retorna `chips` com os 4 valores do `chips.config.ts`
- [x] Com usuário PRO e `confidence: "high"`, `autoSavedAnnotationId` é retornado e a anotação existe no DB
- [x] `DELETE /tutor/session/:id` cria registro em `TutorSession` com `endedAt` preenchido

### Subscriptions Hardening
- [x] `EXPIRATION` seta `plan: "free"` no DB
- [x] `CANCELLATION` mantém `plan: "pro"` (apenas muda status)
- [x] `UNCANCELLATION` reativa com `plan: "pro"` e `status: "active"`
- [x] Todo webhook logado com `event.type` e `app_user_id`

---

## Migrations Prisma Pendentes

| Arquivo | Descrição | Status |
|---------|-----------|--------|
| ~~`back/prisma/migrations/tutor_history.sql`~~ | ~~Adiciona coluna `title text` em `tutor_sessions` + índice composto `(user_id, created_at DESC)`~~ | ✅ **Aplicada em live — 2026-06-21** |

> Migrations aplicadas:
> - Sprint 1 (2026-05-03): `sprint1_manual.sql` (staging + live)
> - Sprint 4 (2026-05-28): `apply_sprint4.js` — índices simulado_questions (staging + live)
> - Camada 2 (2026-06-12): `camada2_weak_topics.sql` — `weak_topics` + `analyzed_at` em study_plans (staging + live)
> - Histórico Tutor (2026-06-21): `tutor_history.sql` — `title` + índice composto em tutor_sessions (live)

## Débito Técnico Registrado

| Item | Impacto | Sprint |
|------|---------|--------|
| FK `simulado_questions → questions` implícita via Prisma relation | Baixo — a FK existe via Prisma ORM; `@db.Uuid` adicionado a `questions.id` resolve o type mismatch UUID/TEXT | ✅ Resolvido Sprint 4 |
| Code health Wave — 5 anti-padrões corrigidos: `lexConfirmDialog` (5 dialogs → 1 utility), `handleAsyncError` (401 centralizado), `LexGlassSheet.show()` (3 sheets), `context.bottomPad` (8 telas), catch silencioso (13 → 0) | Médio — manutenibilidade e rastreabilidade de erros | ✅ Resolvido 2026-06-19 |

---

## Decisões Externas Bloqueantes

| Decisão | Bloqueia | Status |
|---------|---------|--------|
| Pricing model PRO | Sprint 3 — RevenueCat config | ⏳ Pendente |
| Banco de questões | Sprint 2 — M5 Simulados | ✅ **2026-06-12** — 2.210 questões OAB ativas + 5.744 questões review ativas em live e staging. |
| Migration Camada 2 | Camada 2 Sonnet profile | ✅ **2026-06-12** — `weak_topics` + `analyzed_at` aplicados em staging e live via `camada2_weak_topics.sql`. |
| Topics (M3 Manual) | Pipeline generate_review_questions.py | ✅ Concluído — 1.883 topics em live + staging (2026-05-04) |
| App IDs Apple/Google | Sprint 3 — IAP + Sign in with Apple | ⏳ Pendente — **bloqueia RevenueCat (preços dinâmicos) e Apple Sign In em produção** |
| OneSignal App ID + API Key | Sprint 3 — Push | ⏳ Pendente |
| URL pública Privacy Policy | Compliance 5.1.1.i — App Store Connect | ⏳ **Aguarda lançamento.** HTML pronto em `docs/privacy/index.html`. Deploy junto com os outros deploys finais (repo privado — GitHub Pages requer plano pago). |
| Licença Apple Developer ($99/ano) | **Desbloqueia todos os itens abaixo** | ⏳ **Aguarda decisão de lançamento** — pagar só quando app estiver pronto para submeter |
| Passo 2 — Xcode: ativar capability Sign In with Apple | Compliance 4.8 | ⏳ Aguarda licença Apple + Mac |
| Passo 3 — Apple Developer Portal: Services ID + Key .p8 | Compliance 4.8 | ⏳ Aguarda licença Apple |
| Passo 3 — Supabase: ativar Apple Auth Provider | Compliance 4.8 | ⏳ Aguarda passo anterior |
| Passo 4 — App Store Connect: Age Rating 17+, conta demo, URL policy | Compliance geral | ⏳ Aguarda licença Apple |
| Passo 5 — RevenueCat: produtos IAP + REVENUECAT_APPLE_API_KEY | Compliance 3.1.1 | ⏳ Aguarda App Store Connect configurado |

---

## Roadmap Pós-MVP — 2ª Fase OAB

> Estudo aprofundado planejado antes de iniciar implementação.

### Contexto
A 2ª fase OAB é fundamentalmente diferente da 1ª: 5h de prova, 1 peça prático-profissional (45 pts)
+ 4 questões discursivas (~13,75 pts cada), em uma das ~14 especialidades (Penal, Civil, Constitucional,
Trabalho, Tributário, Empresarial, Administrativo, Previdenciário, Internacional, Ambiental, Consumidor,
ECA, Eleitoral, Digital). Avaliação por rubrica FGV, não gabarito.

### Decisões já tomadas
- `oab_phase2` no SimuladoConfig virou badge **"Em breve"** para todos os planos (2026-06-11)
- Nenhum conteúdo real de 2ª fase no banco — modo era rótulo vazio
- **Módulo 2ª fase NÃO entra no MVP de lançamento** — validar o app com 1ª fase primeiro

### O que o LCF pode oferecer (pesquisa 2026-06-11)

| Nível | O que é | Esforço | Quando |
|-------|---------|---------|--------|
| **1 — Tutor coach** | Mode "fase2" no Tutor IA com system prompt para estrutura de peças | Baixo | Sprint F10 |
| **1 — Manual filtrado** | Filtro "Área 2ª fase" — organiza 1.883 tópicos por especialidade | Baixo | Sprint F10 |
| **1 — Biblioteca de peças** | Modelos de petição inicial, HC, MS, contestação por área no Manual | Médio (curadoria) | Sprint F10 |
| **2 — Módulo completo** | Editor de texto + LLM corrige peça via rubrica FGV + discursivas | Alto | Pós-validação MVP |

### Diferencial competitivo
Nenhuma plataforma hoje oferece correção automatizada de peça com rubrica FGV via LLM.
Claude Sonnet + Tool Use é tecnicamente capaz — maior diferencial de monetização PRO para
o público de 2ª fase (motivado, disposto a pagar, mal atendido pelo mercado).

### Pendências antes de implementar
- [ ] Estudo aprofundado: rubrica FGV por área, tipos de peça por especialidade, exemplos reais
- [ ] Definir estrutura de dados: `PecaExercise`, `DiscursivaExercise`, `PecaAttempt`
- [ ] Avaliar custo por submissão (Claude Sonnet por peça) para precificação PRO
- [ ] Curadoria de banco de exercícios (provas anteriores por especialidade)

---

## Decisões Arquiteturais Registradas

| Data | Decisão | Motivo |
|------|---------|--------|
| 2026-06-19 | Utilities globais Flutter: `lexConfirmDialog` (shared/utils/lex_dialogs.dart), `handleAsyncError` (shared/utils/async_value_handler.dart), `context.bottomPad` extension (shared/extensions/context_extensions.dart), `LexGlassSheet.show<T>()` static method | Code health — 5 padrões duplicados extraídos para utilities compartilhadas; 13 catches silenciosos documentados; `Errors.upstream()` adicionada ao backend |
| 2026-06-18 | Renomeação de marca LCF → LEX: 11 widgets `lcf_*.dart` → `lex_*.dart` (classes `LcfXxx` → `LexXxx`), 27 arquivos de feature atualizados, pubspec `name: lcf_app` → `name: lex_app`, 4 strings backend (server.ts, auth.routes.ts, system.prompt.ts, profile-analysis.service.ts), back/CLAUDE.md. `.g.dart` files pendentes de regeneração via `build_runner`. Bundle ID `com.lcf.app` permanece inalterado — requer mudança manual em Android/iOS. Skill files `lcf-*` em `.claude/skills/` permanecem com prefixo antigo — renomear separadamente quando necessário. | Marca renomeada; produto passa a se chamar LEX em todo o código |
| 2026-06-12 | Histórico do Tutor v1: persistência **write-through** (`persistTurn` por turno; TutorSession lazy na 1ª msg, `id` = sessionId Redis, `title` = 1ª msg ≤ 80 chars determinístico) + endpoints `GET /tutor/history`, `GET /tutor/history/:id`, `DELETE /tutor/history/:id`. Free vê 7 dias (gate na leitura), PRO tudo. Conversas antigas **read-only** com CTA "Nova conversa sobre isso"; `mode: simulado` não persiste; sem Isar; sem cron. `persistToDB` será removido; `DELETE /tutor/session/:id` vira só encerrar (endedAt + Redis clear). Spec: `docs/specs/TUTOR_HISTORY_SPEC.md` | Modelo atual perde conversas (persistência só no DELETE explícito + fatia de 8 msgs); reidratar transcript com tool_use serializado no LLM viola anti-alucinação; read-only não fere a decisão fixada "sem memória entre sessões" (v2.0). Free 7d = alavanca de conversão barata. |
| 2026-06-11 | Revisão Inteligente vira "porta dupla": tap no card abre `RevisarSheet` (LcfGlassSheet) com **Ler resumo** (`/manual?subject=`) + **Praticar questões** (`POST /simulados/start` modo custom, subject, type:review). Borda dourada passa a ser estado de toque (não `isFirst` fixo); subtítulo "repetição espaçada" trocado por copy honesto. ✅ **IMPLEMENTADO 2026-06-11** | Reaproveita 100% do que existe (LcfGlassSheet, fluxo simulado F5, resumos M3) — sem endpoint novo, sem migration. Ativa as 5.791 questões `type:review` paradas. Card antes mentia ("X questões"=respondidas; botão Revisar caía em `/manual` sem filtro). **Depende:** promover `type:review` para `active` no live. |
| 2026-06-11 | Direcionamento por tópico determinístico na `RevisarSheet`: `getRevisionCards` adiciona `topTopics` (top 3 por erros dos últimos 14 dias em questões `type:review` com `topicId`). PRO: linhas tappáveis → `/manual/topic/:id`. Free: cadeado → `ProGateSheet`. "Ler resumo": PRO com tópicos → tópico #1; demais → `/manual?subject=`. Backend antigo (sem `topTopics`) não quebra o app (`@JsonKey(defaultValue: [])`). ✅ **IMPLEMENTADO 2026-06-11** | Join determinístico `SimuladoQuestion → Question.topicId → Topic.title` — sem LLM, sem endpoint novo, sem migration. |
| 2026-06-12 | Camada 2 — análise de perfil Sonnet: `runProfileAnalysis(userId)` disparado como fire-and-forget em `POST /simulados/:id/complete` (PRO only). Agrega erros dos últimos 60 dias por topicId → envia ao Sonnet → persiste `weakTopics Json` + `analyzedAt` em `StudyPlan`. `getRevisionCards` prefere `weakTopics` quando `analyzedAt < 7 dias`; conta de erros reais (14 dias) exibida mesmo no path Camada 2. Migration: `camada2_weak_topics.sql` (ALTER TABLE study_plans ADD COLUMN weak_topics jsonb, analyzed_at timestamptz). ✅ **IMPLEMENTADO 2026-06-12** | Sonnet só para análise de perfil (decisão fixada); fire-and-forget garante que o response de complete não é bloqueado; Camada 1 continua como fallback quando análise é velha ou inexistente. |
| 2026-06-07 | apply_topics_fts.sql executado em staging + live | KB estática do Tutor IA ativada (BM25 em 1.883 tópicos) |
| 2026-06-07 | [SECURITY] Session ownership: `tutor:session:owner:{sessionId}` vincula sessão ao userId no Redis com TTL 4h | IDOR: qualquer JWT válido conseguia ler/injetar/deletar sessão alheia via UUID. `validateOwnership` lança 403 antes de qualquer operação. |
| 2026-06-07 | JWT: `@fastify/jwt` usa `secret: SUPABASE_JWT_SECRET` (HS256 simétrico) | `SUPABASE_JWT_PUBLIC_KEY` não existe; Supabase usa HS256, não RS256. Undefined behavior se var ausente. |
| 2026-06-07 | DELETE /auth/me chama `supabaseAdmin.auth.admin.deleteUser` antes de `db.user.delete` | Sem essa chamada, JWT do usuário deletado ainda passava no `requireAuth` e o auto-provisioning recriava a conta — violação LGPD |
| 2026-06-10 | `onboarding_done` (metadata Supabase) é fonte de verdade do roteamento — sem `isNew`/`statusCode == 201` | Backend sempre retorna 200 em `/auth/verify`; redirect #3 do app_router decide onboarding vs dashboard |
| 2026-06-10 | `signInWithGoogle` usa flag `_pendingGoogleVerify` + listener `onAuthStateChange.signedIn` para chamar `verify()` | Fluxo redirect: `signInWithOAuth` retorna imediatamente, sessão estabelecida apenas quando deep link `com.lcf.app://auth-callback` retorna |
| 2026-06-10 | Sign in with Apple revertido — obrigatório pela Guideline 4.8 | Decisão "removido do escopo" foi revogada; app usa Google OAuth, portanto Apple Sign In é mandatório |
| 2026-06-07 | Apple Sign In usa Supabase `signInWithIdToken` (não endpoint customizado) | Supabase já valida tokens Apple natively; reusa o fluxo `/auth/verify` existente sem migration Prisma |
| 2026-06-07 | RevenueCat inicializado com guard (`if (_revenueCatAppleKey.isNotEmpty)`) | API key bloqueante externa; sem ela preços exibem '—' sem crash |
| 2026-06-02 | Sabiázinho-4 para queries direct simples | ~5× mais barato; heurístico: >200 chars, verbos analíticos, art. N, nome de lei → Sabiá-4; demais → Sabiázinho-4 |
| 2026-06-02 | KB estática com 1.883 tópicos no modo direct | Feature de UX (resposta instantânea) + custo zero LLM para ~30% das queries; usa BM25 nativo PostgreSQL (`content_tsv`); fallback silencioso se coluna não existir |
|------|---------|--------|
| 2026-05-01 | Setup de memória Claude Code (CLAUDE.md + hooks) | Continuidade entre sessões de IA |
| 2026-05-02 | Onboarding simplificado: 1 tela, 2 perguntas (academicPhase + dailyStudyMins) | Reduz fricção; dados reais vêm do Quiz Diagnóstico e comportamento |
| 2026-05-02 | Quiz Diagnóstico universal: dois caminhos (oab / graduation), opcional com dismiss consciente | Personalização real > autoavaliação; dismiss ≠ skip |
| 2026-05-02 | graduation_end adicionado como 4ª fase acadêmica (90 dias) | Design identificou lacuna entre graduation_mid e oab_prep |
| 2026-05-02 | studyGoal e selectedSubjects removidos do onboarding | Autoavaliação é ruído; comportamento do app é sinal |
| 2026-05-24 | Rate limits granulares por rota (`/simulados/start` 5/min, `/annotations` 30/min, `/tutor/message` 60/min) | Separar rate limit de infra (Fastify) do rate limit de negócio (Redis) | 
| 2026-05-24 | Health check sempre retorna HTTP 200 com `status: degraded` em falha | Evitar restart loops em Railway quando DB/Redis estão lentos |
| 2026-05-27 | `GET /users/profile` agora retorna `email` (User) e `plan` (Subscription) via Promise.all | Badge PRO e gates de feature na tela Perfil dependem desses campos |
| 2026-05-27 | `PUT /users/profile` aceita `dailyStudyMins` (Zod min:15 max:480) | Flutter enviava o campo; backend ignorava silenciosamente |
| 2026-05-27 | `GET /simulados/history` retorna array direto (não `{attempts:[]}`) | Alinhamento contrato real — fix crash TypeError Flutter |
| 2026-05-27 | `GET /simulados/in-progress` retorna 204 sem corpo quando vazio | Fix crash null em Flutter ao abrir app sem simulado em andamento |
| 2026-05-27 | Quantidade máxima de questões em SimuladoConfig: 100→80 | Backend valida totalQ max(80); opção 100 causava 400 sempre |
| 2026-05-27 | TutorRepository.sendMessage aceita parâmetro `mode` (default: 'direct') | Prepara extensão de contexto topico/questão sem quebrar comportamento atual |
| 2026-05-28 | Dio interceptor 401 retry removido em `api_client.dart` | Loop infinito: staging JWT rejeitado pela produção causava refresh→retry→401→refresh indefinido. Supabase Flutter SDK já gerencia refresh de token automaticamente. |
| 2026-05-28 | `LcfMarkdownBody` widget compartilhado — `shared/widgets/lcf_markdown_body.dart` | Elimina ~60 linhas de MarkdownStyleSheet duplicado entre ChatBubble e TopicSectionTile |
| 2026-05-28 | NotificationsService implementado com graceful degradation | Sem ONESIGNAL_APP_ID: sendPush retorna {success:false}, validatePlayer retorna false → PUT /notifications/player lança 400. Credenciais OneSignal ainda pendentes. |
| 2026-05-28 | Rota PUT /users/notifications/player separada de PUT /users/notifications | Evita quebrar contrato Flutter das preferências gerais; player ID tem validação UUID + OneSignal API |
| 2026-05-28 | Retry manual 401 removido do Dio interceptor (`api_client.dart`) | Loop infinito com Supabase staging JWT; SDK Flutter já gerencia refresh via `onAuthStateChange` |
| 2026-05-28 | Profile APK fix: pré-criar `aar_metadata` de profile em `build/isar_flutter_libs/` | AGP 9+ desabilita `writeProfileAarMetadata` via `whenTaskAdded`; sem o arquivo pré-criado, `checkProfileAarMetadata` falha (path not found). Rebuild após `flutter clean` requer recriar. |
| 2026-06-10 | `LcfGlassSheet` componente compartilhado — padrão de vidro translúcido sem blur | Encapsula superfície 30 %, fio dourado top, cantos 30 px. Primeiro uso: gaveta do Tutor IA no Manual (`ManualTutorOrb`). |
| 2026-06-10 | Tutor IA no Manual: orbe flutuante + gaveta de vidro substituem ⚡ por seção | Único ponto de entrada, animação orbe→âncora, stagger de pills, `LcfTutorAppBar` minimalista em modo contexto (showBack=true). |
| 2026-06-10 | Ajustes finos tutor flutuante: fio dourado vira `Border.all` no shape (topo+quinas+laterais); `ChatInputBar.backgroundColor` (transparente na gaveta); header identidade "Lex/Tutor IA" removido do `LcfTutorAppBar` modo padrão; `/tutor/context` envolto em `ScaffoldWithNav` (BottomNav visível, sessão ainda isolada via `ProviderScope`) | Acabamento visual do padrão de vidro + navegação consistente: chat aberto pelo Manual mostra BottomNav mantendo voltar "Resumo" |
| 2026-06-10 | Refino visual tutor flutuante: fio dourado do `LcfGlassSheet` vira `_GoldTrimPainter` (CustomPainter — arco esquerdo + aresta do topo + arco direito, para no fim do arredondamento; laterais/base sem dourado); gaveta com respiro lateral `AppSpacing.sm` (8px); blur `_kFrostSigma = 18` mantido | `Border.all` pintava laterais inteiras — o fio deve ser só acabamento do topo seguindo a curvatura; gaveta não encosta nos cantos do aparelho |
| 2026-06-10 | `ProGateSheet` normalizado para o padrão `LcfGlassSheet`; `LcfGlassSheet` aceita altura intrínseca (`height == null` → child dimensiona a folha, sem `Positioned.fill`) | Sheet PRO usava superfície sólida `backgroundSheet` + `Border.all` dourado integral — fora do padrão de vidro fixado hoje. Todo bottom sheet do app deve usar `LcfGlassSheet` (vidro 30 %, fio dourado no topo, respiro lateral 8px) |
| 2026-06-11 | Deep links de esquema customizado interceptados em `main.dart` via `SystemChannels.navigation` — nunca chegam ao GoRouter | CAUSA RAIZ do bug de navegação pós-OAuth: GoRouter chama `uri.origin` em `com.lcf.app://auth-callback` → `StateError` corrompe `_routeInformationProvider` permanentemente; redirect nunca rodava. supabase_flutter recebe o deep link via app_links EventChannel (caminho próprio, intacto) |
| 2026-06-11 | Telas-bottom-sheet (ex.: `/cadastro`) usam rota transparente (`_slideUpPage`: `opaque: false` + scrim em fade + slide vertical) — nunca página opaca | Vidro do `LcfGlassSheet` precisa de conteúdo real atrás para frostar (blur de fundo liso é invisível); página opaca subia inteira como parede. Login permanece pintado atrás; tap fora fecha |

---

---

## Frontend — Status dos Sprints Flutter

| Sprint | Status | Descrição |
|--------|--------|-----------|
| **F1 — Fundação + Auth + Onboarding** | ✅ Concluído (Hotfix aplicado) | `flutter analyze` zero issues |
| **F2 — Dashboard** | ✅ Concluído | 10 arquivos criados — models, repository, providers, screen, 5 widgets, router atualizado |
| **F3 — Tutor IA** | ✅ Concluído | — |
| **F4 — Manual** | ✅ Concluído | — |
| **F5 — Simulados** | ✅ Concluído | — |
| **F6 — Anotações** | ✅ Concluído | — |
| **F7 — Perfil + Assinatura** | ✅ Concluído | 12 arquivos — models, repository, provider, 5 widgets, 2 screens, router atualizado. url_launcher adicionado. `flutter analyze` zero issues |
| **F8 — Hardening + Offline** | ✅ Concluído | UI/UX pass (waves 1–4) + offline-first Isar (fallback stale, invalidateCache, pull-to-refresh 3 telas). `flutter analyze` zero issues. |
| **F9 — Quiz Diagnóstico** | ✅ Concluído | `GET /diagnostic/questions` backend + Flutter UI funcional (questões reais, progresso, avanço). `tsc --noEmit` + `flutter analyze` zero. |
| **Visual Icons Refactor** | ✅ Código concluído — aguardando SVGs em `assets/icons/` | `LexIcons` criado; 17 arquivos editados; zero analyze issues. Ver `sessions/2026-06-21_visual_icons_refactor.md` |

### Para ativar o Sprint F1 (próximos passos obrigatórios)

```bash
# 1. Scaffoldar plataformas (mantém lib/ já criado)
cd C:\Projetos\BX\LCF
flutter create --org com.lex --project-name lex_app --platforms ios,android front/lex_app

# 2. Gerar código (Riverpod, Retrofit, json_serializable)
cd front/lex_app
dart run build_runner build --delete-conflicting-outputs

# 3. Verificar
flutter analyze

# 4. Rodar (com credenciais)
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ... \
  --dart-define=API_BASE_URL=http://localhost:3000
```

---

## Log de Sessões

| Data | Arquivo | Resumo |
|------|---------|--------|
| 2026-05-01 | sessions/2026-05-01_setup.md | Setup inicial: CLAUDE.md raiz, CLAUDE.md backend, PROJECT_STATE, hooks |
| 2026-05-02 | sessions/2026-05-02_etl_questions.md | Pipeline ETL de questões OAB — corpus/etl-questions/ criado |
| 2026-05-02 | sessions/2026-05-02_migration_and_load.md | Migração legal_articles (18.779) + carga de 2.210 questões OAB em live e staging |
| 2026-05-03 | sessions/2026-05-03_review_pipeline.md | Pipeline geração questões de revisão (3 agentes Claude) |
| 2026-05-03 | sessions/2026-05-03_sprint1.md | Sprint 1 completo: M1 Onboarding, M2 Dashboard, M3 Manual, M6 Anotações, Users + migrations |
| 2026-05-03 | sessions/2026-05-03_sprint2_simulados.md | Sprint 2 completo: M5 Simulados — ciclo de vida, limites Free, features PRO, UserQuestionAnswered |
| 2026-05-04 | sessions/2026-05-04_topics_etl.md | ETL Fase 1 Topics: 1.883 topics gerados a partir de 18.779 artigos — staging + live |
| 2026-05-07 | sessions/2026-05-07_review_questions.md | Pipeline questões de revisão: 45 tópicos/164 questões geradas (Civil) — cota diária Gemini exaurida |
| 2026-05-07 | sessions/2026-05-07_review_questions_sabia4.md | Migração para Sabiá-4 (Maritaca AI) — pipeline rodando, ~6h para conclusão completa |
| 2026-05-16 | sessions/2026-05-16_sprint3_tutor_subscriptions.md | Sprint 3 completo: M4 gaps PRO (chips, auto-save, persistência sessão) + Subscriptions hardening |
| 2026-05-22 | sessions/2026-05-22_flutter_f1_foundation.md | Sprint F1: 22 arquivos Flutter criados — core/theme, router, auth, onboarding (aguardando build_runner) |
| 2026-05-22 | sessions/2026-05-22_monorepo_restructure.md | Monorepo: git mv back/ + front/docs + docs/ + .claude/ — commits 2c2df2f e d3360fc |
| 2026-06-18 | sessions/2026-06-18_emulator_fix.md | Fix tela preta emulador: Impeller desabilitado em debug + interceptor Dio retry 401 |
| 2026-06-10 | sessions/2026-06-10_tutor_flutuante_manual.md | Tutor flutuante: orbe + gaveta de vidro no Manual, LcfGlassSheet, LcfTutorAppBar context-mode |
| 2026-06-10 | sessions/2026-06-10_tutor_ajustes_finos.md | Ajustes finos tutor flutuante: borda dourada no shape, input bar transparente na gaveta, header identidade removido, /tutor/context com BottomNav. flutter analyze zero issues |
| 2026-06-10 | sessions/2026-06-10_tutor_refino_visual.md | Refino visual: fio dourado via CustomPainter (arcos + topo, sem laterais), respiro lateral 8px na gaveta. flutter analyze zero issues |
| 2026-06-10 | sessions/2026-06-10_progate_glass_normalize.md | ProGateSheet normalizado para LcfGlassSheet (vidro + fio dourado + respiro 8px); LcfGlassSheet com suporte a altura intrínseca. flutter analyze zero issues |
| 2026-05-23 | sessions/2026-05-23_sprint_f1_finalizacao.md | Sprint F1 finalização: 4 widgets novos, OnboardingDone guard, app_router reescrito, prefer_const clean — 26 arquivos auditados |
| 2026-05-23 | sessions/2026-05-23_sprint_f2_dashboard.md | Sprint F2 Dashboard: 10 arquivos Flutter — models, repository, providers, 5 widgets, dashboard_screen, router. build_runner + flutter analyze zero issues |
| 2026-05-23 | sessions/2026-05-23_sprint_f3_tutor.md | Sprint F3 Tutor IA: 11 arquivos Flutter — tutor_models, tutor_repository, tutor_provider, 7 widgets, tutor_screen, router atualizado. build_runner + flutter analyze zero issues |
| 2026-05-23 | sessions/2026-05-23_sprint_f4_manual.md | Sprint F4 Manual: 10 arquivos Flutter — manual_models, manual_repository, manual_provider, 5 widgets, 2 screens, router atualizado. build_runner + flutter analyze zero issues |
| 2026-05-23 | sessions/2026-05-23_sprint_f5_simulados.md | Sprint F5 Simulados: 13 arquivos Flutter — simulado_models, simulado_repository, simulado_provider, 7 widgets, 3 screens, router atualizado. build_runner + flutter analyze zero issues |
| 2026-05-23 | sessions/2026-05-23_review_f1_f5.md | Auditoria forense F1–F5: 80 arquivos Dart auditados em 12 fases — 5 bugs críticos (crash/placeholder/fonte), 10 findings importantes, 5 gaps vs SCREENS.md. Score 7.1/10. Sem correções — apenas relatório. |
| 2026-05-23 | sessions/2026-05-23_hotfix_f1_f5.md | Hotfix F1–F5: C1–C5 (parsing nullable, fonte Inter/GoogleFonts, placeholder produção), I1/I3–I10 (endpoints API, invalidate, catch genérico, 401 redirects, errorBg), M1/M4 (super.key, comentários). flutter analyze zero issues. |
| 2026-05-24 | sessions/2026-05-24_sprint_f6_anotacoes.md | Sprint F6 Anotações: 9 arquivos Dart criados — anotacao_models, anotacao_repository, anotacao_provider, 3 widgets (card, filter_chips, search_bar), 2 screens (lista, editor), router atualizado. build_runner + flutter analyze zero issues. |
| 2026-05-24 | sessions/2026-05-24_sprint_f7_perfil.md | Sprint F7 Perfil + Assinatura: 12 arquivos Flutter — perfil_models, perfil_repository, perfil_provider, 5 widgets (ProfileHeader, DadosPessoaisCard, SegurancaCard, LcfProBannerCard, PreferenciasCard), 2 screens (PerfilScreen, SubscriptionScreen), router atualizado, url_launcher adicionado. build_runner + flutter analyze zero issues. |
| 2026-05-24 | sessions/2026-05-24_contract_fix_simulados.md | Contract fix simulados: 4 blockers corrigidos em simulados.service.ts — enunciado/opcoes (startAttempt+getInProgress), total/correct/wrong/bySubject/questões achatadas (getResults), lista→objeto único 204 (getInProgress), totalQuestions/correctAnswers (getHistory). tsc --noEmit zero erros. |
| 2026-05-24 | — | Hotfix submitAnswer: `isCorrect` → `correct` em simulados.service.ts (field name mismatch Flutter). tsc --noEmit zero erros. |
| 2026-05-24 | sessions/2026-05-24_sprint4_hardening.md | Sprint 4 completo: rate limits granulares, índices DB, @db.Uuid, health check DB+Redis, api-contract.md atualizado. tsc zero erros. |
| 2026-05-24 | — | F8 Hardening · UI/UX pass concluído (waves 1–4): bugs críticos (ProGateSheet→/subscription, ChatBubble markdown, AppColors.success verde), perf (ListView.builder result, TextStyle static, scroll throttle), polish (InkWell+Haptics, Material3 NavigationBar, custom transitions, fake streaming, chips ShaderMask), auth (Google icon real, Lembrar-me persistente). flutter_markdown + shared_preferences adicionados. flutter analyze zero issues. |
| 2026-05-24 | sessions/2026-05-24_pipeline_retomada.md | Auditoria pipeline ETL: review_gen 1.874/1.874 done (5.791 questões pending_review), enrich_topics 1.883/1.883 done (1.890 resumos aprovados). Ambos pipelines concluídos — PROJECT_STATE atualizado. |
| 2026-05-27 | sessions/2026-05-27_sprint_f8_offline.md | Sprint F8 offline-first (Isar): fallback stale cache em ManualRepository + DashboardRepository, invalidateCache(), pull-to-refresh em 3 telas (Dashboard, Manual, Anotações), bugfix markAsRead async. flutter analyze zero issues. |
| 2026-05-27 | sessions/2026-05-27_sprint_diagnostico.md | Quiz Diagnóstico end-to-end: GET /onboarding/diagnostic/questions (backend) + DiagnosticoQuizNotifier + _AnsweringState funcional (Flutter). tsc + flutter analyze zero. |
| 2026-05-28 | sessions/2026-05-28_android_fix_markdown_refactor.md | AGP 9+ fix (isar_flutter_libs namespace+AarMetadata), LcfMarkdownBody widget compartilhado, refactor ChatBubble+TopicSectionTile, emulador configurado, usuário staging criado. |
| 2026-05-28 | sessions/2026-05-28_backend_cleanup.md | Dead code removido em dismissQuiz, nixpacks.toml deletado. tsc zero erros. |
| 2026-05-28 | sessions/2026-05-28_notifications_service.md | NotificationsService com graceful degradation, PUT /users/notifications/player, validatePlayer OneSignal. tsc zero erros. |
| 2026-05-28 | sessions/2026-05-28_verificacao_emulador.md | Verificação completa no emulador: Dashboard OK, LcfMarkdownBody bold dourado confirmado (Manual+Tutor), Dio 401 fix confirmado, profile APK 77.3MB gerado (fix metadados isar_flutter_libs). |
| 2026-06-03 | sessions/2026-06-03_llmops.md | LLM-Ops Fase 1+2: Sabiázinho-4 para direct simples + KB estática 1.883 tópicos. `tsc --noEmit` zero erros. |
| 2026-06-07 | sessions/2026-06-07_security_jwt_delete.md | CRÍTICO: JWT fixado para HS256 simétrico (`SUPABASE_JWT_SECRET`); DELETE /auth/me passa a invalidar sessão Supabase via `admin.deleteUser` antes de deletar do banco (LGPD). `SUPABASE_SERVICE_ROLE_KEY` adicionado ao `.env.example` e checklist. |
| 2026-06-07 | sessions/2026-06-07_compliance_apple.md | Apple App Store Compliance: 6 itens implementados — Privacy Policy, Consent Modal IA, Delete Account UI, Disclaimer jurídico, Sign in with Apple, RevenueCat dynamic prices. flutter analyze zero issues. |
| 2026-06-07 | sessions/2026-06-07_security_session_ownership.md | [SECURITY] AUTH-SESSION-OWN: Session ownership validation no Tutor IA — `create`, `validateOwnership`, `clear` atualizados; controller protege newSession/sendMessage/getSession/deleteSession. tsc zero erros. |
| 2026-06-07 | — | [INFRA] 61 arquivos do `back/` commitados e pusheados para origin/main (commit dcca01f). Railway agora consegue detectar Node.js e executar `npm run build`. |
| 2026-06-09 | sessions/2026-06-09_dashboard_bug_fix.md | [BUG] Dashboard 3 erros: causa raiz = `API_BASE_URL=http://localhost:3000` no emulador Android (localhost = o próprio emulador). Railway healthy (`/health` ok). Fix: PEM normalization `\n` em `app.ts`; URL Railway + instruções Flutter em `env-checklist.md`. |
| 2026-06-11 | sessions/2026-06-11_oauth_navfix_cadastro_modal.md | CAUSA RAIZ navegação pós-OAuth corrigida (interceptor SystemChannels.navigation em main.dart); cadastro vira overlay modal de vidro (rota transparente + scrim + LcfGlassSheet frostando o login); git credential fixado (Xavierhenrik). flutter analyze zero issues. |
| 2026-06-11 | sessions/2026-06-11_revisao_porta_dupla.md | Revisão Inteligente porta dupla: RevisarSheet (LcfGlassSheet), borda por toque, label correto, filtro Manual por matéria, backend type:review no modo custom. flutter analyze + tsc zero issues. |
| 2026-06-11 | sessions/2026-06-11_revisao_topico_exato.md | Camada 1: direcionamento determinístico por tópico — topTopics no getRevisionCards, RevisarSheet com gate PRO/Free, navegação /manual/topic/:id. tsc + flutter analyze + build_runner zero issues. |
| 2026-06-12 | sessions/2026-06-12_camada2_sonnet_profile.md | Camada 2: análise Sonnet persistida — profile-analysis.service.ts, fire-and-forget em completeAttempt, getRevisionCards prefere weakTopics frescos, migration SQL. tsc zero issues. |
| 2026-06-12 | sessions/2026-06-12_tutor_history_planning.md | Planejamento Histórico do Tutor: 4 decisões de produto fechadas, spec TUTOR_HISTORY_SPEC.md criada, pacote de delegação noturna (orquestrador + 3 agentes Sonnet + fix template) em temp-feat-historico/. |
| 2026-06-18 | sessions/2026-06-18_rename_lcf_lex.md | Renomeação completa LCF → LEX: 11 widgets, 27 telas/features, pubspec, backend strings, docs |
| 2026-06-19 | sessions/2026-06-19_code_health_wave.md | Code Health Wave: 4 utilities Flutter criadas (lexConfirmDialog, handleAsyncError, context.bottomPad, LexGlassSheet.show()); 17 arquivos Flutter + 3 backend corrigidos; 13 catches silenciosos documentados. flutter analyze + tsc zero issues. |





---

## Pipeline de Geração de Questões de Revisão

| Item | Status |
|------|--------|
| **Script ETL Topics** | `corpus/etl-questions/scripts/generate_topics_from_articles.py` ✅ Criado e executado |
| **Script Questões** | `corpus/etl-questions/scripts/generate_review_questions.py` ✅ Criado e corrigido (2026-05-07) |
| **Script Enriquecimento** | `corpus/etl-questions/scripts/enrich_topics_llm.py` ✅ Criado e executado — 1.883/1.883 tópicos enriquecidos, 1.890 aprovados (2026-05-19) |
| **Runner loop** | `corpus/etl-questions/scripts/run_pipeline_loop.py` ✅ Criado — reinício automático pós-quota |
| **Documentação** | `corpus/etl-questions/REVIEW_QUESTIONS_PIPELINE.md` ✅ Criado |
| **Pré-requisito Topics** | ✅ 1.883 topics em staging + live (2026-05-04) |
| **Execução parcial (2026-05-07 Gemini)** | ✅ 45/1.874 tópicos — 164 questões (Civil) — Gemini quota esgotada |
| **Execução ativa (2026-05-07 Sabiá-4)** | ✅ 1.874/1.874 tópicos — 5.791 questões validadas em staging — pipeline concluído |
| **Retomada** | ✅ Concluído — checkpoint: 1.874 done, 0 planned, 0 failed |

### Estado do Checkpoint (2026-05-24 — auditado por agente)

- **Done**: 1.874/1.874 tópicos — pipeline de questões de revisão 100% concluído
- **Generated**: 5.799 questões (todas as matérias — CF, CC, CP, CPC, CPP, CLT, CTN, CDC, OAB)
- **Validated**: 5.791 questões aprovadas (score ≥ 7/10) — promovidas para `status: active` (2026-05-24)
- **Rejected**: 8 questões descartadas pelo Validator
- **Failed**: 0 tópicos com falha
- **Enrich Topics (Fase 2)**: 1.883/1.883 tópicos enriquecidos com resumos didáticos Sabiá-4 — 1.890 aprovados, 0 reprovados

### Como retomar

```bash
cd ../etl/questions
python scripts/run_pipeline_loop.py   # reinicia automaticamente após quota
```

### Modelo e configuração atual

- **Modelo**: `sabia-4` (Maritaca AI — API OpenAI-compatible) — migrado de Gemini em 2026-05-07
- **RATE_LIMIT_DELAY**: 3s entre chamadas LLM
- **QUOTA_WAIT**: 180s entre restarts após rate-limit
- **Agente 0 — Planner**: lógica Python local (sem LLM — output de 1.874 itens excede 8.192 tokens)
- **Agente 1 — Generator**: prompt tolerante a ausência de artigos BM25 + fallback por número de artigo
