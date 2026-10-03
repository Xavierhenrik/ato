import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/perfil_models.dart';

class DadosPessoaisCard extends StatelessWidget {
  const DadosPessoaisCard({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.card,
      ),
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Dados pessoais', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _DataRow(label: 'Nome completo', value: profile.name),
          const Divider(color: AppColors.border, height: 1),
          _DataRow(label: 'E-mail', value: profile.email),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
