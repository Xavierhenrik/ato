import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_button.dart';
import '../../providers/onboarding_provider.dart';

class DiagnosticoScreen extends ConsumerWidget {
  const DiagnosticoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(diagnosticoNotifierProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: switch (step) {
            DiagnosticoStep.intro    => _IntroState(),
            DiagnosticoStep.answering => _AnsweringState(),
            DiagnosticoStep.done     => _DoneState(),
          },
        ),
      ),
    );
  }
}

// ─── Intro ────────────────────────────────────────────────────────────────────

class _IntroState extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderAccent, width: 1.5),
                color: AppColors.backgroundCard,
              ),
              child: const Icon(Icons.balance, color: AppColors.accent, size: 36),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Vamos personalizar seu aprendizado',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Responda algumas questões para calibrar seu plano de estudos',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Info chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(icon: Icons.timer_outlined, label: '5 minutos'),
              const SizedBox(width: AppSpacing.md),
              _InfoChip(icon: Icons.quiz_outlined, label: '15 questões'),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),

          LcfButton(
            label: 'Começar diagnóstico',
            onPressed: () =>
                ref.read(diagnosticoNotifierProvider.notifier).startAnswering(),
          ),
          const SizedBox(height: AppSpacing.md),
          LcfButton(
            label: 'Fazer depois',
            variant: LcfButtonVariant.outline,
            onPressed: () => _onDismiss(context, ref),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _onDismiss(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(diagnosticoNotifierProvider.notifier).dismiss();
    } catch (_) {}
    if (context.mounted) context.go('/dashboard');
  }
}

// ─── Answering (placeholder — questões via Sprint F5) ────────────────────────

class _AnsweringState extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text('Diagnóstico', style: AppTextStyles.h3),
              const Spacer(),
              Text('Questão 1 de 15', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Progress bar
          ClipRRect(
            borderRadius: AppRadius.chip,
            child: LinearProgressIndicator(
              value: 1 / 15,
              backgroundColor: AppColors.backgroundCard,
              color: AppColors.accent,
              minHeight: 6,
            ),
          ),
          const Spacer(),
          Text(
            'As questões do diagnóstico serão exibidas aqui (Sprint F5 — Simulados).',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          LcfButton(
            label: 'Concluir diagnóstico (simulado)',
            onPressed: () =>
                ref.read(diagnosticoNotifierProvider.notifier).complete(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─── Done ─────────────────────────────────────────────────────────────────────

class _DoneState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderAccent, width: 1.5),
                color: AppColors.backgroundCard,
              ),
              child: const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 36),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Diagnóstico concluído!',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Seu plano de estudos foi personalizado',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          LcfButton(
            label: 'Ir para o Dashboard',
            onPressed: () => context.go('/dashboard'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.chip,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 14),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
