import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/category_tag.dart';
import '../../../../shared/widgets/ato_button.dart';
import '../../providers/onboarding_provider.dart';
import '../../../simulados/presentation/widgets/answer_option.dart';

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
            DiagnosticoStep.intro    => const _IntroState(),
            DiagnosticoStep.answering => const _AnsweringState(),
            DiagnosticoStep.done     => const _DoneState(),
          },
        ),
      ),
    );
  }
}

// ─── Intro ────────────────────────────────────────────────────────────────────

class _IntroState extends ConsumerWidget {
  const _IntroState();

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
          Text(
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(icon: Icons.timer_outlined, label: '5 minutos'),
              SizedBox(width: AppSpacing.md),
              _InfoChip(icon: Icons.quiz_outlined, label: '15 questões'),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),

          AtoButton(
            label: 'Começar diagnóstico',
            onPressed: () =>
                ref.read(diagnosticoNotifierProvider.notifier).startAnswering(),
          ),
          const SizedBox(height: AppSpacing.md),
          AtoButton(
            label: 'Fazer depois',
            variant: AtoButtonVariant.outline,
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
    } catch (e) { debugPrint('[Diagnóstico] Erro: $e'); }
    if (context.mounted) context.go('/dashboard');
  }
}

// ─── Answering ─────────────────────────────────────────────────────────────────

class _AnsweringState extends ConsumerStatefulWidget {
  const _AnsweringState();

  @override
  ConsumerState<_AnsweringState> createState() => _AnsweringStateState();
}

class _AnsweringStateState extends ConsumerState<_AnsweringState> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(diagnosticoQuizNotifierProvider.notifier).loadQuestions();
      }
    });
  }

  Future<void> _skip(BuildContext context) async {
    try {
      await ref.read(diagnosticoNotifierProvider.notifier).dismiss();
    } catch (e) { debugPrint('[Diagnóstico] Erro: $e'); }
    if (context.mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(diagnosticoQuizNotifierProvider);

    if (quiz.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
      );
    }

    if (quiz.error != null || quiz.questions.isEmpty) {
      return Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Não foi possível carregar as questões.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AtoButton(
              label: 'Tentar novamente',
              onPressed: () => ref
                  .read(diagnosticoQuizNotifierProvider.notifier)
                  .loadQuestions(),
            ),
            const SizedBox(height: AppSpacing.md),
            AtoButton(
              label: 'Pular por agora',
              variant: AtoButtonVariant.outline,
              onPressed: () => _skip(context),
            ),
          ],
        ),
      );
    }

    final question = quiz.currentQuestion!;
    final total = quiz.questions.length;
    final progress = (quiz.currentIndex + 1) / total;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Text(
                'Questão ${quiz.currentIndex + 1} de $total',
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.border,
          color: AppColors.accent,
          minHeight: 3,
        ),
        Expanded(
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              const SizedBox(height: AppSpacing.md),
              _QuestionCard(
                enunciado: question.enunciado,
                subject: question.subject,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...question.opcoes.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AnswerOption(
                    letter: e.key,
                    text: e.value,
                    state: quiz.selectedAnswer == e.key
                        ? AnswerState.selected
                        : AnswerState.idle,
                    onTap: () => ref
                        .read(diagnosticoQuizNotifierProvider.notifier)
                        .selectAnswer(e.key),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: AtoButton(
            label: quiz.isLastQuestion
                ? 'Concluir diagnóstico'
                : 'Próxima questão',
            onPressed: quiz.canAdvance
                ? () =>
                    ref.read(diagnosticoQuizNotifierProvider.notifier).advance()
                : null,
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.enunciado, this.subject});

  final String enunciado;
  final String? subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subject != null) ...[
            CategoryTag(label: subject!),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(enunciado, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}

// ─── Done ─────────────────────────────────────────────────────────────────────

class _DoneState extends StatelessWidget {
  const _DoneState();

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
          Text(
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
          AtoButton(
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
