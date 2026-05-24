import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/category_tag.dart';
import '../../data/models/simulado_models.dart';

const Color _kGreen = Color(0xFF4CAF50);
const Color _kGreenBg = Color(0xFF1A3A1A);

class QuestionReviewItem extends StatelessWidget {
  const QuestionReviewItem({
    super.key,
    required this.review,
    required this.index,
    required this.onProGate,
  });

  final QuestionReview review;
  final int index;
  final VoidCallback onProGate;

  @override
  Widget build(BuildContext context) {
    final accent = review.isCorrect ? _kGreen : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: review.isCorrect ? _kGreenBg : const Color(0xFF3A1A1A),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.labelLarge.copyWith(color: accent),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                review.isCorrect ? Icons.check_circle : Icons.cancel,
                color: accent,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              if (review.subject != null) CategoryTag(label: review.subject!),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Enunciado
          Text(
            review.enunciado,
            style: AppTextStyles.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Respostas
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Sua resposta: ',
                      style: AppTextStyles.labelSmall,
                    ),
                    TextSpan(
                      text: review.userAnswer,
                      style: AppTextStyles.labelMedium.copyWith(color: accent),
                    ),
                  ],
                ),
              ),
              if (!review.isCorrect)
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: '  Correta: ',
                        style: AppTextStyles.labelSmall,
                      ),
                      TextSpan(
                        text: review.correctAnswer,
                        style: AppTextStyles.labelMedium
                            .copyWith(color: _kGreen),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Explicação / gate
          if (review.explanation != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.backgroundSheet,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                review.explanation!,
                style: AppTextStyles.bodySmall,
              ),
            )
          else
            GestureDetector(
              onTap: onProGate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSheet,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock,
                        color: AppColors.textMuted, size: 14),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Assine o PRÓ para ver a explicação',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textMuted),
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
