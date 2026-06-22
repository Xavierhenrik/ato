import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';


enum AnswerState { idle, selected, correct, wrong }

class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  static final TextStyle _letterStyle = AppTextStyles.labelLarge;
  static final TextStyle _textStyle = AppTextStyles.bodyMedium;

  final String letter;
  final String text;
  final AnswerState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: AppRadius.card,
        border: Border.all(color: _border, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.card,
          splashColor: AppColors.accent.withValues(alpha: 0.12),
          highlightColor: AppColors.accent.withValues(alpha: 0.06),
          child: Padding(
            padding: AppSpacing.cardPadding,
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
                  child: Text(letter, style: _letterStyle),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(text, style: _textStyle),
                  ),
                ),
                if (state == AnswerState.correct) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.quizCorrect,
                    size: 20,
                  ),
                ] else if (state == AnswerState.wrong) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.cancel, color: AppColors.error, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _bg => switch (state) {
        AnswerState.idle => AppColors.backgroundCard,
        AnswerState.selected =>
          AppColors.accent.withValues(alpha: 0.1),
        AnswerState.correct => AppColors.quizCorrectBg,
        AnswerState.wrong => AppColors.quizWrongBg,
      };

  Color get _border => switch (state) {
        AnswerState.idle => AppColors.border,
        AnswerState.selected => AppColors.borderAccent,
        AnswerState.correct => AppColors.quizCorrect,
        AnswerState.wrong => AppColors.error,
      };

  Color get _letterBg => switch (state) {
        AnswerState.idle => AppColors.backgroundSheet,
        AnswerState.selected =>
          AppColors.accent.withValues(alpha: 0.2),
        AnswerState.correct => AppColors.quizCorrectLetterBg,
        AnswerState.wrong => AppColors.quizWrongLetterBg,
      };
}
