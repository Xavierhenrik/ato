# LCF — Design Tokens

> Extraído das telas enviadas em 2026-05-21.
> Implementar em `lib/core/theme/app_colors.dart` e `app_text_styles.dart`.
> Esta é a fonte de verdade de design. Nunca usar valores hardcoded no código.

---

## Cores

### Paleta base

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // Backgrounds
  static const Color background     = Color(0xFF1A0800); // tela principal
  static const Color backgroundCard = Color(0xFF2D1200); // cards e containers
  static const Color backgroundSheet= Color(0xFF3D1200); // bottom sheets, modais
  static const Color backgroundNav  = Color(0xFF140600); // bottom navigation bar

  // Gold / Accent
  static const Color accent         = Color(0xFFC9922A); // gold primário
  static const Color accentDark     = Color(0xFF9A6B1A); // gold hover/pressed
  static const Color accentLight    = Color(0xFFE8B84B); // gold highlight

  // Bordas
  static const Color border         = Color(0xFF3D2010); // border padrão
  static const Color borderAccent   = Color(0xFFC9922A); // border selecionado/gold
  static const Color borderMuted    = Color(0xFF2A1508); // border sutil

  // Textos
  static const Color textPrimary    = Color(0xFFFFFFFF); // texto principal
  static const Color textSecondary  = Color(0xFF9E8472); // labels, subtítulos
  static const Color textMuted      = Color(0xFF6B5240); // placeholders, disabled
  static const Color textAccent     = Color(0xFFC9922A); // links, destaque gold

  // Semânticas
  static const Color tagBackground  = Color(0xFF5A1A1A); // tag de categoria (vermelho escuro)
  static const Color success        = Color(0xFFC9922A); // checkmarks (usa gold)
  static const Color info           = Color(0xFF2A4A7A); // banner informativo (azul escuro)
  static const Color error          = Color(0xFF8B2020); // erros

  // Streak / Progresso
  static const Color streakFire     = Color(0xFFFF6B00); // ícone de streak (laranja)
  static const Color progressRing   = Color(0xFFC9922A); // anel de progresso (gold)
  static const Color progressBg     = Color(0xFF3D2010); // fundo do anel

  // Avatares / Status
  static const Color onlineDot      = Color(0xFF4CAF50); // ponto verde no avatar
}
```

### Gradientes

```dart
// Gradiente do anel de progresso (DonutChart)
static const LinearGradient progressGradient = LinearGradient(
  colors: [Color(0xFFC9922A), Color(0xFFE8B84B)],
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
  static const TextStyle h3Gold = TextStyle(
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

  // Accent / Gold
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
    color: AppColors.accent, letterSpacing: 2,
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
- Background: backgroundCard (#2D1200)
- Border: 1px solid border (#3D2010)
- Border focused: 1px solid accent (#C9922A)
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
| `primary` | `accent` (#C9922A) | branco, bold | nenhum |
| `secondary` | `backgroundCard` | branco | 1px border |
| `outline` | transparente | textMuted | 1px borderMuted |
| `social` | `backgroundCard` | branco | 1px border |
| `destructive` | transparente | error | 1px error |

Todos: `borderRadius: 12`, `height: 52px`, `width: double.infinity` por padrão.

### Card padrão

```
- Background: backgroundCard (#2D1200)
- Border: 1px solid border (#3D2010)
- Border radius: 16px
- Padding: 16px
- Shadow: nenhuma (flat design)
```

### Card destacado (selecionado / PRÓ)

```
- Border: 1.5px solid accent (#C9922A)
- Background: pode ter leve tint gold (C9922A com 10% opacidade)
```

### CategoryTag (pill)

```
- Background: tagBackground (#5A1A1A)
- Texto: textPrimary, 12px, weight 500
- Padding: 4px vertical, 10px horizontal
- Border radius: full (100px)
```

### Badge "Membro Pró"

```
- Background: backgroundSheet (#3D1200) ou backgroundCard
- Borda: 1px solid accentDark
- Texto: accent, 12px, weight 600
- Padding: 4px 10px
- Border radius: full
```

### Streak Badge

```
- Background: backgroundCard
- Borda: 1px solid accent
- Ícone: 🔥 laranja (#FF6B00)
- Número: accent (gold), bold
- Label: "Dias seguido", textSecondary, 10px
- Padding: 6px 10px
- Border radius: 20px
```

### BottomNav

```
- Background: backgroundNav (#140600)
- Altura: 60px + padding SafeArea
- Ícone ativo: accent (#C9922A)
- Label ativo: accent, 10px
- Ícone inativo: textMuted (#6B5240)
- Label inativo: textMuted, 10px
- Sem indicador/blob — apenas mudança de cor
```

### AppBar padrão (telas internas)

```
- Background: background (#1A0800) — sem elevação
- Título: "LCF" centralizado, logoTitle style
- Leading: ← ícone, textPrimary
- Actions: ícones textPrimary ou accent
```

### AppBar do Tutor IA

```
- Diferente do padrão:
- Leading: box com borda gold contendo "LCF" (logo box)
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
