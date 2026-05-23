import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class ChipsRow extends StatelessWidget {
  const ChipsRow({super.key, required this.chips, required this.onTap});

  final List<String> chips;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();

    // Left padding aligns chips below the AI bubble text (after avatar + gap)
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg + 32 + AppSpacing.sm,
        right: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips.map((chip) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onTap(chip),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: AppRadius.chip,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(chip, style: AppTextStyles.labelMedium),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
