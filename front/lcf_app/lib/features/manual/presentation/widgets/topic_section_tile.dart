import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_markdown_body.dart';
import '../../data/models/manual_models.dart';

class TopicSectionTile extends StatelessWidget {
  const TopicSectionTile({
    super.key,
    required this.section,
    required this.index,
    this.onTutorTap,
  });

  final TopicSection section;
  final int index;
  /// Callback ao tocar no ícone ⚡ — abre o ManualTutorSheet.
  /// Null = botão não é exibido (e.g. seções sem conteúdo útil).
  final VoidCallback? onTutorTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _BulletNumber(number: index + 1),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(section.title, style: AppTextStyles.labelLarge),
            ),
            if (onTutorTap != null)
              GestureDetector(
                onTap: onTutorTap,
                child: const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.xs),
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 20,
                    color: AppColors.accent,
                  ),
                ),
              ),
          ],
        ),
        if (section.content.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          LcfMarkdownBody(data: section.content),
        ],
        const SizedBox(height: AppSpacing.lg),
        const Divider(color: AppColors.border, thickness: 1),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _BulletNumber extends StatelessWidget {
  const _BulletNumber({required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.background,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
