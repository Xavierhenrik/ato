import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/category_tag.dart';
import '../../data/models/simulado_models.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.subject != null || question.year != null) ...[
            Row(
              children: [
                if (question.subject != null)
                  CategoryTag(label: question.subject!),
                if (question.subject != null && question.year != null)
                  const SizedBox(width: AppSpacing.sm),
                if (question.year != null)
                  Text('${question.year}', style: AppTextStyles.labelSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(question.enunciado, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}
