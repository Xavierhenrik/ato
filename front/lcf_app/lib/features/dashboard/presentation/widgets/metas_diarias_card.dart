import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_error_state.dart';
import '../../../../shared/widgets/lcf_loading_shimmer.dart';
import '../../providers/dashboard_provider.dart';

class MetasDiariasCard extends ConsumerWidget {
  const MetasDiariasCard({super.key});

  // Converte minutos de estudo em meta de questões.
  static int _dailyGoal(int dailyGoalMins) =>
      (dailyGoalMins / 3).ceil().clamp(10, 90);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardDataProvider);
    return async.when(
      loading: () => const LcfLoadingShimmer(height: 148),
      error: (e, _) => LcfErrorState(
        message: 'Erro ao carregar metas.',
        onRetry: () => ref.invalidate(dashboardDataProvider),
      ),
      data: (data) {
        final p = data.dailyProgress;
        final goal = _dailyGoal(p.dailyGoalMins);
        final percent = (p.questionsAnsweredToday / goal).clamp(0.0, 1.0);
        return _MetasDiariasContent(
          questionsToday: p.questionsAnsweredToday,
          dailyGoal: goal,
          percent: percent,
          topicsReadToday: p.topicsReadToday,
        );
      },
    );
  }
}

class _MetasDiariasContent extends StatelessWidget {
  const _MetasDiariasContent({
    required this.questionsToday,
    required this.dailyGoal,
    required this.percent,
    required this.topicsReadToday,
  });

  final int questionsToday;
  final int dailyGoal;
  final double percent;
  final int topicsReadToday;

  @override
  Widget build(BuildContext context) {
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
          const Text('Metas diárias', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: CustomPaint(
                      painter: _DonutPainter(percent: percent),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$questionsToday/$dailyGoal',
                              style: AppTextStyles.accentMedium,
                            ),
                            const Text(
                              'questões',
                              style: AppTextStyles.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TaskItem(
                      done: topicsReadToday >= 1,
                      label: 'Ler 1 resumo',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _TaskItem(
                      done: questionsToday >= 10,
                      label: 'Resolver 10 questões',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _TaskItem(
                      done: questionsToday >= dailyGoal,
                      label: 'Concluir meta diária',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  const _TaskItem({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? AppColors.success : AppColors.textMuted,
          size: 18,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: done ? AppColors.textPrimary : AppColors.textSecondary,
              decoration: done ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.percent});
  final double percent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = AppColors.progressBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (percent > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, -pi / 2, 2 * pi * percent, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.percent != percent;
}
