---
updated: 2026-05-22
sprint: "Sprint 3 concluído · Sprint F1 Flutter iniciado"
---

# LCF — Estado do Projeto

> Atualizado pelo Claude ao fim de cada sessão de trabalho.
> Para detalhes de implementação de cada módulo, ver `../back/docs/ROADMAP.md`.

---

## Sprint Atual: Sprint 3 — PRO Features & Monetização

**Objetivo:** Tutor IA gaps PRO fechados + Subscriptions hardening. Próximo: Push Notifications (OneSignal — aguardando credenciais).

**Pré-requisito atendido:** Sprint 2 concluído.

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
| **M5 — Simulados** | ✅ Completo | — | 2 |
| **Push Notifications** | ⏳ Bloqueado | Aguardando ONESIGNAL_APP_ID + API_KEY | 3 |

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

| Migration | Módulo | Sprint |
|-----------|--------|--------|
| Índices compostos em `SimuladoQuestion` | Sprint 4 Hardening | 4 |

> Migrations do Sprint 1 aplicadas em 2026-05-03 via `prisma/migrations/sprint1_manual.sql`
> (staging + live). Detalhes em `.claude/sessions/2026-05-03_sprint1.md`.

## Débito Técnico Registrado

| Item | Impacto | Sprint |
|------|---------|--------|
| FK `simulado_questions → questions` ausente (type mismatch UUID/TEXT) | Baixo — integridade garantida pela app | 4 Hardening |
| `questions.id` é UUID no ETL mas mapeado como `String` no Prisma sem `@db.Uuid` | Baixo — PostgreSQL faz cast implícito | 4 Hardening |

---

## Decisões Externas Bloqueantes

| Decisão | Bloqueia | Status |
|---------|---------|--------|
| Pricing model PRO | Sprint 3 — RevenueCat config | ⏳ Pendente |
| Banco de questões | Sprint 2 — M5 Simulados | ✅ Concluído — 2.210 questões OAB em live + staging (legal_articles 18.779 também migrados) |
| Topics (M3 Manual) | Pipeline generate_review_questions.py | ✅ Concluído — 1.883 topics em live + staging (2026-05-04) |
| App IDs Apple/Google | Sprint 3 — IAP | ⏳ Pendente |
| OneSignal App ID + API Key | Sprint 3 — Push | ⏳ Pendente |

---

## Decisões Arquiteturais Registradas

| Data | Decisão | Motivo |
|------|---------|--------|
| 2026-05-01 | Setup de memória Claude Code (CLAUDE.md + hooks) | Continuidade entre sessões de IA |
| 2026-05-02 | Onboarding simplificado: 1 tela, 2 perguntas (academicPhase + dailyStudyMins) | Reduz fricção; dados reais vêm do Quiz Diagnóstico e comportamento |
| 2026-05-02 | Quiz Diagnóstico universal: dois caminhos (oab / graduation), opcional com dismiss consciente | Personalização real > autoavaliação; dismiss ≠ skip |
| 2026-05-02 | graduation_end adicionado como 4ª fase acadêmica (90 dias) | Design identificou lacuna entre graduation_mid e oab_prep |
| 2026-05-02 | studyGoal e selectedSubjects removidos do onboarding | Autoavaliação é ruído; comportamento do app é sinal |

---

---

## Frontend — Status dos Sprints Flutter

| Sprint | Status | Descrição |
|--------|--------|-----------|
| **F1 — Fundação + Auth + Onboarding** | 🔄 Código criado — aguardando `flutter create` + `build_runner` | Core theme, router, auth, onboarding — 22 arquivos |
| **F2 — Dashboard** | ⏳ Pendente F1 compilando | — |
| **F3 — Tutor IA** | ⏳ Pendente F1 | — |
| **F4 — Manual** | ⏳ Pendente F1 | — |
| **F5 — Simulados** | ⏳ Pendente F1 | — |
| **F6 — Anotações** | ⏳ Pendente F1 | — |
| **F7 — Perfil + Assinatura** | ⏳ Pendente F1 | — |
| **F8 — Hardening + Offline** | ⏳ Pendente F1–F7 | — |

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





---

## Pipeline de Geração de Questões de Revisão

| Item | Status |
|------|--------|
| **Script ETL Topics** | `corpus/etl-questions/scripts/generate_topics_from_articles.py` ✅ Criado e executado |
| **Script Questões** | `corpus/etl-questions/scripts/generate_review_questions.py` ✅ Criado e corrigido (2026-05-07) |
| **Script Enriquecimento** | `corpus/etl-questions/scripts/enrich_topics_llm.py` ✅ Criado (2026-05-19) — aguardando execução |
| **Runner loop** | `corpus/etl-questions/scripts/run_pipeline_loop.py` ✅ Criado — reinício automático pós-quota |
| **Documentação** | `corpus/etl-questions/REVIEW_QUESTIONS_PIPELINE.md` ✅ Criado |
| **Pré-requisito Topics** | ✅ 1.883 topics em staging + live (2026-05-04) |
| **Execução parcial (2026-05-07 Gemini)** | ✅ 45/1.874 tópicos — 164 questões (Civil) — Gemini quota esgotada |
| **Execução ativa (2026-05-07 Sabiá-4)** | 🔄 51+/1.874 tópicos — 245+ questões em staging — pipeline rodando com Sabiá-4 |
| **Retomada** | `python run_pipeline_loop.py` — checkpoint em `data/checkpoints/review_gen_checkpoint.json` |

### Estado do Checkpoint (2026-05-07)

- **Done**: 45 tópicos (todos Civil) — 164 questões em staging
- **Generating** (killed mid-run): 3 tópicos Civil — retomados automaticamente no próximo run
- **Planned**: 1.826 tópicos (todas as demais matérias + Civil restante)
- **Quota Gemini**: free tier diária exaurida em 2026-05-07 — retomar no dia seguinte

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

