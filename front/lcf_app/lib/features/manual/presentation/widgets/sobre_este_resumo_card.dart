import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class SobreEsteResumoCard extends StatelessWidget {
  const SobreEsteResumoCard({super.key});

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
              const Icon(
                Icons.auto_awesome,
                color: AppColors.accent,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Sobre este resumo', style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Este resumo foi gerado seguindo a estrutura canônica LCF v1.0, '
            'com referências diretas aos artigos de lei e exemplos práticos '
            'voltados para o Exame da OAB e a graduação em Direito. '
            'Todas as informações são baseadas na legislação vigente e '
            'validadas por um sistema antialucinação com uso de ferramentas.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
