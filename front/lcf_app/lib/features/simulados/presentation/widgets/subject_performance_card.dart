import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class SubjectPerformanceCard extends StatelessWidget {
  const SubjectPerformanceCard({super.key, required this.bySubject});

  final Map<String, double> bySubject;

  @override
  Widget build(BuildContext context) {
    if (bySubject.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Desempenho por matéria', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.lg),
          ...bySubject.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: AppTextStyles.bodyMedium),
                      Text(
                        '${(e.value * 100).round()}%',
                        style: AppTextStyles.accentMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: AppRadius.chip,
                    child: LinearProgressIndicator(
                      value: e.value.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
