import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/category_tag.dart';
import '../../data/models/tutor_history_models.dart';

/// Card de histórico de conversa.
///
/// Exibe título (1 linha, ellipsis), data relativa, contagem de mensagens.
/// Sessões do modo 'reading' mostram um [CategoryTag] com o topicTitle.
/// Long-press aciona [onLongPress] para exclusão.
class HistorySessionCard extends StatelessWidget {
  const HistorySessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onLongPress,
  });

  final HistorySession session;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: AppRadius.card,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              session.title.isNotEmpty ? session.title : 'Conversa sem título',
              style: AppTextStyles.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            // Metadados: data + contador de mensagens
            Row(
              children: [
                Text(
                  _relativeDate(session.createdAt),
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: AppSpacing.sm),
                const _Dot(),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${session.msgCount} mensagens',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            // Badge do tópico (somente modo 'reading')
            if (session.mode == 'reading' &&
                session.topicTitle != null &&
                session.topicTitle!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              CategoryTag(label: session.topicTitle!),
            ],
          ],
        ),
      ),
    );
  }

  String _relativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return 'há ${diff.inDays} dias';
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return 'há $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return 'há $months ${months == 1 ? 'mês' : 'meses'}';
    }
    final years = (diff.inDays / 365).floor();
    return 'há $years ${years == 1 ? 'ano' : 'anos'}';
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textMuted,
      ),
    );
  }
}
