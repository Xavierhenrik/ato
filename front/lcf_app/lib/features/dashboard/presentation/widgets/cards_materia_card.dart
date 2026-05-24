import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_error_state.dart';
import '../../../../shared/widgets/lcf_loading_shimmer.dart';
import '../../data/models/dashboard_models.dart';
import '../../providers/dashboard_provider.dart';

class CardsMateriaCard extends ConsumerWidget {
  const CardsMateriaCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perfAsync = ref.watch(performanceProvider);
    final dashAsync = ref.watch(dashboardDataProvider);

    return perfAsync.when(
      loading: () => const LcfLoadingShimmer(height: 200),
      error: (e, _) => LcfErrorState(
        message: 'Erro ao carregar desempenho.',
        onRetry: () => ref.invalidate(performanceProvider),
      ),
      data: (perf) {
        final streak = dashAsync.valueOrNull?.streak.current ?? 0;
        return _CardsMateriaContent(performance: perf, streak: streak);
      },
    );
  }
}

class _CardsMateriaContent extends StatelessWidget {
  const _CardsMateriaContent({
    required this.performance,
    required this.streak,
  });

  final PerformanceData performance;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final accuracyPct =
        (performance.globalAccuracyRate * 100).toStringAsFixed(0);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cards de matérias', style: AppTextStyles.h3),
              _VerTodasButton(onTap: () => context.push('/manual')),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Prioridades definidas para o seu estudo',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: '${performance.totalAnswered}',
                  label: 'Questões respondidas',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatBox(
                  value: '$accuracyPct%',
                  label: 'Taxa de acerto',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: '${performance.bySubject.length}',
                  label: 'Matérias ativas',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatBox(
                  value: '$streak',
                  label: 'Dias seguidos',
                  icon: Icons.local_fire_department,
                  iconColor: AppColors.streakFire,
                ),
              ),
            ],
          ),
        ],
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

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundSheet,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(value, style: AppTextStyles.accentLarge),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(icon, color: iconColor ?? AppColors.accent, size: 18),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
