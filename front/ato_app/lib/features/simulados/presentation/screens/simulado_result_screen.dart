import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/ato_app_bar.dart';
import '../../../../shared/widgets/ato_button.dart';
import '../../../../shared/widgets/ato_error_state.dart';
import '../../../../shared/widgets/ato_loading_shimmer.dart';
import '../../../../shared/widgets/pro_gate_sheet.dart';
import '../../providers/simulado_provider.dart';
import '../widgets/question_review_item.dart';
import '../widgets/score_header_card.dart';
import '../widgets/subject_performance_card.dart';

class SimuladoResultScreen extends ConsumerWidget {
  const SimuladoResultScreen({super.key, required this.simuladoId});

  final String simuladoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(simuladoResultProvider(simuladoId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AtoAppBar(showBack: true, fallbackRoute: '/simulados'),
      body: resultAsync.when(
        loading: () => const AtoLoadingShimmer(),
        error: (e, _) => AtoErrorState(
          message: 'Erro ao carregar resultado.',
          onRetry: () =>
              ref.invalidate(simuladoResultProvider(simuladoId)),
        ),
        data: (result) => CustomScrollView(
          slivers: [
            SliverPadding(
              padding: AppSpacing.screenPadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  Text('Resultado', style: AppTextStyles.h1),
                  const SizedBox(height: AppSpacing.lg),
                  ScoreHeaderCard(result: result),
                  const SizedBox(height: AppSpacing.lg),
                  SubjectPerformanceCard(bySubject: result.bySubject),
                  if (result.bySubject.isNotEmpty)
                    const SizedBox(height: AppSpacing.lg),
                  if (result.questions.isNotEmpty) ...[
                    Text('Revisão das questões', style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ]),
              ),
            ),
            if (result.questions.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                sliver: SliverList.builder(
                  itemCount: result.questions.length,
                  itemBuilder: (ctx, i) => QuestionReviewItem(
                    review: result.questions[i],
                    index: i,
                    onProGate: () => ProGateSheet.show(
                      context,
                      feature: 'explicações detalhadas',
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: AppSpacing.screenPadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  if (result.questions.isNotEmpty)
                    const SizedBox(height: AppSpacing.md),
                  AtoButton(
                    label: 'Novo simulado',
                    onPressed: () => context.go('/simulados'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AtoButton(
                    label: 'Voltar ao início',
                    variant: AtoButtonVariant.outline,
                    onPressed: () => context.go('/dashboard'),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
