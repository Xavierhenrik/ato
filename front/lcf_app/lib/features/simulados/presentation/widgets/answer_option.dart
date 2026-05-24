import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

// Semantic colors for correct/wrong states — not in AppColors since they are
// standard green/red feedback, distinct from the brand palette.
const Color _kCorrectGreen = Color(0xFF4CAF50);
const Color _kCorrectBg = Color(0xFF1A3A1A);
const Color _kCorrectLetterBg = Color(0xFF2A5A2A);
const Color _kWrongBg = Color(0xFF3A1A1A);
const Color _kWrongLetterBg = Color(0xFF5A2A2A);

enum AnswerState { idle, selected, correct, wrong }

class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final AnswerState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: AppRadius.card,
          border: Border.all(color: _border, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _letterBg,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: AppTextStyles.labelLarge.copyWith(color: _textColor),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  text,
                  style: AppTextStyles.bodyMedium.copyWith(color: _textColor),
                ),
              ),
            ),
            if (state == AnswerState.correct) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.check_circle, color: _kCorrectGreen, size: 20),
            ] else if (state == AnswerState.wrong) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.cancel, color: AppColors.error, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Color get _bg => switch (state) {
        AnswerState.idle => AppColors.backgroundCard,
        AnswerState.selected =>
          AppColors.accent.withValues(alpha: 0.1),
        AnswerState.correct => _kCorrectBg,
        AnswerState.wrong => _kWrongBg,
      };

  Color get _border => switch (state) {
        AnswerState.idle => AppColors.border,
        AnswerState.selected => AppColors.borderAccent,
        AnswerState.correct => _kCorrectGreen,
        AnswerState.wrong => AppColors.error,
      };

  Color get _textColor => switch (state) {
        AnswerState.idle => AppColors.textPrimary,
        AnswerState.selected => AppColors.textPrimary,
        AnswerState.correct => AppColors.textPrimary,
        AnswerState.wrong => AppColors.textPrimary,
      };

  Color get _letterBg => switch (state) {
        AnswerState.idle => AppColors.backgroundSheet,
        AnswerState.selected =>
          AppColors.accent.withValues(alpha: 0.2),
        AnswerState.correct => _kCorrectLetterBg,
        AnswerState.wrong => _kWrongLetterBg,
      };
}
