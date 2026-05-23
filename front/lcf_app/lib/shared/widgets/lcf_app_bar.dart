import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

// AppBar padrão — título "LCF" centralizado, sem elevação
class LcfAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LcfAppBar({
    super.key,
    this.leading,
    this.actions,
  });

  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: leading,
      actions: actions,
      title: const Text('LCF', style: AppTextStyles.logoTitle),
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
            child: const Text('LCF', style: AppTextStyles.accentMedium),
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
