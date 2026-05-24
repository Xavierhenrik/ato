import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/category_tag.dart';
import '../../data/models/manual_models.dart';

class TopicCard extends StatelessWidget {
  const TopicCard({
    super.key,
    required this.topic,
    required this.onTap,
  });

  final Topic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: topic.isRead ? AppColors.borderAccent : AppColors.border,
          width: topic.isRead ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: AppRadius.card,
          splashColor: AppColors.accent.withValues(alpha: 0.12),
          highlightColor: AppColors.accent.withValues(alpha: 0.06),
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CategoryTag(label: topic.lawLabel),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        topic.title,
                        style: AppTextStyles.bodyLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _MetaRow(topic: topic),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _ReadIndicator(isRead: topic.isRead),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.topic});
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    final updatedLabel = _formatDate(topic.updatedAt);
    return Row(
      children: [
        const Icon(
          Icons.timer_outlined,
          size: 12,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '${topic.readTimeMinutes} min',
          style: AppTextStyles.labelSmall,
        ),
        if (updatedLabel != null) ...[
          const SizedBox(width: AppSpacing.md),
          const Icon(
            Icons.calendar_today_outlined,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Atualizado $updatedLabel',
            style: AppTextStyles.labelSmall,
          ),
        ],
      ],
    );
  }

  String? _formatDate(DateTime? dt) {
    if (dt == null) return null;
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${months[dt.month - 1]}/${dt.year}';
  }
}

class _ReadIndicator extends StatelessWidget {
  const _ReadIndicator({required this.isRead});
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    if (isRead) {
      return const Icon(
        Icons.check_circle,
        color: AppColors.success,
        size: 22,
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
    );
  }
}
