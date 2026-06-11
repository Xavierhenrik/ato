# LCF — Design Tokens

> Extraído das telas enviadas em 2026-05-21.
> ⚠️ A migração para azul-marinho (2026-06-09) foi **apenas um teste e sofreu rollback**. A paleta vigente é a **âmbar/dourado sobre fundo marrom escuro** — a fonte de verdade real é `lib/core/theme/app_colors.dart` (ex.: `background #1A0800`, `accent #C9922A`). Os valores azuis listados abaixo neste doc estão desatualizados e devem ser alinhados ao código.
> Implementar em `lib/core/theme/app_colors.dart` e `app_text_styles.dart`.
> Esta é a fonte de verdade de design. Nunca usar valores hardcoded no código.

---

## Cores

### Paleta base

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // Backgrounds (escuro → médio → claro)
  static const Color background      = Color(0xFF050D1A); // azul-marinho profundo
  static const Color backgroundCard  = Color(0xFF0D1E33); // cards e containers
  static const Color backgroundSheet = Color(0xFF122640); // bottom sheets, modais
  static const Color backgroundNav   = Color(0xFF030A14); // bottom navigation bar

  // Blue / Accent
  static const Color accent      = Color(0xFF2D7DD2); // azul primário
  static const Color accentDark  = Color(0xFF1A5CA0); // hover/pressed
  static const Color accentLight = Color(0xFF5BA3E8); // highlight

  // Amber / Highlight (terceira cor — identidade de marca, PRÓ, conquistas, streaks)
  static const Color amber      = Color(0xFFE8963A); // âmbar primário
  static const Color amberDark  = Color(0xFFBF7020); // hover/pressed
  static const Color amberLight = Color(0xFFF5BC72); // highlight suave
  static const Color amberGlow  = Color(0x33E8963A); // âmbar 20% opacidade — glows e tints

  // Bordas
  static const Color border       = Color(0xFF1A3352); // border padrão
  static const Color borderAccent = Color(0xFF2D7DD2); // border selecionado
  static const Color borderMuted  = Color(0xFF0F2035); // border sutil

  // Textos
  static const Color textPrimary   = Color(0xFFFFFFFF); // texto principal
  static const Color textSecondary = Color(0xFF7A9BBF); // azul-acinzentado
  static const Color textMuted     = Color(0xFF3D6080); // placeholders, disabled
  static const Color textAccent    = Color(0xFF2D7DD2); // links, destaque

  // Semânticas
  static const Color tagBackground = Color(0xFF0D2B4A); // tag de categoria
  static const Color success       = Color(0xFF2D7DD2); // checkmarks (usa accent)
  static const Color info          = Color(0xFF1A3A5C); // banner informativo
  static const Color error         = Color(0xFF8B2020); // erros
  static const Color errorBg       = Color(0xFF3A1A1A); // fundo de erro

  // Streak / Progresso
  static const Color streakFire   = Color(0xFFE8963A); // unificado com amber
  static const Color progressRing = Color(0xFFE8963A); // anel de progresso → amber
  static const Color progressBg   = Color(0xFF0D1E33);

  // Avatares / Status
  static const Color onlineDot = Color(0xFF4CAF50); // mantém verde
}
```

### Gradientes

```dart
// Gradiente do anel de progresso (DonutChart)
static const LinearGradient progressGradient = LinearGradient(
  colors: [Color(0xFF1A5CA0), Color(0xFF5BA3E8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

---

## Tipografia

```dart
// lib/core/theme/app_text_styles.dart

class AppTextStyles {
  static const String _fontFamily = 'Inter'; // ou sans-serif padrão se Inter não disponível

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );

  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle h3Accent = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.accent,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.textMuted,
  );

  // Accent / Blue
  static const TextStyle accentLarge = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.accent,
  );
  static const TextStyle accentMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent,
  );
  static const TextStyle link = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.accent,
    decoration: TextDecoration.underline,
  );

  // Logo / Brand
  static const TextStyle logoTitle = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.amber, letterSpacing: 2,
  );
}
```

---

## Espaçamentos

```dart
class AppSpacing {
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;

  // Padding padrão de tela
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  // Padding de card
  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  // Espaçamento entre seções
  static const double sectionGap = 20.0;
}
```

---

## Bordas e Raios

```dart
class AppRadius {
  static const double xs   = 6.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double full = 100.0; // chips, pills, badges

  // BorderRadius prontos
  static final BorderRadius card   = BorderRadius.circular(16);
  static final BorderRadius chip   = BorderRadius.circular(100);
  static final BorderRadius button = BorderRadius.circular(12);
  static final BorderRadius input  = BorderRadius.circular(10);
  static final BorderRadius sheet  = const BorderRadius.vertical(top: Radius.circular(24));
}
```

---

## Componentes Reutilizáveis

### LcfTextField

```
- Background: backgroundCard (#0D1E33)
- Border: 1px solid border (#1A3352)
- Border focused: 1px solid accent (#2D7DD2)
- Border radius: 10px
- Padding: 14px horizontal, 16px vertical
- ícone leading: textSecondary quando vazio, accent quando focused
- Placeholder: textMuted
- Texto digitado: textPrimary
- Senha: ícone 👁 à direita (toggle show/hide)
```

### LcfButton — Variantes

| Variante | Background | Texto | Border |
|----------|-----------|-------|--------|
| `primary` | `accent` (#2D7DD2) | branco, bold | nenhum |
| `secondary` | `backgroundCard` | branco | 1px border |
| `outline` | transparente | textMuted | 1px borderMuted |
| `social` | `backgroundCard` | branco | 1px border |
| `destructive` | transparente | error | 1px error |

Todos: `borderRadius: 12`, `height: 52px`, `width: double.infinity` por padrão.

### Card padrão

```
- Background: backgroundCard (#0D1E33)
- Border: 1px solid border (#1A3352)
- Border radius: 16px
- Padding: 16px
- Shadow: nenhuma (flat design)
```

### Card destacado (selecionado / PRÓ)

```
- Border: 1.5px solid accent (#2D7DD2)
- Background: pode ter leve tint azul (2D7DD2 com 10% opacidade)
```

### CategoryTag (pill)

```
- Background: tagBackground (#0D2B4A)
- Texto: textPrimary, 12px, weight 500
- Padding: 4px vertical, 10px horizontal
- Border radius: full (100px)
```

### Badge "Membro Pró"

```
- Background: amberGlow (0x33E8963A)
- Borda: 1px solid amber (#E8963A)
- Texto: amber, 12px, weight 600
- Padding: 4px 10px
- Border radius: full
```

### Streak Badge

```
- Background: backgroundSheet (inativo) / amberGlow (streak ≥ 7 dias)
- Borda: border (inativo) / amber (streak ≥ 7 dias)
- Ícone: 🔥 amber (#E8963A) — unificado com streakFire
- Número/texto: textSecondary (inativo) / amber (streak ≥ 7 dias), bold
- Troféu: amber quando streak ≥ 7 dias
- Padding: 6px 10px
- Border radius: full
```

### Regra de uso das três cores

```
Azul (accent #2D7DD2):
  - Ações primárias (botões, CTAs de navegação)
  - Estados de foco em inputs e formulários
  - Links, ícones de estado interativo
  - BottomNav ativo, chips de filtro selecionados

Âmbar (amber #E8963A):
  - Identidade de marca: logo "LCF" na AppBar
  - Plano PRÓ: badges, banners, ícone crown, border cards PRÓ
  - Conquistas e streaks ativos (≥ 7 dias)
  - Anel de progresso (progressRing) e fogo de streak (streakFire)
  - Gradiente amberGradient para DonutChart / ProgressRing

NUNCA usar âmbar em:
  - Feedback semântico (erro, sucesso, info) — reservados para vermelho/verde/azul
  - Inputs e formulários — sempre azul para foco
  - Ações destrutivas
```

### BottomNav

```
- Background: backgroundNav (#030A14)
- Altura: 60px + padding SafeArea
- Ícone ativo: accent (#2D7DD2)
- Label ativo: accent, 10px
- Ícone inativo: textMuted (#3D6080)
- Label inativo: textMuted, 10px
- Sem indicador/blob — apenas mudança de cor
```

### AppBar padrão (telas internas)

```
- Background: background (#050D1A) — sem elevação
- Título: "LCF" centralizado, logoTitle style
- Leading: ← ícone, textPrimary
- Actions: ícones textPrimary ou accent
```

### AppBar do Tutor IA

```
- Diferente do padrão:
- Leading: box com borda azul contendo "LCF" (logo box)
- Title alinhado à esquerda: "Tutor IA" bold + subtítulo menor
```

---

## Ícones

O projeto usa ícones customizados via SVG/assets. Para MVP, usar pacote `flutter_svg` com ícones Material como fallback.

Ícones identificados nas telas:

| Contexto | Ícone sugerido |
|----------|---------------|
| Tutor (nav) | robô — `Icons.smart_toy` ou asset SVG |
| Anotações (nav) | bookmark — `Icons.bookmark_outline` |
| Início (nav) | home — `Icons.home_outlined` |
| Perfil (nav) | person — `Icons.person_outline` |
| Favoritar | heart — `Icons.favorite_border` |
| Segurança | shield — `Icons.shield_outlined` |
| Preferências | settings — `Icons.settings_outlined` |
| Crown (PRÓ) | `Icons.workspace_premium` ou asset SVG |
| Streak | 🔥 asset SVG ou emoji |
| Balança (tutor) | `Icons.balance` ou asset SVG |
| Attach | `Icons.attach_file` |
| Mic | `Icons.mic_none` |
| Send | `Icons.send` (rotacionado ou seta →) |

---

## Animações

Padrão de animação do projeto (MVP — simples):

| Tipo | Duração | Curva |
|------|---------|-------|
| Transição de rota | 300ms | `Curves.easeInOut` |
| Fade in de card | 200ms | `Curves.easeOut` |
| Expand/collapse | 250ms | `Curves.easeInOut` |
| Tap feedback | `InkWell` com splashColor accent 20% opacidade | — |

---

## ThemeData Flutter

```dart
// lib/core/theme/app_theme.dart

ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.accent,
    surface: AppColors.backgroundCard,
    background: AppColors.background,
    onPrimary: Colors.white,
    onSurface: AppColors.textPrimary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyles.logoTitle,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.backgroundNav,
    selectedItemColor: AppColors.accent,
    unselectedItemColor: AppColors.textMuted,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.backgroundCard,
    border: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
    ),
    hintStyle: const TextStyle(color: AppColors.textMuted),
  ),
  cardTheme: CardTheme(
    color: AppColors.backgroundCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.card,
      side: const BorderSide(color: AppColors.border),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);
```

---

## Padrão de Vidro Translúcido (overlays)

> Decidido na ideação do tutor contextual do Manual (jun/2026). **Padrão a reutilizar** em todos os overlays onde fizer sentido (gavetas, pop-ups, modais). Encapsular em `shared/widgets/lcf_glass_sheet.dart`.

Regras inegociáveis do padrão:

- **Superfície externa translúcida** — a "folha de vidro" usa cor de fundo com baixa opacidade (ex. `AppColors.backgroundCard.withOpacity(0.30)`).
- **Frost só na folha de vidro, nunca no fundo** — o `BackdropFilter`/`ImageFilter.blur` aplica-se SOMENTE à superfície da gaveta/barra que sobe, com escopo limitado à região dela via `ClipRRect`. NÃO aplicar blur global ao fundo/scrim — o conteúdo fora da gaveta (o resumo) permanece nítido.
- **Fio dourado de acabamento** — borda escura (token de borda) **com um detalhe dourado** no acabamento (ex. hairline `AppColors.accent.withOpacity(0.6)` na borda superior da gaveta). Assinatura visual padrão.
- **Conteúdo nunca translúcido** — qualquer elemento com texto ou ícone (pills, campos, bubbles) é `Container` de cor **sólida e opaca** por cima do vidro, para legibilidade total. A transparência fica só na folha externa.
- **Cantos bem arredondados** — anti-"quadrado" (ex. 30px nos cantos superiores da gaveta).

Tokens sugeridos a adicionar em `AppColors`/tema (constantes, não hardcoded):
`glassSurfaceOpacity = 0.30`, `glassEdgeAccent = AppColors.accent.withOpacity(0.6)`.

**Padrão obrigatório para TODOS os bottom sheets / barras que sobem.** Implementado em `shared/widgets/lcf_glass_sheet.dart` — ponto único de controle (mudar a opacidade lá propaga para todos). Aplicar em: tutor do Manual (`ManualTutorSheet` ✓), paywall PRO (`ProGateSheet`), sheet de cadastro (`cadastro_screen.dart`), e qualquer novo sheet. Cards estáticos (Dashboard, Simulados, etc.) NÃO usam vidro — só superfícies que deslizam para cima.

**Implementação canônica (2026-06-10):** `shared/widgets/lcf_glass_sheet.dart` encapsula
o padrão completo. Constantes `_kSurfaceOpacity = 0.30`, `_kTopBorderOpacity = 0.60` e
`_kFrostSigma = 18.0` vivem no arquivo do componente. Uso atual: gaveta de vidro do
Tutor IA no Manual (`ManualTutorOrb`).

> ⚠️ Revisão 2026-06-10 (decisão do produto): o vidro passou a usar `BackdropFilter`
> (blur σ18) DENTRO da folha — efeito fosco do conteúdo atrás da gaveta, mantendo a
> opacidade 0.30. O fio dourado é uma hairline separada (1.5 px) no topo, dentro do
> `ClipRRect` — nunca usar `Border` não-uniforme com `borderRadius` (exception de paint).
