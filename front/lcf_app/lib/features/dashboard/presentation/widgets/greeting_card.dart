import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_error_state.dart';
import '../../../../shared/widgets/lcf_loading_shimmer.dart';
import '../../data/models/dashboard_models.dart';
import '../../providers/dashboard_provider.dart';

class GreetingCard extends ConsumerWidget {
  const GreetingCard({super.key});

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  static const _phrases = [
    'Disciplina hoje, aprovação amanhã.',
    'Cada artigo lido é um passo mais perto.',
    'Seu esforço está construindo seu futuro.',
    'Continue firme — você está progredindo.',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardDataProvider);
    return async.when(
      loading: () => const LcfLoadingShimmer(height: 120),
      error: (e, _) => LcfErrorState(
        message: 'Erro ao carregar dados.',
        onRetry: () => ref.invalidate(dashboardDataProvider),
      ),
      data: (data) => _GreetingContent(
        data: data,
        greeting: _greeting(),
        phrase: _phrases[DateTime.now().day % _phrases.length],
      ),
    );
  }
}

class _GreetingContent extends StatelessWidget {
  const _GreetingContent({
    required this.data,
    required this.greeting,
    required this.phrase,
  });

  final DashboardData data;
  final String greeting;
  final String phrase;

  @override
  Widget build(BuildContext context) {
    final isGoldStreak = data.streak.current >= 7;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppColors.streakFire,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isGoldStreak
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : AppColors.backgroundSheet,
                  borderRadius: AppRadius.chip,
                  border: Border.all(
                    color: isGoldStreak
                        ? AppColors.borderAccent
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  '${data.streak.current} dias seguidos',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isGoldStreak
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isGoldStreak) ...[
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.accent,
                  size: 16,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$greeting, ${data.name}!',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(phrase, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
