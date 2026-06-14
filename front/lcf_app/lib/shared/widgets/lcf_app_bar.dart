import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/glass_tokens.dart';

// AppBar padrão — título "LCF" centralizado, sem elevação
//
// Back button behavior:
// - If `leading` is provided, it overrides everything.
// - If `showBack: true`, always renders a back button:
//   - Uses context.pop() when Navigator has a previous route
//   - Falls back to context.go(fallbackRoute) when stack is empty (refresh / deep link)
// - If `showBack: false` (default), behaves like the previous version (no leading).
class LcfAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LcfAppBar({
    super.key,
    this.leading,
    this.actions,
    this.showBack = false,
    this.fallbackRoute = '/dashboard',
  });

  final Widget? leading;
  final List<Widget>? actions;
  final bool showBack;
  final String fallbackRoute;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget? _resolveLeading(BuildContext context) {
    if (leading != null) return leading;
    if (!showBack) return null;
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      tooltip: 'Voltar',
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(fallbackRoute);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: _resolveLeading(context),
      actions: actions,
      title: Text('Lex', style: AppTextStyles.logoTitle),
      flexibleSpace: const _GlassTopBar(),
    );
  }
}

// AppBar variante Tutor IA — LCF box à esquerda, título alinhado à esquerda
class LcfTutorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LcfTutorAppBar({
    super.key,
    this.actions,
    this.showBack = false,
    this.fallbackRoute = '/dashboard',
  });

  final List<Widget>? actions;
  final bool showBack;
  final String fallbackRoute;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Modo contexto (veio do Manual): header minimalista — seta + "Resumo"
    if (showBack) {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.textSecondary,
          ),
          onPressed: () => _goBack(context),
        ),
        titleSpacing: 0,
        title: Text(
          'Resumo',
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.accent),
        ),
        actions: actions,
        flexibleSpace: const _GlassTopBar(),
      );
    }

    // Modo padrão: header minimalista — sem título de identidade
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: actions,
      flexibleSpace: const _GlassTopBar(),
    );
  }
}

// Gradiente vidro-fosco para os AppBars do LCF.
// Fundo sólido escuro → sem BackdropFilter (blur em sólido não tem efeito visível).
class _GlassTopBar extends StatelessWidget {
  const _GlassTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundCard,
            AppColors.background,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.accent.withValues(alpha: kGlassTrimOpacity),
            width: kGlassTrimStroke,
          ),
        ),
      ),
    );
  }
}
