import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/category_tag.dart';
import '../../../../shared/widgets/lcf_error_state.dart';
import '../../../../shared/widgets/lcf_loading_shimmer.dart';
import '../../data/models/dashboard_models.dart';
import '../../providers/dashboard_provider.dart';

class RevisaoInteligenteCard extends ConsumerWidget {
  const RevisaoInteligenteCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(revisionCardsProvider);
    return async.when(
      loading: () => const LcfLoadingShimmer(height: 200),
      error: (e, _) => LcfErrorState(
        message: 'Erro ao carregar revisões.',
        onRetry: () => ref.invalidate(revisionCardsProvider),
      ),
      data: (cards) => _RevisaoContent(cards: cards),
    );
  }
}

class _RevisaoContent extends StatelessWidget {
  const _RevisaoContent({required this.cards});
  final List<RevisionCard> cards;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.lg,
        left: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Revisão inteligente', style: AppTextStyles.h3),
                Text('Ver todas >', style: AppTextStyles.accentMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Padding(
            padding: EdgeInsets.only(right: AppSpacing.lg),
            child: Text(
              'Com base no algoritmo de repetição espaçada',
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (cards.isEmpty)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.lg),
              child: Center(
                child: Text(
                  'Nenhuma revisão pendente',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            )
          else
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                itemCount: cards.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, i) =>
                    _RevisionTile(card: cards[i], isFirst: i == 0),
              ),
            ),
        ],
      ),
    );
  }
}

class _RevisionTile extends StatelessWidget {
  const _RevisionTile({required this.card, required this.isFirst});
  final RevisionCard card;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Navega para o manual filtrado por lawCode — F4 implementará o filtro.
      onTap: () => context.push('/manual'),
      child: Container(
        width: 160,
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: isFirst
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.backgroundSheet,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isFirst ? AppColors.borderAccent : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryTag(label: card.subject),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Text(
                card.subject,
                style: AppTextStyles.labelLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${card.totalAnswered} questões',
                  style: AppTextStyles.labelSmall,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    'Revisar',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
