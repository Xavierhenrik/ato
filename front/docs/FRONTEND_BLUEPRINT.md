# ATO — Frontend Blueprint

> Planta completa do desenvolvimento Flutter, organizada em sprints sequenciais.
> Cada sprint é uma unidade de trabalho para um agente Claude Code autônomo.
> Leia este arquivo antes de qualquer implementação frontend.

---

## Referências obrigatórias (ler antes de codificar)

| Documento | Caminho | O que contém |
|-----------|---------|-------------|
| Stack e decisões fixadas | `CLAUDE.md` | Tecnologias, regras não negociáveis |
| Estado dos módulos | `.claude/PROJECT_STATE.md` | O que está completo no backend |
| Contratos de API | `back/docs/api-contract.md` | Endpoints, bodies, responses |
| Spec de telas | `front/docs/SCREENS.md` | Layout, componentes, dados por tela |
| Design tokens | `front/docs/DESIGN_TOKENS.md` | Cores, tipografia, espaçamentos, tema |
| Prompt de init | `prompt_flutter_init.md` | Comando flutter create + pubspec.yaml |

---

## Arquitetura Flutter

```
front/ato_app/
├── lib/
│   ├── main.dart                          # Entry point + Supabase.initialize
│   ├── app.dart                           # MaterialApp.router + tema
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart            # AppColors — fonte única de verdade
│   │   │   ├── app_text_styles.dart       # AppTextStyles
│   │   │   └── app_theme.dart             # ThemeData dark
│   │   ├── router/
│   │   │   └── app_router.dart            # GoRouter + ShellRoute + guards
│   │   └── network/
│   │       └── api_client.dart            # Dio singleton + interceptor JWT
│   ├── shared/
│   │   └── widgets/
│   │       ├── scaffold_with_nav.dart     # ShellRoute wrapper + BottomNav
│   │       ├── ato_text_field.dart        # TextField estilizado reutilizável
│   │       ├── ato_button.dart            # Button variantes (primary, outline)
│   │       ├── ato_app_bar.dart           # AppBar padrão + variante Tutor
│   │       ├── ato_loading_shimmer.dart   # Shimmer loading genérico
│   │       ├── ato_error_state.dart       # Error state genérico
│   │       ├── ato_empty_state.dart       # Empty state genérico
│   │       ├── category_tag.dart          # Pill colorido de matéria
│   │       └── pro_gate_sheet.dart        # Bottom sheet de upgrade PRO
│   └── features/
│       ├── auth/
│       │   ├── data/auth_repository.dart
│       │   ├── providers/auth_provider.dart
│       │   └── presentation/
│       │       ├── screens/login_screen.dart
│       │       ├── screens/cadastro_screen.dart
│       │       └── screens/reset_senha_screen.dart
│       ├── onboarding/
│       │   ├── data/onboarding_repository.dart
│       │   ├── providers/onboarding_provider.dart
│       │   └── presentation/
│       │       ├── screens/onboarding_screen.dart
│       │       └── screens/diagnostico_screen.dart
│       ├── dashboard/
│       │   ├── data/dashboard_repository.dart
│       │   ├── providers/dashboard_provider.dart
│       │   └── presentation/
│       │       ├── screens/dashboard_screen.dart
│       │       └── widgets/
│       │           ├── greeting_card.dart
│       │           ├── metas_diarias_card.dart
│       │           ├── revisao_inteligente_card.dart
│       │           ├── tarefas_rapidas_card.dart
│       │           └── cards_materia_card.dart
│       ├── tutor/
│       │   ├── data/
│       │   │   ├── models/tutor_models.dart
│       │   │   └── tutor_repository.dart
│       │   ├── providers/tutor_provider.dart
│       │   └── presentation/
│       │       ├── screens/tutor_screen.dart
│       │       └── widgets/
│       │           ├── tutor_welcome_card.dart
│       │           ├── tutor_suggestions_card.dart
│       │           ├── tutor_empty_state.dart
│       │           ├── chat_bubble.dart
│       │           ├── chat_input_bar.dart
│       │           ├── chips_row.dart
│       │           └── typing_indicator.dart
│       ├── manual/
│       │   ├── data/
│       │   │   ├── models/topic_model.dart
│       │   │   └── manual_repository.dart
│       │   ├── providers/manual_provider.dart
│       │   └── presentation/
│       │       ├── screens/manual_list_screen.dart
│       │       ├── screens/manual_detail_screen.dart
│       │       └── widgets/
│       │           ├── topic_card.dart
│       │           └── topic_section_item.dart
│       ├── simulados/
│       │   ├── data/
│       │   │   ├── models/simulado_models.dart
│       │   │   └── simulados_repository.dart
│       │   ├── providers/simulados_provider.dart
│       │   └── presentation/
│       │       ├── screens/simulados_config_screen.dart
│       │       ├── screens/simulados_attempt_screen.dart
│       │       ├── screens/simulados_result_screen.dart
│       │       └── widgets/
│       │           ├── question_card.dart
│       │           ├── option_tile.dart
│       │           └── result_header_card.dart
│       ├── anotacoes/
│       │   ├── data/
│       │   │   ├── models/annotation_model.dart
│       │   │   └── anotacoes_repository.dart
│       │   ├── providers/anotacoes_provider.dart
│       │   └── presentation/
│       │       ├── screens/anotacoes_list_screen.dart
│       │       ├── screens/anotacao_edit_screen.dart
│       │       └── widgets/
│       │           └── annotation_card.dart
│       └── perfil/
│           ├── data/perfil_repository.dart
│           ├── providers/perfil_provider.dart
│           └── presentation/
│               ├── screens/perfil_screen.dart
│               └── screens/subscription_screen.dart
```

