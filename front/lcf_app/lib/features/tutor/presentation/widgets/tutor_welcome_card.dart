import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

class TutorWelcomeCard extends StatelessWidget {
  const TutorWelcomeCard({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.borderAccent,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: AppColors.accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, eu sou o tutor LCF ⚖️',
                      style: AppTextStyles.h3,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Estou aqui para te ajudar a entender o Direito com base legal verificada.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _FeatureBadge(
                icon: Icons.gps_fixed,
                label: 'Respostas com base legal',
              ),
              _FeatureBadge(
                icon: Icons.menu_book_outlined,
                label: 'Explicações claras',
              ),
              _FeatureBadge(
                icon: Icons.verified_outlined,
                label: 'Fontes confiáveis',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSheet,
        borderRadius: AppRadius.chip,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accent, size: 12),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
