# LEX — Visual Identity Brief
> Documento de referência para Claude Designs.
> Fonte de verdade para todos os elementos visuais customizados do app LEX.
> Leia este arquivo antes de criar qualquer ativo visual.

---

## O Produto

**LEX** é um app EdTech jurídico mobile-first (iOS + Android). Estudantes de Direito e candidatos ao Exame da OAB usam o LEX para estudar legislação, praticar questões e interagir com a **Lexia** — a tutora IA jurídica do produto.

Público: jovens adultos em preparação para a OAB. Ambiente mobile, uso diário, contexto de estudo sério.

**Personalidade visual:** Confiança acadêmica com calor humano. Não é corporativo frio, não é gamificado demais. É o equivalente visual de "uma biblioteca com luz quente de lamparina".

---

## Paleta Oficial (fonte de verdade)

> Extraída de `lib/core/theme/app_colors.dart` — valores absolutos, nunca usar os do DESIGN_TOKENS.md (está desatualizado).

```
BACKGROUNDS
  background      #1A0800   ← fundo de tela (marrom escuro profundo)
  backgroundCard  #2D1200   ← cards e containers
  backgroundSheet #3D1200   ← bottom sheets, modais
  backgroundNav   #140600   ← nav bar

GOLD / ACCENT (cor identidade)
  accent          #C9922A   ← dourado primário — brand color, PRÓ, streak
  accentDark      #9A6B1A   ← hover/pressed
  accentLight     #E8B84B   ← highlight, shimmer

BORDERS
  border          #3D2010   ← borda padrão
  borderAccent    #C9922A   ← borda selecionada/ativa
  borderMuted     #2A1508   ← borda sutil

TEXTO
  textPrimary     #FFFFFF   ← texto principal
  textSecondary   #9E8472   ← texto secundário
  textMuted       #6B5240   ← placeholders, disabled

SEMÂNTICAS
  success         #4CAF50   ← verde (certo no quiz)
  error           #8B2020   ← vermelho (errado)
  streakFire      #FF6B00   ← laranja do fogo do streak

GRADIENTE DOURADO
  #C9922A → #E8B84B (top-left → bottom-right)
```

---

## Padrão de Vidro (Glass Pattern)

Superfícies que sobem (bottom sheets, modais, orbs) seguem o padrão de vidro translúcido:

- **Superfície externa:** cor de fundo com 30% de opacidade (`backgroundCard` a 0.30)
- **Blur/frost:** `BackdropFilter` com sigma 10 aplicado SOMENTE na superfície, nunca no fundo
- **Fio dourado:** hairline de 1.5px em `accent` com 60% de opacidade no topo da superfície
- **Conteúdo:** sempre sólido e opaco por cima do vidro
- **Cantos:** 24–30px nos cantos superiores

---

## Tipografia

Font family: **Inter** (Google Fonts)

```
logoTitle: 22px, weight 700, color accent #C9922A, letterSpacing 2
h1:       24px, weight 700, textPrimary
h2:       20px, weight 700, textPrimary
h3:       18px, weight 600, textPrimary
body:     16px / 14px / 12px, weight 400
label:    14px / 12px / 10px, weight 600 / 500 / 400
```

---

## Regra das Cores no App

```
Gold #C9922A → Identidade de marca: logo, PRÓ, streak ativo, anel de progresso
              → NÃO usar em feedback semântico (erro/sucesso/info), NÃO em inputs

Branco → Texto primário sobre fundos escuros

Vermelho #8B2020 → Apenas erros e ações destrutivas

Verde #4CAF50 → Apenas feedback de acerto no quiz
```

---

## Formato dos Assets

**Destino:** `lcf/front/lex_app/assets/icons/` (SVGs inline no Flutter via `flutter_svg`)

Especificações técnicas:
- Formato: SVG
- ViewBox: 24×24 para ícones de 16–28px; 48×48 para ícones de 32–56px; 96×96 para logomark
- Paleta: usar valores hex exatos acima — sem cores fora da paleta
- Estilo: linhas limpas, weight consistente com os ícones Material do sistema (~2px stroke)
- Filosofia: reconhecível em 16px, bonito em 56px

---