---

## Roteamento — GoRouter

```
/ (redirect baseado em auth)
├── /login
├── /cadastro
├── /esqueci-senha
├── /onboarding
├── /diagnostico
└── /app  [ShellRoute — ScaffoldWithNav]
    ├── /tutor
    ├── /anotacoes
    │   ├── /anotacoes/nova
    │   └── /anotacoes/:id/editar
    ├── /dashboard
    └── /perfil
        └── /perfil/subscription

Rotas push (sem ShellRoute):
├── /manual                      # lista de tópicos
│   └── /manual/topic/:id        # detalhe
├── /simulados                   # config + início
│   ├── /simulados/:id           # em andamento
│   └── /simulados/:id/results   # resultado
```

### Guards de autenticação

- Sem sessão Supabase → redireciona para `/login`
- Com sessão + `onboardingDone: false` → redireciona para `/onboarding`
- Com sessão + `nivelamentoPendente: true` → exibe `DiagnosticoScreen` como modal após `/dashboard`

---

## Dependências (pubspec.yaml)

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  go_router: ^13.2.0
  dio: ^5.4.1
  retrofit: ^4.1.0
  supabase_flutter: ^2.3.2
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.2
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
  json_serializable: ^6.7.1
  retrofit_generator: ^8.1.0
  isar_generator: ^3.1.0+1
