import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/lex_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/anotacao_models.dart';

class AnotacaoCard extends StatelessWidget {
  const AnotacaoCard({
    super.key,
    required this.anotacao,
    required this.onTap,
  });

  final Anotacao anotacao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    anotacao.title.isNotEmpty ? anotacao.title : 'Sem título',
                    style: AppTextStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (anotacao.autoSaved) ...[
                      SvgPicture.asset(
                        LexIcons.lexiaBadge,
                        width: 14, height: 14,
                        colorFilter: const ColorFilter.mode(AppColors.accent, BlendMode.srcIn),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      _formatDate(anotacao.updatedAt),
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
            if (anotacao.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children:
                    anotacao.tags.map((tag) => _TagPill(label: tag)).toList(),
              ),
            ],
            if (anotacao.content.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                anotacao.content,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (anotacao.subject != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _SubjectPill(label: anotacao.subject!),
            ],
          ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'hoje';
    if (diff.inDays == 1) return 'ontem';
    if (diff.inDays < 7) return '${diff.inDays}d atrás';
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  static final TextStyle _style = AppTextStyles.labelSmall.copyWith(
    color: AppColors.accent,
  );

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.chip,
        border: Border.all(color: AppColors.borderAccent),
        color: AppColors.accent.withValues(alpha: 0.1),
      ),
      child: Text(label, style: _style),
    );
  }
}

class _SubjectPill extends StatelessWidget {
  const _SubjectPill({required this.label});

  static final TextStyle _style = AppTextStyles.labelSmall.copyWith(
    color: AppColors.textPrimary,
  );

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.chip,
        color: AppColors.tagBackground,
      ),
      child: Text(label, style: _style),
    );
  }
}
