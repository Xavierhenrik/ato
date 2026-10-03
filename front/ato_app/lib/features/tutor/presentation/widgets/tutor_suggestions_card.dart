import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class TutorSuggestionsCard extends StatelessWidget {
  const TutorSuggestionsCard({super.key, required this.onChipTap});

  final ValueChanged<String> onChipTap;

  static const _suggestions = [
    'O que é habeas corpus?',
    'Diferença entre dolo e culpa',
    'Como funciona o júri popular?',
    'O que é prescrição penal?',
    'Direitos do consumidor no CDC',
    'Princípio da legalidade',
  ];

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text('Sugestões para começar', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Clique em um tema abaixo ou digite sua pergunta',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _suggestions
                .map(
                  (s) => _SuggestionChip(
                    label: s,
                    onTap: () => onChipTap(s),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundSheet,
          borderRadius: AppRadius.chip,
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium,
        ),
      ),
    );
  }
}
