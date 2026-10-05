import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

/// Renders markdown content with the ATO design system stylesheet.
///
/// Used in both the Tutor IA chat bubbles and the Manual topic detail screen
/// so that all AI-generated content is styled consistently.
class AtoMarkdownBody extends StatelessWidget {
  const AtoMarkdownBody({
    super.key,
    required this.data,
    this.selectable = true,
  });

  final String data;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      shrinkWrap: true,
      selectable: selectable,
      softLineBreak: true,
      styleSheet: _styleSheet,
    );
  }

  static final MarkdownStyleSheet _styleSheet = MarkdownStyleSheet(
    p: AppTextStyles.bodyMedium.copyWith(height: 1.6),
    h1: AppTextStyles.h2,
    h2: AppTextStyles.h3,
    h3: AppTextStyles.h3Gold,
    h4: AppTextStyles.labelLarge,
    h5: AppTextStyles.labelLarge,
    h6: AppTextStyles.labelLarge,
    strong: AppTextStyles.bodyMedium.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.accentLight,
    ),
    em: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic),
    code: AppTextStyles.bodyMedium.copyWith(
      fontFamily: 'monospace',
      color: AppColors.accentLight,
      backgroundColor: AppColors.backgroundCard,
    ),
    codeblockDecoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      border: Border.all(color: AppColors.border),
    ),
    codeblockPadding: const EdgeInsets.all(AppSpacing.md),
    blockquote: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textSecondary,
      fontStyle: FontStyle.italic,
    ),
    blockquoteDecoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      border: const Border(
        left: BorderSide(color: AppColors.accent, width: 3),
      ),
    ),
    blockquotePadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    listBullet: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent),
    listIndent: AppSpacing.lg,
    a: AppTextStyles.link,
    tableHead: AppTextStyles.labelLarge,
    tableBody: AppTextStyles.bodyMedium,
    tableBorder: TableBorder.all(color: AppColors.border),
    tableCellsPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    horizontalRuleDecoration: const BoxDecoration(
      border: Border(
        top: BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    pPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
  );
}
