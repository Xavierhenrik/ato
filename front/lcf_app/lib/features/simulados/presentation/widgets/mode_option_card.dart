import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/simulado_models.dart';

class ModeOptionCard extends StatelessWidget {
  const ModeOptionCard({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  final SimuladoMode mode;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor =
        isLocked ? AppColors.textMuted : (isSelected ? AppColors.accent : AppColors.textSecondary);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected && !isLocked
              ? AppColors.accent.withValues(alpha: 0.1)
              : AppColors.backgroundCard,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isSelected && !isLocked
                ? AppColors.borderAccent
                : AppColors.border,
            width: isSelected && !isLocked ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(_modeIcon, color: activeColor, size: 28),
                if (isLocked)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundSheet,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock,
                          color: AppColors.textMuted, size: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              mode.label,
              style: AppTextStyles.labelMedium.copyWith(color: activeColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData get _modeIcon => switch (mode) {
        SimuladoMode.oabPhase1 => Icons.school_outlined,
        SimuladoMode.oabPhase2 => Icons.balance_outlined,
        SimuladoMode.custom => Icons.menu_book_outlined,
        SimuladoMode.weakAreas => Icons.gps_fixed_outlined,
      };
}
