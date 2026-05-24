import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

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
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      // Disable Flutter's implicit back button — we control it explicitly.
      automaticallyImplyLeading: false,
      leading: _resolveLeading(context),
      actions: actions,
      title: Text('LCF', style: AppTextStyles.logoTitle),
    );
  }
}

// AppBar variante Tutor IA — LCF box à esquerda, título alinhado à esquerda
class LcfTutorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LcfTutorAppBar({super.key, this.actions});

  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.lg,
      title: Row(
        children: [
          // LCF logo box com borda gold
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderAccent, width: 1.5),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            alignment: Alignment.center,
            child: Text('LCF', style: AppTextStyles.accentMedium),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tutor IA', style: AppTextStyles.h3),
              Text(
                'Direito inteligente para sua aprovação',
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ],
      ),
      actions: actions,
    );
  }
}