## Inventário de Elementos a Criar

### GRUPO A — Identidade de Marca (Prioridade 1)

#### A1 — Logomark LEX

**O que é:** O símbolo central da marca. Aparece:
- Tela de login: círculo de 88×88px com borda gold 2px
- App bar: versão reduzida (apenas texto "Lex" no estilo `logoTitle` atualmente)
- Deve funcionar como ícone de app (standalone)

**Referência do design original (SCREENS.md):**
> "círculo gold com texto + balança + livro"

**Conceito esperado:**
- Círculo (ou shape derivado) com borda dourada #C9922A
- Letras "LEX" em dourado, peso 700, Inter
- Elementos jurídicos integrados ao símbolo: balança da justiça e/ou livro aberto
- Tom: autoridade + acessibilidade. Não é o martelo do juiz — é a balança que pesa, o livro que ilumina.

**Variantes necessárias:**
- `logo_mark.svg` — símbolo completo (texto + ícone), viewBox 96×96
- `logo_icon.svg` — apenas o símbolo sem texto (para favicons, orb do tutor), viewBox 48×48

**Contexto de uso Flutter:**
```dart
// login_screen.dart — círculo de 88×88 com borda gold
Container(
  width: 88, height: 88,
  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.borderAccent, width: 2)),
  child: Text('Lex', style: AppTextStyles.logoTitle), // ← substituir por SvgPicture
)
```

---

#### A2 — Lexia (Tutora IA) — Avatar e Orb

**O que é:** A identidade visual da Tutora IA do LEX. Atualmente um ícone genérico `Icons.smart_toy` (robô). Lexia é o coração do produto — precisa de uma identidade própria.

**Conceito:** Não um robô genérico. Lexia é uma entidade jurídica sábia — pense em algo que evoca expertise + acessibilidade, sem ser humano realista. Pode ser:
- Uma balança estilizada com elementos que sugerem "mente ativa"
- Um símbolo jurídico com aura de IA (circuitos suaves, brilho dourado)
- Uma figura abstrata feminina (veste acadêmica + elementos digitais)
- Um "oráculo dourado" — forma circular com elementos de lei dentro

**Variantes necessárias:**

`lexia_avatar.svg` — 48×48 — para chat bubble (circle container com gold border)
`lexia_orb.svg` — 56×56 — para o botão flutuante (fundo accent, borda accentLight)
`lexia_badge.svg` — 16×16 — badge pequeno nas anotações auto-salvas pela IA

**Contexto de uso Flutter:**
```dart
// tutor_welcome_card.dart — 48×48 circle com gold border
Container(
  width: 48, height: 48,
  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.borderAccent, width: 1.5)),
  child: Icon(Icons.smart_toy, color: AppColors.accent, size: 28), // ← substituir
)

// manual_tutor_orb.dart — 56×56 floating button
// fundo: AppColors.accent (#C9922A), ícone branco
Icon(Icons.smart_toy_outlined, color: Colors.white, size: 26) // ← substituir

// chat_bubble.dart — 18×18 circle com gold border, fundo backgroundCard
Icon(Icons.smart_toy, color: AppColors.accent, size: 18) // ← substituir
```

---

### GRUPO B — Ícones de Feature (Prioridade 1)

#### B1 — Crown PRÓ

**O que é:** Ícone que representa o plano PRÓ do LEX. Atualmente `Icons.workspace_premium` (genérico).

**Conceito:** Coroa com personalidade — não a coroa emoji genérica. Uma coroa clean, geométrica, com peso visual coerente com Inter. Pode ter um detalhe dourado que referencia os elementos jurídicos (pequena balança no topo central, ou iniciais L).

**Tamanhos de uso:**
- 64px: tela "Você já é PRÓ!"
- 20px: LexProBannerCard, header da SubscriptionScreen
- 16px: ProGateSheet (check circle ao lado)

**Asset:** `crown_pro.svg` — viewBox 24×24 (escala por size no Flutter)

**Cor:** sempre `#C9922A` (accent gold) — nunca hard-coded, será colorido via `color:` no Flutter

---

#### B2 — Streak Flame (Fogo)

**O que é:** Chama do streak de estudos. Atualmente `Icons.local_fire_department`.

