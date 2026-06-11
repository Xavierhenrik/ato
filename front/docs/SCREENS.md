# LCF — Documentação de Telas (UI Reference)

> Gerado a partir das telas enviadas pelo designer em 2026-05-21.
> Esta é a fonte de verdade para o desenvolvimento Flutter.
> Conflitos com a spec técnica estão sinalizados com ⚠️ e devem ser resolvidos antes da implementação da tela afetada.

---

## Índice

**Telas com design aprovado (designer):**
1. [Login](#1-login)
2. [Cadastro](#2-cadastro)
3. [Onboarding](#3-onboarding)
4. [Dashboard / Início](#4-dashboard--início)
5. [Tutor IA — Estado vazio](#5-tutor-ia--estado-vazio)
6. [Manual — Detalhe do artigo](#6-manual--detalhe-do-artigo)
7. [Perfil](#7-perfil)
8. [Assinatura PRÓ](#8-assinatura-pró)

**Telas especificadas por arquitetura (sem design do designer):**
9. [Tutor IA — Estado de chat](#9-tutor-ia--estado-de-chat)
10. [Manual — Lista de tópicos](#10-manual--lista-de-tópicos)
11. [Simulados — Configuração e início](#11-simulados--configuração-e-início)
12. [Simulados — Em andamento](#12-simulados--em-andamento)
13. [Simulados — Resultado](#13-simulados--resultado)
14. [Anotações — Lista](#14-anotações--lista)
15. [Anotações — Criação e edição](#15-anotações--criação-e-edição)
16. [Quiz Diagnóstico / Nivelamento](#16-quiz-diagnóstico--nivelamento)
17. [Esqueci minha senha](#17-esqueci-minha-senha)

---

## Tokens de Design Globais

Ver `DESIGN_TOKENS.md` para referência completa. Resumo:

| Token | Valor |
|-------|-------|
| `background` | `#1A0800` |
| `backgroundCard` | `#2D1200` |
| `backgroundSheet` | `#3D1200` |
| `accent` / gold | `#C9922A` |
| `backgroundNav` | `#140600` |
| `border` | `#3D2010` |
| `textPrimary` | `#FFFFFF` |
| `textSecondary` | `#9E8472` |
| `textMuted` | `#6B5240` |
| `tagBackground` | `#5A1A1A` (vermelho escuro) |
| `success` | `#C9922A` (checkmark gold) |

---

## Bottom Navigation

Presente em todas as telas autenticadas. 4 itens fixos:

| Posição | Label | Ícone | Rota GoRouter |
|---------|-------|-------|---------------|
| 1 | Tutor | robô | `/tutor` |
| 2 | Anotações | bookmark | `/anotacoes` |
| 3 | Início | home | `/dashboard` |
| 4 | Perfil | person | `/perfil` |

- Item ativo: ícone gold + label gold
- Item inativo: ícone muted + label muted
- Background nav: `#140600`
- Altura: ~60px + safe area bottom

---

## 1. Login

**Rota:** `/login` (fora do ShellRoute — sem BottomNav)
**Estado:** único

### Layout

```
[LCF Logo — círculo gold com texto + balança + livro]
[Tagline: "Sua aprovação para OAB começa aqui"]

[Label: E-mail]
[TextField: ✉️ "Digite seu e-mail"]

[Label: Senha]
[TextField: 🔒 "Digite sua senha" | 👁 toggle]
[Row: ☐ Lembrar de mim | Esqueci minha senha (link)]

[Button: "Entrar" — full-width, dark brown]
[Divider: "ou continue com"]

[Button: 🍎 "Entrar com Apple" — full-width, dark]   ⚠️
[Button: G "Entrar com Google" — full-width, dark]

[Link: "Não tem uma conta? Criar conta"]
```

### Componentes

| Widget | Detalhes |
|--------|----------|
| `LcfLogo` | Círculo com borda gold, "LCF" + ícones internos. Reutilizável. |
| `LcfTextField` | Rounded border, ícone leading, toggle senha opcional |
| `LcfButton` | Full-width, variante primary (dark) |
| `SocialAuthButton` | Full-width, ícone + texto, variante Apple / Google |

### Dados / Ações

| Ação | API / SDK |
|------|-----------|
| Login e-mail + senha | `supabase.auth.signInWithPassword()` |
| Login Google | `supabase.auth.signInWithOAuth(provider: google)` |
| Login Apple | ⚠️ Ver conflito #2 abaixo |
| Esqueci senha | `supabase.auth.resetPasswordForEmail()` |

### ⚠️ Conflito #2 — Apple Sign In
Design mostra "Entrar com Apple". Spec técnica define: **"Sem Apple Sign In — Removido do escopo"**.
**Decisão pendente** antes de implementar o botão.

---

## 2. Cadastro

**Rota:** `/cadastro` (fora do ShellRoute)
**Padrão:** Bottom Sheet sobre tela de splash

### Layout

```
[Fundo: background escuro #1A0800]
[LCF Logo — topo centralizado]
[Tagline: "Sua aprovação para OAB começa aqui"]

[Bottom Sheet — #3D1200, cantos superiores arredondados]
  [Botão X — fechar, canto superior direito]
  [Título: "Criar conta com e-mail"]
  [TextField: 👤 "Nome completo"]
  [TextField: ✉️ "E-mail"]
  [TextField: 🔒 "Senha" | 👁 toggle]
  [Button: "Criar conta e iniciar →" — full-width, dark]
  [Texto: "Ao continuar você concorda com os termos de uso e política de privacidade"]
```

### Componentes

| Widget | Detalhes |
|--------|----------|
| `AuthBottomSheet` | Modal arrastável, altura ~60% da tela |
| `LcfTextField` | Mesmo componente do Login |
| `LcfButton` | Com ícone → sufixo |

### Dados / Ações

| Ação | API / SDK |
|------|-----------|
| Criar conta | `supabase.auth.signUp(email, password)` + update `display_name` |
| Validação local | Nome não vazio, e-mail válido, senha ≥ 8 chars |

### Fluxo pós-cadastro
`/cadastro` → `POST /onboarding/complete` → `/dashboard`

---

## 3. Onboarding

**Rota:** `/onboarding` (fora do ShellRoute)
**Estado:** único (questionário em uma tela só)

### Layout

```
[AppBar: ← voltar | "LCF" centralizado]
[Título: "Vamos montar seu plano de estudos"]
[Subtítulo: ⏱ "Leva menos de 1 minuto"]

[Seção: "① Em qual fase você está?"]
[Grid 2×2: cards de fase]
  [ 🎓 Inicio da faculdade ]  [ 📖 Meio da faculdade ]
  [ ⚖️ Final da faculdade  ]  [ 🎒 Estudando para OAB ]

[Seção: "② Quanto tempo você pode estudar por dia?"]
[Row de chips: 30 min | 1 hora | 2 horas | 3+ horas]

[Button: "Gerar meu plano de estudos" — full-width]
```

### Cards de Fase

| Label no UI | `academicPhase` no backend |
|-------------|---------------------------|
| Inicio da faculdade | `graduation_start` |
| Meio da faculdade | `graduation_mid` |
| Final da faculdade | `graduation_end` |
| Estudando para OAB | `oab_prep` |

Estado selecionado: borda gold `#C9922A`, ícone gold.
Estado não selecionado: borda `#3D2010`, ícone muted `#6B5240`.

### Chips de Tempo

| Label | `dailyStudyMins` |
|-------|-----------------|
| 30 min | 30 |
| 1 hora | 60 |
| 2 horas | 120 |
| 3+ horas | 180 |

Estado selecionado: borda gold, texto branco.
Estado padrão ao abrir: nenhum selecionado (ou pré-selecionar 1 hora).

### Dados / Ações

```
POST /onboarding/complete
body: { academicPhase, dailyStudyMins }
response: { flow, nivelamentoPendente }
→ Navegar para /dashboard (quiz diagnóstico é opcional, disparado pelo dashboard)
```

---

## 4. Dashboard / Início

**Rota:** `/dashboard` — tab Início ativa no BottomNav
**Estado:** único (scroll vertical)

### Layout (de cima para baixo)

```
[Header Row]
  [LCF logo — gold, left]
  [Greeting: "Olá, {nome}! 👋 / Continue firme nos seus estudos"]
  [Streak badge: 🔥 {n} / "Dias seguido"]
  [Avatar — circle, green online dot]

[GreetingCard — dark card, arredondado]
  [Flame icon com badge {streak}]
  [Texto: "Bom dia, {nome}!" + frase motivacional]
  [Row: "Meta diária {n}% concluída" | "Revisão inteligente {n} matérias hoje"]

[MetasDiariasCard]
  [Left: DonutChart — gold fill, % no centro, "Concluído"]
  [Right: CheckList de tarefas do dia]
    [✅ Ler um resumo]
    [✅ Resolver 10 questões]
    [✅ Revisar 2 matérias]
    [⭕ Estudar 1 tema novo]

[RevisaoInteligenteCard]
  [Header: "Revisão inteligente" | "Ver todas >"]
  [Subtítulo: "Com base no algoritmo de repetição espaçada"]
  [HorizontalScrollView de SubjectRevisionCards]
    Cada card: subject name, "Revisão hoje", "{n} questões", [Revisar]
    Primeiro card: destacado com borda/bg gold

[TarefasRapidasCard]
  [Header: "Tarefas rápidas"]
  [Row de 3 SquareActionButtons]
    [📄 "Ler 1 resumo"]
    [📋 "Resolver 10 questões"]
    [🔄 "Revisar matérias"]

[CardsMateriaCard]
  [Header: "Cards de matérias" | "Ver todas >"]
  [Subtítulo: "Prioridades definidas para o seu estudo"]
  [Grid 2×2 de StatBoxes]
    [12 / Matérias ativas]
    [48 / Temas em revisão]
    [128 / Questões pendentes]
    [85% / Desempenho geral]
```

### Dados consumidos

| Seção | Endpoint |
|-------|----------|
| Greeting, streak, metas | `GET /dashboard` |
| Revisão inteligente | `GET /dashboard/revision-cards` |
| Desempenho / stats | `GET /dashboard/performance` |

### Observações
- Frase motivacional ("Disciplina hoje, aprovação amanhã") pode ser fixa ou rotacionada.
- Tarefas rápidas são shortcuts de navegação local — não chamam API diretamente.
- "Ver todas >" em Revisão e Cards de matérias → rotas a definir (provavelmente `/simulados` e `/manual`).

---

## 5. Tutor IA — Estado vazio

**Rota:** `/tutor` — tab Tutor ativa no BottomNav
**Estado:** `empty` (sem histórico de chat na sessão atual)
**Estado pendente de documentar:** `chat` (com mensagens)

### Layout

```
[Header — diferente do padrão]
  [LCF logo box — gold border rectangle]
  [Column: "Tutor IA" | "Direito inteligente para sua aprovação"]

[WelcomeCard — dark card]
  [Left: Avatar robô em círculo gold]
  [Right: "Olá, eu sou o tutor LCF ⚖️" + descrição]
  [Row de 3 FeatureBadges]
    [🎯 Respostas com base legal]
    [📖 Explicações claras e objetivas]
    [✅ Fontes confiáveis e atualizadas]

[SuggestoesCard — dark card]
  [Header: 💡 "Sugestões para começar"]
  [Subtítulo: "Clique em um tema abaixo ou digite sua pergunta"]
  [Grid 3 linhas × 2 colunas de SuggestionChipCards]
    [📄 Resumir este tema         ] [⚖️ Artigo de lei            ]
    [🔍 Entender Jurisprudência   ] [📝 Explicar conceito        ]
    [✏️ Questão comentada         ] [🧠 Criar mapa mental        ]
  [Link: "Ver mais sugestões >"]

[TutorEmptyState — centralizado, fora dos cards]
  [Ícone balança em círculo gold]
  [Título: "Faça sua pergunta sobre direito"]
  [Subtítulo: "Estou pronto para te ajudar"]

[ChatInputBar — fixed bottom, acima do BottomNav]
  [📎 ícone attach]
  [TextField: "Digite sua pergunta sobre direito"]
  [🎤 ícone mic]
  [▶ botão send — círculo gold]
  [Disclaimer: "🔒 Respostas geradas por IA, sempre confira as fontes e a legislação vigente"]
```

### SuggestionChipCards — detalhes

| Ícone | Título | Exemplo |
|-------|--------|---------|
| 📄 | Resumir este tema | Ex: princípios da legalidade |
| ⚖️ | Artigo de lei | Ex: Art 5°, CF/88 |
| 🔍 | Entender Jurisprudência | Ex: súmula 651 do STJ |
| 📝 | Explicar conceito | Ex: teoria da imputação objetiva |
| ✏️ | Questão comentada | Ex: OAB 2023 – penal |
| 🧠 | Criar mapa mental | Ex: direito administrativo |

> Nota: O design tem "Endender" — corrigir para "Entender" na implementação.

Ao clicar em um chip: preenche o TextField com o título do chip e foca o input.

### Dados / Ações

| Ação | API |
|------|-----|
| Enviar mensagem | `POST /tutor/message` |
| Response stream | Streaming ou polling conforme implementado |

### Chips de resposta (estado chat)
O backend retorna `chips` com 4 opções de continuação após cada resposta. Renderizar como row de chips abaixo da última mensagem da IA.

---

## 6. Manual — Detalhe do artigo

**Rota:** `/manual/topic/:id`
**Estado:** único (leitura)

### Layout

```
[AppBar: ← voltar | "LCF" centralizado | ♡ favoritar (direita)]

[CategoryTag — pill dark red: "Direito constitucional"]
[Título do artigo — grande, branco]
[MetaRow: ⏱ "{n} min de leitura" | 📋 "Atualizado em {mês/ano}"]

[SobreEsteResumoCard — dark card]
  [Header: ✦ "Sobre este resumo"]
  [Texto explicativo da metodologia]

[SectionDivider: "Resumo" com linha horizontal]

[Lista de 6 seções, cada uma:]
  [Row: 🔵{n} {Título da seção} | "Ver mais" (link)]
  [Texto resumo da seção]
  [Divider horizontal]
```

### Seções exibidas no design

| Nº | Título |
|----|--------|
| 1 | Conceito |
| 2 | Estrutura |
| 3 | Fundamentação Legal |
| 4 | Jurisprudência |
| 5 | Principais pontos |
| 6 | Conclusão |

### ⚠️ Conflito #3 — Estrutura de seções do Manual

A spec técnica (`CLAUDE.md` — Decisões Fixadas) define a **estrutura canônica v1.0**:
> `fundamento → artigos centrais → exemplo prático → atenção → OAB → resumo`

O design apresenta seções diferentes e mais genéricas. Os pipelines de geração de conteúdo (`generate_topic_content.py`) produzem conteúdo na estrutura canônica.

**Decisão pendente:** adotar a estrutura do design (Conceito → Conclusão) ou manter a canônica. Impacta tanto o pipeline quanto o frontend.

### Dados consumidos

| Dado | Campo |
|------|-------|
| Conteúdo | `GET /manual/topics/:id` |
| Marcar como lido | `POST /manual/topics/:id/read` |
| Favoritar | *(endpoint a definir — não está na spec atual)* |

### Observação
- "Ver mais" por seção pode expandir inline ou navegar para sub-tela.
- O coração de favoritar não tem endpoint mapeado no backend — verificar se entra no MVP.

### Tutor contextual flutuante (orbe-robô) — decidido jun/2026

Ponto de entrada do Tutor IA dentro do resumo. Substitui o antigo gatilho ⚡ por seção (removido) por um **orbe flutuante único** com contexto do tópico inteiro.

- **Orbe-robô** — botão circular flutuante (canto inferior direito), fundo `AppColors.accent`, borda `AppColors.accentLight`, **ícone/imagem do robô** do Tutor (sem texto "Lex").
- **Abrir** — ao tocar, scrim translúcido leve (~12%, **sem blur** no fundo) e a **gaveta de vidro** sobe; o orbe **anima e ancora no topo da gaveta** como cabeçalho.
- **Cancelar** — tocar fora ou no orbe novamente reverte a animação.
- **Gaveta** — padrão de vidro translúcido (ver `DESIGN_TOKENS.md` › Padrão de Vidro Translúcido): translúcida, sem blur, cantos 30px, **fio dourado de acabamento** no topo.
- **Conteúdo (sólido/opaco)** — 3 pills de ação rápida ("Resumo para a prova", "Como cai na OAB?", "Exemplo prático") + barra de input **idêntica à do chat** (reusar o widget `ChatInputBar`).
- **Navegação** — tocar numa pill ou enviar texto → `context.push('/tutor/context', extra: TutorScreenArgs(initialMessage, topicContext: TutorTopicContext(topicTitle, topicContent)))`. Contexto = tópico inteiro.
- **Header do Tutor em modo contexto** — `LcfTutorAppBar` com `showBack: true` exibe um voltar **sutil**: seta + texto **"Resumo"** (não "Voltar para o resumo"); o bloco de avatar/identidade do topo é **omitido** nesse modo (fica subentendido). A tab `/tutor` normal permanece inalterada.

Arquivos: `manual_detail_screen.dart`, `manual_tutor_sheet.dart` (redesenhado), `topic_section_tile.dart` (⚡ removido), `tutor_screen.dart`/`LcfTutorAppBar` (header), `shared/widgets/lcf_glass_sheet.dart` (novo).

---

## 7. Perfil

**Rota:** `/perfil` — tab Perfil ativa no BottomNav

### Layout (scroll vertical)

```
[AppBar: ← voltar | "LCF" centralizado]

[ProfileHeader]
  [Avatar — círculo, overlay 📷 para editar]
  [Nome completo]
  [E-mail]
  [Badge: "Membro Pró" — pill dark]

[DadosPessoaisCard]
  [Header: 👤 "Dados pessoais" | ✏️ Editar (botão)]
  [Linha: Nome completo]
  [Linha: E-mail]
  [Linha: Telefone]
  [Linha: Data de nascimento]
  [Linha: CPF]
  (cada linha com label em cima + valor em baixo + divider)

[SegurancaCard]
  [Header: 🛡️ "Segurança da conta"]
  [Row: 🔒 "Alterar senha" + subtítulo | chevron →]

[LcfProBannerCard — borda gold]
  [Header: 👑 "LCF PRÓ"]
  [Subtítulo]
  [Lista de 4 features com ✅ gold]
  [Button: "Gerenciar plano" — full-width gold]

[PreferenciasCard]
  [Header: ⚙️ "Preferências"]
  [Row: "Tema do aplicativo" | "Escuro" + chevron →]

[Button: "Sair do aplicativo" — outlined, texto muted/vermelho escuro]
```

### Variantes do PRO Banner

| Situação | Conteúdo do banner |
|----------|--------------------|
| Usuário Free | Banner de upgrade com CTA "Assinar PRÓ" → `/subscription` |
| Usuário PRÓ | Banner com features + "Gerenciar plano" → RevenueCat manage |

### Dados consumidos

| Seção | Endpoint |
|-------|----------|
| Dados do perfil | `GET /users/profile` |
| Atualizar dados | `PUT /users/profile` |
| Plano atual | Campo `plan` retornado pelo profile |

### Observações
- "Membro Pró" badge: exibir apenas se `plan === "pro"`.
- Avatar edit: upload de imagem — endpoint a definir, não está na spec atual.
- CPF: campo de dado sensível — confirmar se é coletado/necessário para o MVP.
- "Tema do aplicativo" → por ora o app é dark only. Este item pode ser decorativo no MVP.

---

## 8. Assinatura PRÓ

**Rota:** `/subscription` (fora do ShellRoute ou como modal/bottom sheet)

### Layout (scroll vertical)

```
[AppBar: ← voltar | "LCF" centralizado]

[Header: 👑 "LCF PRÓ" + subtítulo]
[Grid 2×2 de FeatureBlocks]
  [📤 Todos os materiais liberados     ] [🎯 Revisões ilimitadas e inteligentes]
  [✅ Simulados avançados e relatórios ] [💬 Suporte prioritário com IA        ]

[PlanCard — borda gold, selecionado]
  [Left: "Plano mensal" + "cancele quando quiser"]
  [Right: "R$ 49,90 / mês"]                          ⚠️

[FormasPagamentoCard]
  [Header: "Forma de pagamento" | "Cancelar assinatura" (link)]
  [Row: 💳 "Cartão de crédito / Pagamento recorrente mensal" | chevron →]

[DadosCartaoCard]                                     ⚠️ Ver conflito #1
  [Header: "Dados do cartão" | 🔒 "Seus dados estão protegidos"]
  [TextField: "Nome do cartão"]
  [TextField: "Número do cartão" — masked]
  [Row: TextField "Validade MM/AA" | TextField "CVV" + ? ajuda]
  [Row: 💳 "Alterar dados de pagamento" | chevron →]

[ResumoCard]
  [Linha: Plano — "LCF PRÓ mensal"]
  [Linha: Valor mensal — "R$49,90" (gold)]          ⚠️
  [Linha: Próxima cobrança — data]

[InfoBanner: texto informativo sobre cobrança mensal e cancelamento]

[Button: "Assinar e ativar plano pró" — full-width gold]
[Rodapé: 🔒 "Ambiente 100% seguro com criptografia"]
```

### ⚠️ Conflito #1 — Preço

Design exibe **R$49,90/mês**. Documentação técnica define **R$29,90/mês · R$249,90/ano**.
**Decisão pendente:** alinhar preço com estratégia de negócio antes de configurar no RevenueCat e implementar a tela.

### ⚠️ Conflito #4 — Formulário de cartão vs RevenueCat IAP

O design apresenta um formulário de cartão de crédito customizado. A arquitetura definida usa **RevenueCat com Apple IAP + Google Play Billing**.

RevenueCat **não usa formulário de cartão customizado** — o pagamento passa pela sheet nativa da App Store / Google Play, que o usuário já conhece e que tem seus dados de pagamento salvos.

**Impacto:** A tela de assinatura no app deve:
1. Mostrar os planos (mensal / anual)
2. Ao confirmar → chamar RevenueCat SDK `Purchases.purchasePackage()`
3. A sheet de pagamento nativa da store abre automaticamente
4. Sem formulário de cartão customizado

O design atual desta tela precisa ser **revisado pelo designer** para refletir o fluxo real do RevenueCat.

---

## Telas Pendentes de Design

| Tela | Módulo backend | Prioridade |
|------|---------------|-----------|
| Tutor IA — Estado de chat | M4 | Alta |
| Manual — Lista de tópicos | M3 | Alta |
| Simulados — Lista | M5 | Alta |
| Simulados — Em andamento | M5 | Alta |
| Simulados — Resultado | M5 | Alta |
| Anotações — Lista | M6 | Alta |
| Anotações — Criação/edição | M6 | Alta |
| Quiz Diagnóstico | M1 | Média |
| Esqueci minha senha | Auth | Média |
| Tela de carregamento / Splash | — | Baixa |

---

---

## 9. Tutor IA — Estado de chat

**Rota:** `/tutor` (mesma rota do estado vazio — estado gerenciado pelo `TutorNotifier`)
**Estado:** `chat` — sessão ativa com ≥1 mensagem
**Transição:** estado vazio → chat ao enviar primeira mensagem

### Layout

```
[AppBar: igual ao estado vazio — LCF box | "Tutor IA" | subtítulo]

[ListView de mensagens — ocupa todo o espaço disponível]
  [ChatBubble usuário — alinhada à direita]
    Container arredondado, borda accent 30% opacidade, fundo accent 20%
    Texto branco, sem avatar

  [ChatBubble IA — alinhada à esquerda]
    Avatar robô (círculo gold 32px) + Container arredondado backgroundCard
    Texto branco
    [ChipsRow — abaixo da última mensagem da IA apenas]
      4 chips de resposta rápida retornados pelo backend

  [TypingIndicator — visível enquanto isLoading]
    Avatar robô + container com 3 pontos animados (fade loop)

[ChatInputBar — fixed bottom, idêntico ao estado vazio]
```

### ChipsRow (resposta rápida)

Os 4 chips são retornados pelo backend em `response.chips`. Renderizar apenas abaixo da **última** mensagem da IA. Ao clicar num chip: envia como nova mensagem do usuário.

```
[Row horizontal scrollável]
  [Chip: texto do chip, borda border, pill shape]
  [Chip: ...]
  [Chip: ...]
  [Chip: ...]
```

### Dados / Ações

| Ação | API |
|------|-----|
| Criar sessão (lazy, na 1ª mensagem) | `POST /tutor/session/new` → `{ session_id }` |
| Enviar mensagem | `POST /tutor/message` → `{ reply, chips, autoSavedAnnotationId? }` |
| Encerrar sessão (ao sair da tela) | `DELETE /tutor/session/:id` |

### Rate limit (Free vs PRO)

| Plano | Limite | Comportamento ao atingir |
|-------|--------|--------------------------|
| Free | 20 msgs/dia | Backend retorna `429` → exibir `ProGateSheet` |
| PRO | 200 msgs/dia | Raramente atingido |

### Auto-save de anotação (PRO)

Se `response.autoSavedAnnotationId != null`, exibir snackbar discreto abaixo do ChatInputBar:
`"✓ Anotação salva automaticamente"` — desaparece após 3s.

---

## 10. Manual — Lista de tópicos

**Rota:** `/manual` — acessível via "Ver todas" no Dashboard ou futura tab
**Estado:** `loading` / `list` / `empty` / `search`

### Layout

```
[AppBar: ← voltar | "LCF" centralizado | 🔍 search icon]

[SearchBar — aparece ao tocar 🔍, colapsa com X]
  TextField: "Buscar tópicos, artigos..."
  (chama GET /manual/search?q=... com debounce 400ms)

[FilterChipsRow — horizontal scroll]
  [Chip: Todos] [Chip: Constitucional] [Chip: Civil] [Chip: Penal]
  [Chip: Trabalho] [Chip: Processo Civil] [Chip: Administrativo]
  Selecionado: borda gold, fundo accent 15%

[ListView de TopicCards]
  Cada card:
    [Row]
      [Left]
        [CategoryTag — pill colorido por matéria]
        [Título do tópico — bodyLarge]
        [Row: ⏱ "X min" | 📋 "Atualizado em mês/ano"]
      [Right]
        [✅ ícone gold se isRead — ou círculo vazio]

[EmptyState — se lista vazia após filtro]
  Ícone livro + "Nenhum tópico encontrado"
```

### TopicCard — detalhes

- Background: `backgroundCard`
- Borda: `border` (padrão) ou `borderAccent` se `isRead` (sutil highlight)
- Tap → navega para `/manual/topic/:id`
- CategoryTag: cor por matéria (definir paleta → ver tabela abaixo)

### Paleta de cores por matéria (tags)

| Matéria | Background tag |
|---------|---------------|
| Constitucional | `#1A3A5C` (azul escuro) |
| Civil | `#1A3A2A` (verde escuro) |
| Penal | `#5C1A1A` (vermelho escuro) |
| Trabalho | `#3A2A1A` (marrom) |
| Proc. Civil | `#2A1A5C` (roxo escuro) |
| Administrativo | `#1A3A3A` (teal escuro) |
| OAB / Geral | `#3A3A1A` (amarelo escuro) |

### Dados consumidos

| Estado | Endpoint |
|--------|----------|
| Lista completa | `GET /manual/topics` |
| Filtro por matéria | `GET /manual/topics?lawCode=CC` |
| Busca | `GET /manual/search?q={termo}` |

---

## 11. Simulados — Configuração e início

**Rota:** `/simulados`
**Estado:** `config` (configuração antes de iniciar)

### Layout

```
[AppBar: ← voltar | "LCF" centralizado]

[HeaderCard — dark card]
  [Título: "Simulado"]
  [Row de stats: total respondidas | taxa de acerto média]

[ModeCard — seleção de modo]
  [Header: "Modo do simulado"]
  [Grid 2×2 ou lista de ModeOptions]
    [🎓 OAB Fase 1] [⚖️ OAB Fase 2]
    [📚 Por matéria] [🎯 Pontos fracos]
  Selecionado: borda gold

[SubjectSelector — aparece apenas se modo "Por matéria"]
  [Dropdown ou chips de seleção de matéria]

[QuantitySelector]
  [Header: "Número de questões"]
  [Row de chips: 10 | 15 | 30 | 50 | 100]
  Free: apenas 10 e 15 habilitados, restantes com 🔒 PRO
  PRO: todos habilitados

[Button: "Iniciar simulado" — full-width gold]

[HistoricoSection]
  [Header: "Histórico recente" | "Ver todos >"]
  [Lista de últimas 3 tentativas]
    Cada item: modo + matéria + score + data
```

### Limites Free vs PRO

| Config | Free | PRO |
|--------|------|-----|
| Máx questões | 15/dia (Redis) | ilimitado |
| Modos disponíveis | OAB Fase 1 e Por matéria | todos |
| Histórico | últimas 3 | completo |

### Dados / Ações

| Ação | Endpoint |
|------|----------|
| Iniciar | `POST /simulados/start` body: `{ mode, subject?, totalQ }` |
| Histórico | `GET /simulados/history` |
| Conflito (já existe em andamento) | Backend retorna `409 SIMULADO_IN_PROGRESS` com `inProgressId` → navegar para `/simulados/:id` |

---

## 12. Simulados — Em andamento

**Rota:** `/simulados/:id`
**Estado:** `answering` / `answered` (aguardando próxima)

### Layout

```
[AppBar: [X abandonar — left] | "Questão X de Y" | [timer — right se PRO]]

[ProgressBar linear — gold fill, backgroundCard bg]

[QuestionCard — dark card, scroll interno se texto longo]
  [CategoryTag: matéria + ano + banca]
  [Enunciado da questão — bodyLarge]

[OptionsColumn]
  Cada opção (A, B, C, D):
    [Row: [Letra em círculo] [Texto da opção]]
    Estado neutro: borda border, fundo backgroundCard
    Estado selecionado (aguardando confirm): borda accent, fundo accent 10%
    Estado correto (após submit): borda verde, fundo verde 10%, checkmark
    Estado errado (após submit): borda vermelha, fundo vermelho 10%, X

[ActionButton — full-width]
  Antes de selecionar: desabilitado "Selecione uma alternativa"
  Após selecionar (não confirmado): gold "Confirmar resposta"
  Após confirmar: gold "Próxima questão" (ou "Ver resultado" na última)

[AbandonButton — link text, bottom]
  "Abandonar simulado" → bottom sheet de confirmação
```

### Fluxo de resposta

1. Usuário toca opção → seleciona (highlight accent)
2. Usuário toca "Confirmar resposta" → `POST /simulados/:id/answer`
3. Backend retorna correto/errado → highlight verde/vermelho nas opções
4. Usuário toca "Próxima questão" → avança
5. Na última questão → `POST /simulados/:id/complete` → navega para `/simulados/:id/results`

### Dados / Ações

| Ação | Endpoint |
|------|----------|
| Responder | `POST /simulados/:id/answer` body: `{ questionId, answer, timeSpentSecs? }` |
| Completar | `POST /simulados/:id/complete` |
| Abandonar | `POST /simulados/:id/abandon` → volta para `/simulados` |

---

## 13. Simulados — Resultado

**Rota:** `/simulados/:id/results`
**Estado:** único (leitura)

### Layout

```
[AppBar: ← voltar | "LCF" centralizado]

[ScoreHeader — card com fundo especial]
  [% de acerto em destaque — accentLarge]
  [Badge: "Aprovado" (verde) ou "Reprovado" (vermelho) — baseado em ≥60%]
  [Row: Total | Corretas | Erradas | Tempo]

[PerformanceBySubjectCard]
  [Header: "Desempenho por matéria"]
  [Lista de matérias com barra de progresso percentual]

[QuestionsReviewList]
  [Header: "Revisão das questões"]
  Cada item:
    [Row: letra da resposta do usuário | ✅ ou ❌ | matéria]
    [Enunciado resumido]
    [Resposta correta destacada]
    [Explicação — APENAS PRO]
      Free: bloco travado com 🔒 "Assine o PRÓ para ver a explicação"

[CTARow — fixed bottom ou ao fim da lista]
  [Button: "Novo simulado" — full-width gold]
  [Link: "Voltar ao início"]
```

### Free vs PRO no resultado

| Campo | Free | PRO |
|-------|------|-----|
| Score, corretas, erradas | ✅ | ✅ |
| Desempenho por matéria | ✅ | ✅ |
| Resposta correta | ✅ | ✅ |
| Explicação da questão | ❌ bloqueado | ✅ |

### Dados consumidos

`GET /simulados/:id/results` — o backend já diferencia o response por plano (Free não recebe `explanation`).

---

## 14. Anotações — Lista

**Rota:** `/anotacoes` — tab Anotações ativa no BottomNav
**Estado:** `loading` / `list` / `empty` / `search`

### Layout

```
[AppBar: "LCF" centralizado | 🔍 search | ✏️ nova anotação]

[SearchBar — expansível, mesma lógica do Manual]
  Busca em title e content (GET /annotations com parâmetro q)

[FilterChipsRow]
  [Chip: Todas] [Chip por matéria] [Chip por tag]

[ListView de AnnotationCards]
  Cada card:
    [Row: Título — labelLarge | Data — labelSmall right]
    [Row de TagChips — pills pequenos, accent border]
    [Preview do conteúdo — bodySmall, max 2 linhas, overflow ellipsis]
    [SubjectTag — pill se tiver subject]

[EmptyState — se sem anotações]
  Ícone caderno + "Nenhuma anotação ainda"
  Button: "Criar primeira anotação"

[FAB — botão flutuante, gold, ícone +]
  → navega para /anotacoes/nova
```

### Dados consumidos

| Estado | Endpoint |
|--------|----------|
| Lista | `GET /annotations` |
| Filtro por tópico | `GET /annotations?topicId=:id` |

### Observação
- Anotações auto-salvas pelo Tutor IA (PRO) aparecem aqui com indicador especial (ícone robô pequeno).

---

## 15. Anotações — Criação e edição

**Rota:** `/anotacoes/nova` (criação) / `/anotacoes/:id/editar` (edição)
**Estado:** `creating` / `editing`

### Layout

```
[AppBar: [X cancelar — left] | "Nova anotação" ou "Editar" | [Salvar — right, textButton gold]]

[TitleField]
  TextField grande, sem borda visível, placeholder "Título da anotação"
  fontSize 20, fontWeight bold

[SubjectSelector]
  Label: "Matéria"
  Dropdown ou bottom sheet com opções de matéria
  Selecionado: mostra o valor + X para limpar

[TagsInput]
  Label: "Tags"
  Campo de texto para adicionar tags com chip inline
  Enter ou vírgula adiciona a tag
  Cada tag: chip com X para remover

[ContentField]
  TextField multiline, altura mínima 200px
  Placeholder "Escreva sua anotação..."
  Expande com o conteúdo

[ArticleRefRow — opcional, aparece se veio de contexto]
  "📎 Vinculada a: {topic_title}" ou "{lawCode} Art. {n}"
  X para desvincular
```

### Dados / Ações

| Ação | Endpoint |
|------|----------|
| Criar | `POST /annotations` body: `{ topicId?, lawCode?, articleRef?, content, highlight? }` |
| Editar | `PUT /annotations/:id` body: `{ content }` |
| Deletar | `DELETE /annotations/:id` — via swipe ou botão na tela de edição |

---

## 16. Quiz Diagnóstico / Nivelamento

**Rota:** modal ou `/diagnostico` (push, sem BottomNav)
**Trigger:** `nivelamentoPendente: true` no response do Dashboard — exibir prompt na primeira visita
**Estado:** `intro` / `answering` / `done`

### Layout — Estado intro

```
[Header: "Quiz Diagnóstico" — sem botão voltar]
[Ícone balança em círculo gold — grande]
[Título: "Vamos personalizar seu aprendizado"]
[Subtítulo: "Responda algumas questões para calibrar seu plano de estudos"]
[Info: ⏱ "5 minutos" | 📋 "15 questões"]

[Button: "Começar diagnóstico" — full-width gold]
[Link: "Fazer depois" → POST /onboarding/diagnostic/dismiss]
```

### Layout — Estado answering

```
[Header: "Diagnóstico" | ProgressBar: questão X de 15]
[QuestionCard — mesmo padrão dos Simulados]
  Sem timer, sem opção de abandonar
  Opções: A, B, C, D
[Button: "Próxima" — aparece após selecionar]
```

### Layout — Estado done

```
[Ícone de conclusão — checkmark gold em círculo]
[Título: "Diagnóstico concluído!"]
[Subtítulo: "Seu plano de estudos foi personalizado"]
[Button: "Ir para o Dashboard" — full-width gold]
```

### Dados / Ações

| Ação | Endpoint |
|------|----------|
| Questões do diagnóstico | `GET /simulados/questions?limit=15` (reutiliza endpoint) |
| Concluir | `POST /onboarding/diagnostic/complete` → seta `nivelamentoPendente: false` |
| Dispensar | `POST /onboarding/diagnostic/dismiss` → seta `nivelamentoPendente: false` |

### Observação
- Questões do diagnóstico são questões OAB reais do banco — sem simulado formal, sem registro em `SimuladoAttempt`.
- O path (oab/graduation) é determinado pelo `academicPhase` do onboarding.

---

## 17. Esqueci minha senha

**Rota:** `/esqueci-senha` (push a partir do Login)
**Estado:** `input` / `sent`

### Layout — Estado input

```
[AppBar: ← voltar | "LCF" centralizado]
[Ícone cadeado em círculo gold]
[Título: "Recuperar senha"]
[Subtítulo: "Digite seu e-mail e enviaremos um link de recuperação"]
[TextField: ✉️ "Seu e-mail"]
[Button: "Enviar link" — full-width gold]
```

### Layout — Estado sent

```
[Ícone envelope com checkmark — gold]
[Título: "E-mail enviado!"]
[Subtítulo: "Verifique sua caixa de entrada e siga as instruções"]
[Button: "Voltar ao login" → context.go('/login')]
```

### Dados / Ações

`supabase.auth.resetPasswordForEmail(email)` — sem endpoint LCF direto.

---

## Conflitos Design vs Documentação

> Documentação técnica (`CLAUDE.md` + `PROJECT_STATE.md`) é a fonte de verdade.
> Design divergente nestes pontos deve ser ignorado na implementação.

| # | Tela | Design (ignorar) | Implementar conforme docs |
|---|------|-----------------|--------------------------|
| 1 | Assinatura | R$49,90/mês | **R$29,90/mês · R$249,90/ano** (CLAUDE.md — Decisões Fixadas) |
| 2 | Login | Botão "Entrar com Apple" | **Sem Apple Sign In** — removido do escopo |
| 3 | Assinatura | Formulário de cartão customizado | **RevenueCat IAP nativo** — sem form custom; designer precisa redesenhar esta tela |
| 4 | Manual detalhe | 6 seções genéricas (Conceito → Conclusão) | **Estrutura canônica v1.0**: fundamento → artigos centrais → exemplo prático → atenção → OAB → resumo |

---

## Campos de dados UI não mapeados na API

Verificar se precisam de endpoint ou se são dados locais/calculados:

| Campo | Tela | Status |
|-------|------|--------|
| Favoritar tópico (♡) | Manual detalhe | Sem endpoint no backend |
| CPF | Perfil | Sem campo no schema Prisma |
| Telefone | Perfil | Sem campo no schema Prisma |
| Data de nascimento | Perfil | Sem campo no schema Prisma |
| Tema do aplicativo | Perfil | Local apenas (SharedPreferences) |
| Avatar / foto de perfil | Perfil | Sem endpoint de upload |
| Tarefas rápidas | Dashboard | Navegação local, sem API |
