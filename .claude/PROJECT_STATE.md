---
updated: 2026-06-07
sprint: "Apple App Store Compliance: Privacy Policy, Consent Modal, Delete Account UI, Legal Disclaimer, Sign in with Apple, RevenueCat dynamic prices"
---

# LCF — Estado do Projeto

> Atualizado pelo Claude ao fim de cada sessão de trabalho.
> Para detalhes de implementação de cada módulo, ver `../docs/ROADMAP.md`.

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

Nenhuma pendente.

> Migrations do Sprint 1 aplicadas em 2026-05-03 via `prisma/migrations/sprint1_manual.sql` (staging + live).
> Índices Sprint 4 (`simulado_questions_is_correct_idx`, `simulado_questions_answered_at_idx`, `simulado_questions_attempt_id_is_correct_idx`) aplicados em 2026-05-28 via `prisma/migrations/apply_sprint4.js` (staging + live).

## Débito Técnico Registrado

| Item | Impacto | Sprint |
|------|---------|--------|
| FK `simulado_questions → questions` implícita via Prisma relation | Baixo — a FK existe via Prisma ORM; `@db.Uuid` adicionado a `questions.id` resolve o type mismatch UUID/TEXT | ✅ Resolvido Sprint 4 |

---

## Decisões Externas Bloqueantes

| Decisão | Bloqueia | Status |
|---------|---------|--------|
| Pricing model PRO | Sprint 3 — RevenueCat config | ⏳ Pendente |
| Banco de questões | Sprint 2 — M5 Simulados | ✅ Concluído — 2.210 questões OAB + 5.791 questões review (active) em live + staging |
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

## Decisões Arquiteturais Registradas

| Data | Decisão | Motivo |
|------|---------|--------|
| 2026-06-07 | JWT: `@fastify/jwt` usa `secret: SUPABASE_JWT_SECRET` (HS256 simétrico) | `SUPABASE_JWT_PUBLIC_KEY` não existe; Supabase usa HS256, não RS256. Undefined behavior se var ausente. |
| 2026-06-07 | DELETE /auth/me chama `supabaseAdmin.auth.admin.deleteUser` antes de `db.user.delete` | Sem essa chamada, JWT do usuário deletado ainda passava no `requireAuth` e o auto-provisioning recriava a conta — violação LGPD |
| 2026-06-07 | Sign in with Apple revertido — obrigatório pela Guideline 4.8 | Decisão "removido do escopo" foi revogada; app usa Google OAuth, portanto Apple Sign In é mandatório |
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

### Para ativar o Sprint F1 (próximos passos obrigatórios)

```bash
# 1. Scaffoldar plataformas (mantém lib/ já criado)
cd C:\Projetos\BX\LCF
flutter create --org com.lcf --project-name lcf_app --platforms ios,android front/lcf_app

# 2. Gerar código (Riverpod, Retrofit, json_serializable)
cd front/lcf_app
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
| 2026-06-03 | sessions/2026-06-03_llmops.md | LLM-Ops Fase 1+2: Sabiázinho-4 para direct simples + KB estática 1.883 tópicos. `tsc --noEmit` zero erros. Pendente: executar `apply_topics_fts.sql` no Supabase. |
| 2026-06-07 | sessions/2026-06-07_security_jwt_delete.md | CRÍTICO: JWT fixado para HS256 simétrico (`SUPABASE_JWT_SECRET`); DELETE /auth/me passa a invalidar sessão Supabase via `admin.deleteUser` antes de deletar do banco (LGPD). `SUPABASE_SERVICE_ROLE_KEY` adicionado ao `.env.example` e checklist. |
| 2026-06-07 | sessions/2026-06-07_compliance_apple.md | Apple App Store Compliance: 6 itens implementados — Privacy Policy, Consent Modal IA, Delete Account UI, Disclaimer jurídico, Sign in with Apple, RevenueCat dynamic prices. flutter analyze zero issues. |





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
cd corpus/etl-questions
python scripts/run_pipeline_loop.py   # reinicia automaticamente após quota
```

### Modelo e configuração atual

- **Modelo**: `sabia-4` (Maritaca AI — API OpenAI-compatible) — migrado de Gemini em 2026-05-07
- **RATE_LIMIT_DELAY**: 3s entre chamadas LLM
- **QUOTA_WAIT**: 180s entre restarts após rate-limit
- **Agente 0 — Planner**: lógica Python local (sem LLM — output de 1.874 itens excede 8.192 tokens)
- **Agente 1 — Generator**: prompt tolerante a ausência de artigos BM25 + fallback por número de artigo
- **Agente 2 — Validator**: score ≥ 7/10 para aprovação
- **Output**: `status='pending_review'` → promoção via admin (Sprint 4)