**Conceito:** Uma chama limpa e geométrica, mais elegante do que o ícone genérico de bombeiro. Deve transmitir energia + disciplina. Cor `#FF6B00` (streakFire).

**Tamanho principal:** 20px (greeting card do dashboard)

**Asset:** `streak_flame.svg` — viewBox 24×24

---

#### B3 — Trophy / Conquista

**O que é:** Troféu que aparece no greeting card quando streak ≥ 7 dias.

**Conceito:** Troféu minimalista, linhas limpas. Pode ter uma estrela ou raio dourado no topo.

**Tamanho:** 16px ao lado do badge de streak

**Asset:** `trophy.svg` — viewBox 24×24

---

### GRUPO C — Fases do Onboarding (Prioridade 2)

**Contexto:** Grade 2×2 de seleção de fase acadêmica. Card 80×80 aprox., ícone centralizado, estado selecionado com border gold.

**Atualmente:** emojis 🎓 📖 ⚖️ 🎒 — genéricos e inconsistentes visualmente.

**Cada ícone deve:**
- Funcionar em fundo `#2D1200` (backgroundCard)
- Ser reconhecível em ~32px
- Ter o mesmo peso visual (coerência entre os 4)
- Referenciar o Direito/juridico quando possível

| Asset | Label | Emoji atual | Conceito |
|-------|-------|-------------|----------|
| `phase_graduation_start.svg` | Início da faculdade | 🎓 | Capelo/diploma simples, início de jornada |
| `phase_graduation_mid.svg` | Meio da faculdade | 📖 | Livro aberto com páginas visíveis |
| `phase_graduation_end.svg` | Final da faculdade | ⚖️ | Balança da justiça (LEX style) |
| `phase_oab_prep.svg` | Estudando para OAB | 🎒 | Certificado/diploma OAB, ou medalha/lacre oficial |

**Paleta dos ícones de fase:**
- Estado não selecionado: cor `#6B5240` (textMuted)
- Estado selecionado: cor `#C9922A` (accent)
- Implementação Flutter usa `color:` no SvgPicture — ícones devem ser monochrome (path único, sem fills internos conflitantes)

---

### GRUPO D — Benefícios PRÓ na Subscription (Prioridade 2)

**Contexto:** 4 ícones na tela de assinatura, exibidos em linha com label ao lado. ~28px cada.

**Atualmente:** emojis 📤 🎯 ✅ 💬 — inconsistentes e genéricos.

| Asset | Label | Emoji atual | Conceito |
|-------|-------|-------------|----------|
| `pro_materials.svg` | Todos os materiais liberados | 📤 | Livros/coleção desbloqueada (cadeado aberto + livro) |
| `pro_reviews.svg` | Revisões ilimitadas e inteligentes | 🎯 | Cérebro com seta de loop (revisão espacial) |
| `pro_simulados.svg` | Simulados avançados e relatórios | ✅ | Folha de prova com gráfico/resultado |
| `pro_support.svg` | Suporte prioritário com IA | 💬 | Balão de chat com ícone de raio/IA |

**Cor:** `#C9922A` (accent) — monochrome

---

### GRUPO E — Modos de Simulado (Prioridade 2)

**Contexto:** Grid de cards para selecionar modo do simulado. Ícone ~32px, centralizado no card. Estado selecionado: fundo accent com 10% opacidade, border gold.

**Atualmente:** `Icons.school_outlined`, `Icons.balance_outlined`, `Icons.menu_book_outlined`, `Icons.gps_fixed_outlined`

| Asset | Modo | Ícone atual | Conceito |
|-------|------|-------------|----------|
| `mode_oab1.svg` | 1ª Fase OAB | school_outlined | Selo/escudo oficial OAB, ou toga |
| `mode_oab2.svg` | 2ª Fase OAB (em breve) | balance_outlined | Balança + peça jurídica, mais elaborado |
| `mode_custom.svg` | Modo Personalizado | menu_book_outlined | Filtros/ajustes + livro |
| `mode_weak_areas.svg` | Áreas Fracas | gps_fixed_outlined | Radar/alvo com ponto fraco marcado |

**Cor:** monochrome, aplicada via `color:` no Flutter

