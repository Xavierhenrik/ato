import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class QuantityChip extends StatelessWidget {
  const QuantityChip({
    super.key,
    required this.quantity,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  final int quantity;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = isLocked
        ? AppColors.textMuted
        : (isSelected ? AppColors.accent : AppColors.textPrimary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isSelected && !isLocked
            ? AppColors.accent.withValues(alpha: 0.15)
            : AppColors.backgroundCard,
        borderRadius: AppRadius.chip,
        border: Border.all(
          color: isSelected && !isLocked
              ? AppColors.borderAccent
              : AppColors.border,
          width: isSelected && !isLocked ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.chip,
          splashColor: AppColors.accent.withValues(alpha: 0.12),
          highlightColor: AppColors.accent.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLocked) ...[
                  const Icon(Icons.lock, color: AppColors.textMuted, size: 11),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  '$quantity',
                  style: AppTextStyles.labelLarge.copyWith(color: activeColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
