import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/simulado_models.dart';

const Color _kGreen = Color(0xFF4CAF50);
const Color _kGreenBg = Color(0xFF1A3A1A);

class ScoreHeaderCard extends StatelessWidget {
  const ScoreHeaderCard({super.key, required this.result});

  static final TextStyle _scoreBase = AppTextStyles.displayLarge.copyWith(
    fontSize: 52,
    fontWeight: FontWeight.w700,
  );

  final SimuladoResult result;

  @override
  Widget build(BuildContext context) {
    final pct = (result.score * 100).round();
    final passed = result.score >= 0.6;
    final accent = passed ? _kGreen : AppColors.error;
    final bg = passed ? _kGreenBg : AppColors.errorBg;

    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: accent),
      ),
      child: Column(
        children: [
          Text(
            '$pct%',
            style: _scoreBase.copyWith(color: accent),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(color: bg, borderRadius: AppRadius.chip),
            child: Text(
              passed ? 'Aprovado' : 'Reprovado',
              style: AppTextStyles.labelLarge.copyWith(color: accent),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(label: 'Total', value: '${result.total}'),
              _Stat(
                label: 'Corretas',
                value: '${result.correct}',
                valueColor: _kGreen,
              ),
              _Stat(
                label: 'Erradas',
                value: '${result.wrong}',
                valueColor: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.valueColor});

  static final TextStyle _valuePrimary = AppTextStyles.h2;

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = valueColor == null
        ? _valuePrimary
        : _valuePrimary.copyWith(color: valueColor);
    return Column(
      children: [
        Text(value, style: style),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
