import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/dashboard_repository.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/cards_materia_card.dart';
import '../widgets/greeting_card.dart';
import '../widgets/metas_diarias_card.dart';
import '../widgets/revisao_inteligente_card.dart';
import '../widgets/tarefas_rapidas_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Future<void> _onRefresh() async {
    try {
      final repo = await ref.read(dashboardRepositoryProvider.future);
      await repo.invalidateCache();
    } catch (_) {}
    ref.invalidate(dashboardDataProvider);
    ref.invalidate(revisionCardsProvider);
    ref.invalidate(performanceProvider);
    try {
      await Future.wait([
        ref.read(dashboardDataProvider.future),
        ref.read(revisionCardsProvider.future),
        ref.read(performanceProvider.future),
      ]);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(dashboardDataProvider, (_, state) {
      if (state is AsyncError) {
        final e = state.error;
        if (e is DioException && e.response?.statusCode == 401) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => context.go('/login'),
          );
        }
      }
    });

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.backgroundCard,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lex', style: AppTextStyles.logoTitle),
                  Text('Início', style: AppTextStyles.labelMedium),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const GreetingCard(),
              const SizedBox(height: AppSpacing.sectionGap),
              const MetasDiariasCard(),
              const SizedBox(height: AppSpacing.sectionGap),
              const RevisaoInteligenteCard(),
              const SizedBox(height: AppSpacing.sectionGap),
              const TarefasRapidasCard(),
              const SizedBox(height: AppSpacing.sectionGap),
              const CardsMateriaCard(),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
