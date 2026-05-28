import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import 'lcf_button.dart';

class ProGateSheet extends StatelessWidget {
  const ProGateSheet({super.key, required this.feature});

  final String feature;

  static Future<void> show(BuildContext context, {required String feature}) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ProGateSheet(feature: feature),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSheet,
        borderRadius: AppRadius.sheet,
        border: Border.all(color: AppColors.borderAccent, width: 1.5),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Crown icon
          const Icon(
            Icons.workspace_premium,
            color: AppColors.accent,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text('Recurso PRÓ', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Assine o LCF PRÓ para acessar $feature e muitos outros recursos exclusivos.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Features
          ..._features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.accent, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(f, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // CTA
          LcfButton(
            label: 'Assinar PRÓ — R\$29,90/mês',
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/subscription');
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          LcfButton(
            label: 'Agora não',
            variant: LcfButtonVariant.outline,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  static const _features = [
    'Simulados ilimitados com explicações',
    'Tutor IA sem limite diário (200 msgs)',
    'Auto-save de anotações pelo Tutor',
    'Análise de desempenho avançada',
  ];
}