---

### GRUPO F — Chips de Contexto do Tutor (Prioridade 3)

**Contexto:** Pills/chips na gaveta de vidro do Tutor quando aberto no Manual. Ícone 12px ao lado de label. Fundo sólido `#3D1200`.

**Atualmente:** `school_outlined`, `gavel_outlined`, `lightbulb_outline`, `chat_bubble_outline`

| Asset | Label | Ícone atual | Conceito |
|-------|-------|-------------|----------|
| `chip_explain.svg` | "Explica" | school_outlined | Raio + balão (insight rápido) |
| `chip_jurisprudence.svg` | "Jurisprudência" | gavel_outlined | Martelo + § (parágrafo) |
| `chip_tip.svg` | "Dica de prova" | lightbulb_outline | Estrela + lápis |
| `chip_question.svg` | "Faça uma pergunta" | chat_bubble_outline | Balão com ? |

**Obs:** Estes podem ser versões simplificadas dos ícones do Grupo B/E — reutilize conceitos.

---

## Hierarquia de Prioridade

```
PRIORIDADE 1 (bloqueante para identidade):
  A1 — Logomark LEX
  A2 — Lexia avatar/orb
  B1 — Crown PRÓ
  B2 — Streak Flame

PRIORIDADE 2 (impacto visual imediato):
  C1–C4 — Fases do Onboarding
  D1–D4 — Benefícios PRÓ
  E1–E4 — Modos de Simulado
  B3 — Trophy

PRIORIDADE 3 (polish):
  F1–F4 — Chips do Tutor
```

---

## O que NÃO deve ser tocado

O usuário confirmou: **nav bar fica como está** (Tutor, Anotações, Início, Perfil, Manual, Simulados — todos usando `Icons.*` do Material).

Ícones de chrome de UI que **não precisam de versão customizada:**
- Setas de navegação (arrow_back, arrow_forward)
- Fechar (close)
- Busca (search)
- Adicionar (add)
- Campos de formulário (email, lock, person)
- Ações de lista (delete, edit, chevron_right)
- Feedback de quiz (check_circle, cancel)
- Lock de gate (Icons.lock)
- Enviar mensagem (send)
- Histórico (history_rounded)
- Info e error (info_outline, error_outline)

---

## Estrutura de Entrega Esperada

```
lcf/front/lex_app/assets/icons/
├── logo_mark.svg          ← A1
├── logo_icon.svg          ← A1 (standalone)
├── lexia_avatar.svg       ← A2
├── lexia_orb.svg          ← A2
├── lexia_badge.svg        ← A2 (mini)
├── crown_pro.svg          ← B1
├── streak_flame.svg       ← B2
├── trophy.svg             ← B3
├── phase_graduation_start.svg  ← C1
├── phase_graduation_mid.svg    ← C2
├── phase_graduation_end.svg    ← C3
├── phase_oab_prep.svg     ← C4
├── pro_materials.svg      ← D1
├── pro_reviews.svg        ← D2
├── pro_simulados.svg      ← D3
├── pro_support.svg        ← D4
├── mode_oab1.svg          ← E1
├── mode_oab2.svg          ← E2
├── mode_custom.svg        ← E3
├── mode_weak_areas.svg    ← E4
├── chip_explain.svg       ← F1
├── chip_jurisprudence.svg ← F2
├── chip_tip.svg           ← F3
└── chip_question.svg      ← F4
```

---

## Referências Visuais

O app LEX tem estética de **"biblioteca jurídica digital noturna"**:
- Fundos: marrom escuro quase preto (`#1A0800`)
- Superfícies: marrom médio (`#2D1200`, `#3D1200`)
- Detalhes e destaques: dourado âmbar (`#C9922A`, `#E8B84B`)
- Tipografia: Inter, limpa, sem serifa

**Referências de produto com estética similar:**
- Duolingo (gamificação educacional com cores quentes)
- Notion (cards limpos, tipografia clara)
- Linear (ícones precisos, peso visual consistente)

**Palavras para o design:** Nobre, Estudioso, Acessível, Confiável, Quente.
**Anti-palavras:** Corporativo, Frio, Burocrático, Infantil.