```

---

## Convenções obrigatórias

| Regra | Detalhe |
|-------|---------|
| Cores | Sempre `AppColors.*` — zero `Color(0xFF...)` hardcoded |
| Tipografia | Sempre `AppTextStyles.*` — zero `TextStyle(fontSize: ...)` direto |
| Providers | Riverpod codegen `@riverpod` — nunca `StateNotifierProvider` legado |
| Widgets com estado reativo | `ConsumerWidget` ou `ConsumerStatefulWidget` |
| Repositories | Retrofit + Dio — nunca `http` package diretamente |
| Navegação | `context.push()` / `context.go()` do GoRouter |
| Auth header | Injetado automaticamente pelo interceptor Dio — nunca manualmente |
| Gate PRO | Verificar `plan` do provider antes de ação — exibir `ProGateSheet` |
| Build gerado | Rodar `dart run build_runner build --delete-conflicting-outputs` após criar providers/models |

---

## Sprints de Implementação

### Sprint F1 — Fundação + Auth + Onboarding

**Objetivo:** App rodando, autenticação funcional, usuário chega ao Dashboard.

**Escopo:**
- `flutter create` com estrutura de pastas completa
- `core/theme/` — AppColors, AppTextStyles, AppTheme
- `core/network/api_client.dart` — Dio + interceptor Supabase JWT
- `core/router/app_router.dart` — GoRouter completo com guards
- `shared/widgets/` — ScaffoldWithNav, AtoTextField, AtoButton, AtoAppBar
- `features/auth/` — LoginScreen, CadastroScreen, ResetSenhaScreen
- `features/onboarding/` — OnboardingScreen, DiagnosticoScreen

**Telas:** Login, Cadastro, Esqueci senha, Onboarding, Quiz Diagnóstico

**Endpoints integrados:**
- `supabase.auth.signInWithPassword()`
- `supabase.auth.signUp()`
- `supabase.auth.resetPasswordForEmail()`
- `POST /auth/verify`
- `POST /onboarding/complete`
- `POST /onboarding/diagnostic/complete`
- `POST /onboarding/diagnostic/dismiss`

**Critérios de aceite:**
- [ ] Login com e-mail/senha autentica e navega para `/dashboard`
- [ ] Cadastro cria usuário e navega para `/onboarding`
- [ ] Onboarding com fase + tempo diário chama `POST /onboarding/complete` e navega para `/dashboard`
- [ ] Guard redireciona usuário sem sessão para `/login`
- [ ] DiagnosticoScreen exibe se `nivelamentoPendente: true`
- [ ] Dismiss do diagnóstico chama `POST /onboarding/diagnostic/dismiss`
- [ ] AppColors e AppTextStyles sem nenhum valor hardcoded

**Nota para o agente:** O `ScaffoldWithNav` usa `ShellRoute` do GoRouter. As 4 tabs são: `/tutor`, `/anotacoes`, `/dashboard`, `/perfil`. No Sprint F1 apenas `/dashboard` precisa ter conteúdo (placeholder aceitável para as outras).

---

### Sprint F2 — Dashboard

**Objetivo:** Tela principal com dados reais do backend.

**Pré-requisito:** Sprint F1 concluído — app rodando com auth.

**Escopo:**
- `features/dashboard/data/dashboard_repository.dart`
- `features/dashboard/providers/dashboard_provider.dart`
- `features/dashboard/presentation/screens/dashboard_screen.dart`
- Widgets: GreetingCard, MetasDiariasCard, RevisaoInteligenteCard, TarefasRapidasCard, CardsMateriaCard
- `shared/widgets/ato_loading_shimmer.dart`

**Telas:** Dashboard / Início

**Endpoints integrados:**
- `GET /dashboard`
- `GET /dashboard/revision-cards` (retornado por `GET /dashboard/revision-cards` conforme api-contract)
- `GET /dashboard/performance`

**Critérios de aceite:**
- [ ] Dashboard exibe nome do usuário, streak, % meta diária
- [ ] DonutChart gold renderiza com % correto
- [ ] RevisaoInteligente exibe cards horizontais com matérias
- [ ] Loading state com shimmer durante fetch
- [ ] Error state com mensagem ao falhar
- [ ] TarefasRapidas navega para as rotas corretas ao tocar
- [ ] CardsMaterias exibe os 4 stats

---

### Sprint F3 — Tutor IA

**Objetivo:** Tutor funcional — estado vazio e chat com backend.

**Pré-requisito:** Sprint F1 concluído.

**Escopo:**
- `features/tutor/data/models/tutor_models.dart`
- `features/tutor/data/tutor_repository.dart`
- `features/tutor/providers/tutor_provider.dart`
- `features/tutor/presentation/screens/tutor_screen.dart`
- Widgets: TutorWelcomeCard, TutorSuggestionsCard, TutorEmptyState, ChatBubble, ChatInputBar, ChipsRow, TypingIndicator

**Telas:** Tutor IA estado vazio + estado chat

**Endpoints integrados:**
- `POST /tutor/session/new`
- `POST /tutor/message`
- `DELETE /tutor/session/:id`

**Critérios de aceite:**
- [ ] Estado vazio exibe WelcomeCard + 6 chips de sugestão
- [ ] Tocar chip preenche o input e envia a mensagem
- [ ] Mensagem do usuário aparece imediatamente (optimistic)
- [ ] TypingIndicator aparece enquanto aguarda resposta
- [ ] Resposta da IA renderiza com chips de continuação abaixo
- [ ] Chips de continuação enviam nova mensagem ao tocar
- [ ] Snackbar "Anotação salva" aparece se `autoSavedAnnotationId` presente (PRO)
- [ ] 429 exibe `ProGateSheet` com CTA de upgrade
- [ ] Sessão encerrada ao sair da tela (`DELETE /tutor/session/:id`)
- [ ] Header do Tutor usa layout especial (ATO box + título à esquerda)

**Atenção Free vs PRO:**
- Rate limit de 20 msgs/dia para Free → backend retorna 429 → ProGateSheet
- `autoSavedAnnotationId` só retorna para PRO com `confidence: "high"`

---

### Sprint F4 — Manual

**Objetivo:** Navegação completa pelo corpus de tópicos jurídicos.

**Pré-requisito:** Sprint F1 concluído.

**Escopo:**
- `features/manual/data/models/topic_model.dart`
- `features/manual/data/manual_repository.dart`
- `features/manual/providers/manual_provider.dart`
- Telas: ManualListScreen, ManualDetailScreen
- Widgets: TopicCard, CategoryTag, TopicSectionItem

**Telas:** Manual lista + Manual detalhe

**Endpoints integrados:**
- `GET /manual/topics`
- `GET /manual/topics?lawCode=:code`
- `GET /manual/topics/:id`
- `GET /manual/search?q=:termo`
- `POST /manual/topics/:id/read`

**Critérios de aceite:**
- [ ] Lista exibe tópicos com CategoryTag colorida por matéria
- [ ] Filter chips filtram por matéria (lawCode)
- [ ] Search com debounce 400ms chama `/manual/search`
- [ ] Tópico lido exibe indicador visual (✅ ou borda diferenciada)
- [ ] `POST /manual/topics/:id/read` chamado ao abrir detalhe (idempotente)
- [ ] Detalhe exibe 6 seções da estrutura canônica v1.0
- [ ] "Sobre este resumo" card exibido no topo do detalhe
- [ ] Loading shimmer na lista e no detalhe

**Estrutura canônica das seções (não usar o design do designer):**
`fundamento → artigos centrais → exemplo prático → atenção → OAB → resumo`

---

### Sprint F5 — Simulados

**Objetivo:** Fluxo completo de simulado com diferenciação Free/PRO.

**Pré-requisito:** Sprint F1 concluído.

**Escopo:**
- `features/simulados/data/models/simulado_models.dart`
- `features/simulados/data/simulados_repository.dart`
- `features/simulados/providers/simulados_provider.dart`
- Telas: SimuladosConfigScreen, SimuladosAttemptScreen, SimuladosResultScreen
- Widgets: QuestionCard, OptionTile, ResultHeaderCard

**Telas:** Simulados config + em andamento + resultado

**Endpoints integrados:**
- `GET /simulados/history`
- `POST /simulados/start`
- `POST /simulados/:id/answer`
- `POST /simulados/:id/complete`
- `GET /simulados/:id/results`

**Critérios de aceite:**
- [ ] Config: seleção de modo e quantidade de questões
- [ ] Free: opções acima de 15 questões exibem 🔒 e são desabilitadas
- [ ] `POST /simulados/start` com `totalQ > 15` para Free retorna 400 → tratar
- [ ] 409 `SIMULADO_IN_PROGRESS` navega para simulado existente
- [ ] Opção selecionada highlighted em accent
- [ ] Confirmar resposta chama `POST .../answer` e exibe correto/errado
- [ ] Última questão: "Ver resultado" → `POST .../complete` → navega para results
- [ ] Resultado: score, corretas, erradas exibidos
- [ ] Resultado: explicação exibida apenas para PRO; Free vê ProGateSheet inline
- [ ] Abandonar: bottom sheet de confirmação → `POST .../abandon`

---

### Sprint F6 — Anotações

**Objetivo:** CRUD completo de anotações com integração ao Tutor IA.

**Pré-requisito:** Sprint F1 concluído.

**Escopo:**
- `features/anotacoes/data/models/annotation_model.dart`
- `features/anotacoes/data/anotacoes_repository.dart`
- `features/anotacoes/providers/anotacoes_provider.dart`
- Telas: AnotacoesListScreen, AnotacaoEditScreen
- Widgets: AnnotationCard

**Telas:** Anotações lista + criação/edição

**Endpoints integrados:**
- `GET /annotations`
- `POST /annotations`
- `PUT /annotations/:id`
- `DELETE /annotations/:id`

**Critérios de aceite:**
- [ ] Lista exibe anotações com título, tags, preview e data
- [ ] Filter por matéria e por tag funcionam
- [ ] Search em título e conteúdo funciona
- [ ] FAB navega para criação
- [ ] Criação persiste com título, subject, tags e content
- [ ] Edição carrega dados existentes e atualiza
- [ ] Swipe-to-delete ou botão de deletar com confirmação
- [ ] Anotações auto-salvas pelo Tutor (PRO) exibem ícone de robô
- [ ] Empty state com CTA de criar primeira anotação

---

### Sprint F7 — Perfil + Assinatura

**Objetivo:** Perfil do usuário e fluxo de upgrade PRO via RevenueCat.

**Pré-requisito:** Sprint F1 concluído.

**Escopo:**
- `features/perfil/data/perfil_repository.dart`
- `features/perfil/providers/perfil_provider.dart`
- Telas: PerfilScreen, SubscriptionScreen
- RevenueCat SDK integration

**Telas:** Perfil + Assinatura PRÓ

**Endpoints integrados:**
- `GET /users/profile`
- `PUT /users/profile`
- `GET /subscriptions/status`
- RevenueCat SDK: `Purchases.configure()`, `Purchases.getOfferings()`, `Purchases.purchasePackage()`

**Critérios de aceite:**
- [ ] Perfil exibe nome, e-mail e plano atual
- [ ] Badge "Membro Pró" exibido apenas se `plan === "pro"`
- [ ] PRO banner: Free vê CTA de upgrade, PRO vê "Gerenciar plano"
- [ ] "Editar" abre campos editáveis para nome
- [ ] "Alterar senha" chama `supabase.auth.updateUser()`
- [ ] "Sair" faz `supabase.auth.signOut()` e navega para `/login`
- [ ] SubscriptionScreen exibe planos mensal (R$29,90) e anual (R$249,90)
- [ ] Plano anual em destaque com badge "Economize 30%"
- [ ] Tap em plano → RevenueCat `purchasePackage()` → sheet nativa da store
- [ ] Sem formulário de cartão customizado (RevenueCat IAP nativo)

**Product IDs RevenueCat:**
- Mensal: `com.bx.ato.pro.monthly`
- Anual: `com.bx.ato.pro.annual`

---

### Sprint F8 — Hardening + Offline + Polish

**Objetivo:** App production-ready — cache offline, estados de erro, performance.

**Pré-requisito:** Sprints F1–F7 concluídos.

**Escopo:**
- Isar schema para cache de tópicos do Manual (TTL 24h)
- Isar schema para cache do Dashboard (TTL 1h)
- `flutter analyze` — zero warnings
- Shimmer loading em todas as telas sem loading state
- Error state padronizado em todas as telas
- Pull-to-refresh em Dashboard, Manual lista, Anotações lista
- Deep link handling via GoRouter
- Splash screen + ícone do app

**Critérios de aceite:**
- [ ] Manual lista funciona offline se já carregado antes (Isar cache)
- [ ] Dashboard funciona offline com dados em cache
- [ ] `flutter analyze` retorna zero issues
- [ ] Todas as telas têm shimmer durante loading
- [ ] Todas as telas têm error state com botão "Tentar novamente"
- [ ] Pull-to-refresh atualiza dados e invalida cache
- [ ] App não crasha em nenhum fluxo testado manualmente

---

## Ordem de execução dos sprints

```
F1 (Fundação) ──┬──> F2 (Dashboard)
                ├──> F3 (Tutor IA)
                ├──> F4 (Manual)
                ├──> F5 (Simulados)
                ├──> F6 (Anotações)
                └──> F7 (Perfil + Assinatura)
                         └──> F8 (Hardening)
```

F1 é pré-requisito de todos. F2–F7 podem ser executados em paralelo por agentes diferentes. F8 depende de todos.

---

## Como acionar um sprint

Prompts de sprint são gerados no chat (Claude Cowork) sob demanda — não ficam salvos como arquivos.

Para iniciar um sprint, peça no chat: **"gera o prompt para Sprint F[n]"**.

O agente receberá um prompt com:
- Leitura obrigatória dos 6 documentos de referência
- Escopo exato do sprint (arquivos a criar, endpoints, critérios de aceite)
- Regras absolutas de implementação
- Instruções de finalização (log de sessão + atualização do PROJECT_STATE.md)
