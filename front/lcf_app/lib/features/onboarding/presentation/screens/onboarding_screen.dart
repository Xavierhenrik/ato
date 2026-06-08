import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_app_bar.dart';
import '../../../../shared/widgets/lcf_button.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LcfAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Vamos montar seu plano de estudos',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text('Leva menos de 1 minuto', style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ─── Fase acadêmica ───────────────────────────────────────────
              Text('① Em qual fase você está?', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.md),
              _PhaseGrid(selected: state.selectedPhase),

              const SizedBox(height: AppSpacing.xxl),

              // ─── Tempo diário ─────────────────────────────────────────────
              Text('② Quanto tempo pode estudar por dia?', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.md),
              _MinsRow(selected: state.selectedMins),

              const SizedBox(height: AppSpacing.xxxl),

              // ─── CTA ──────────────────────────────────────────────────────
              LcfButton(
                label: 'Gerar meu plano de estudos',
                onPressed: state.canSubmit
                    ? () => _onSubmit(context, ref)
                    : null,
                isLoading: state.isLoading,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(onboardingNotifierProvider.notifier).complete();
    if (!context.mounted) return;

    if (result == null) {
      final error = ref.read(onboardingNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.toString() ?? 'Erro ao salvar onboarding')),
      );
      return;
    }

    context.go('/dashboard');
  }
}

// ─── Fase acadêmica — grid 2×2 ────────────────────────────────────────────────

class _PhaseGrid extends ConsumerWidget {
  const _PhaseGrid({required this.selected});
  final AcademicPhase? selected;

  static const _phases = [
    (phase: AcademicPhase.graduationStart, icon: '🎓'),
    (phase: AcademicPhase.graduationMid,   icon: '📖'),
    (phase: AcademicPhase.graduationEnd,   icon: '⚖️'),
    (phase: AcademicPhase.oabPrep,         icon: '🎒'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.6,
      children: _phases.map((item) {
        final isSelected = selected == item.phase;
        return _PhaseCard(
          phase: item.phase,
          emoji: item.icon,
          isSelected: isSelected,
          onTap: () => ref.read(onboardingNotifierProvider.notifier).selectPhase(item.phase),
        );
      }).toList(),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.phase,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  final AcademicPhase phase;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.backgroundCard,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isSelected ? AppColors.borderAccent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              phase.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tempo diário — chips row ─────────────────────────────────────────────────

class _MinsRow extends ConsumerWidget {
  const _MinsRow({required this.selected});
  final DailyStudyMins? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: DailyStudyMins.values.map((mins) {
        final isSelected = selected == mins;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => ref
                  .read(onboardingNotifierProvider.notifier)
                  .selectMins(mins),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : AppColors.backgroundCard,
                  borderRadius: AppRadius.chip,
                  border: Border.all(
                    color: isSelected ? AppColors.borderAccent : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  mins.label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
