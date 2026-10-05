import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/category_tag.dart';
import '../../../../shared/widgets/ato_error_state.dart';
import '../../../../shared/widgets/ato_loading_shimmer.dart';
import '../../data/models/dashboard_models.dart';
import '../../providers/dashboard_provider.dart';
import 'revisar_sheet.dart';

class RevisaoInteligenteCard extends ConsumerWidget {
  const RevisaoInteligenteCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(revisionCardsProvider);
    return async.when(
      loading: () => const AtoLoadingShimmer(height: 200),
      error: (e, _) => AtoErrorState(
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
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Revisão inteligente', style: AppTextStyles.h3),
                _VerTodasButton(
                  onTap: () => context.push('/simulados'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Text(
              'Suas matérias com mais erros recentes',
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (cards.isEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
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
                    _RevisionTile(card: cards[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _RevisionTile extends StatefulWidget {
  const _RevisionTile({required this.card});

  final RevisionCard card;

  @override
  State<_RevisionTile> createState() => _RevisionTileState();
}

class _RevisionTileState extends State<_RevisionTile> {
  bool _pressed = false;

  static final TextStyle _revisarLabel = AppTextStyles.labelSmall.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 160,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _pressed
            ? AppColors.accent.withValues(alpha: 0.12)
            : AppColors.backgroundSheet,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: _pressed ? AppColors.borderAccent : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => RevisarSheet.show(context, card: card),
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: AppRadius.card,
          splashColor: AppColors.accent.withValues(alpha: 0.12),
          highlightColor: AppColors.accent.withValues(alpha: 0.06),
          child: Padding(
            padding: AppSpacing.cardPadding,
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
                      '${card.totalAnswered} respondidas',
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
                      child: Text('Revisar', style: _revisarLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerTodasButton extends StatelessWidget {
  const _VerTodasButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        splashColor: AppColors.accent.withValues(alpha: 0.12),
        highlightColor: AppColors.accent.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text('Ver todas >', style: AppTextStyles.accentMedium),
        ),
      ),
    );
  }
}
