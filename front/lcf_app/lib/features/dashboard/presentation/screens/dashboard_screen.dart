import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
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
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.backgroundCard,
        onRefresh: _onRefresh,
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('LCF', style: AppTextStyles.logoTitle),
                  Text('Início', style: AppTextStyles.labelMedium),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              GreetingCard(),
              SizedBox(height: AppSpacing.sectionGap),
              MetasDiariasCard(),
              SizedBox(height: AppSpacing.sectionGap),
              RevisaoInteligenteCard(),
              SizedBox(height: AppSpacing.sectionGap),
              TarefasRapidasCard(),
              SizedBox(height: AppSpacing.sectionGap),
              CardsMateriaCard(),
              SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
