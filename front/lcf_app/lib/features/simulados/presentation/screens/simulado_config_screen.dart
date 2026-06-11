import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_app_bar.dart';
import '../../../../shared/widgets/lcf_button.dart';
import '../../../../shared/widgets/pro_gate_sheet.dart';
import '../../data/models/simulado_models.dart';
import '../../data/simulado_repository.dart';
import '../../providers/simulado_provider.dart';
import '../widgets/mode_option_card.dart';
import '../widgets/quantity_chip.dart';

enum _InProgressAction { continueExisting, startNew, cancel }

class SimuladoConfigScreen extends ConsumerStatefulWidget {
  const SimuladoConfigScreen({super.key});

  @override
  ConsumerState<SimuladoConfigScreen> createState() =>
      _SimuladoConfigScreenState();
}

class _SimuladoConfigScreenState
    extends ConsumerState<SimuladoConfigScreen> {
  SimuladoMode _selectedMode = SimuladoMode.oabPhase1;
  int _selectedQuantity = 15;
  bool _isStarting = false;

  static const _quantities = [10, 15, 30, 50, 80];

  bool _isModeComingSoon(SimuladoMode mode) => mode == SimuladoMode.oabPhase2;

  bool _isModeLockedForFree(SimuladoMode mode) => mode == SimuladoMode.weakAreas;

  bool _isQtyLockedForFree(int qty) => qty > 15;

  Future<void> _startSimulado() async {
    if (_isStarting) return;
    setState(() => _isStarting = true);
    try {
      final attempt = await ref
          .read(simuladoRepositoryProvider)
          .startSimulado(
            mode: _selectedMode.apiValue,
            totalQ: _selectedQuantity,
          );
      if (mounted) {
        context.push('/simulados/${attempt.id}', extra: attempt);
        ref.invalidate(simuladoHistoryProvider);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      final errorCode =
          e.response?.data is Map ? e.response?.data['error'] as String? : null;

      if (status == 409 && errorCode == 'SIMULADO_IN_PROGRESS') {
        final inProgressId = e.response?.data is Map
            ? e.response?.data['inProgressId'] as String?
            : null;
        await _handleInProgress(inProgressId);
      } else if (status == 403 || status == 429) {
        await ProGateSheet.show(context, feature: 'simulados ilimitados');
      } else if (status == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parâmetros inválidos. Tente novamente.')),
        );
      } else if (status == 401) {
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao conectar. Tente novamente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<void> _handleInProgress(String? inProgressId) async {
    if (!mounted) return;
    final action = await showDialog<_InProgressAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('Simulado em andamento', style: AppTextStyles.h3),
        content: Text(
          'Você já tem um simulado em andamento. Deseja continuar ou iniciar um novo?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_InProgressAction.cancel),
            child: Text(
              'Cancelar',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_InProgressAction.startNew),
            child: Text(
              'Novo',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_InProgressAction.continueExisting),
            child: Text(
              'Continuar',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );

    if (!mounted || action == null || action == _InProgressAction.cancel) {
      return;
    }

    final repo = ref.read(simuladoRepositoryProvider);
    if (action == _InProgressAction.startNew) {
      if (inProgressId != null) await repo.abandonSimulado(inProgressId);
      await _startSimulado();
    } else {
      final attempt = await repo.getInProgress();
      if (mounted && attempt != null) {
        context.push('/simulados/${attempt.id}', extra: attempt);
      }
    }
  }

  void _onModeTap(SimuladoMode mode, bool isPro) {
    if (_isModeComingSoon(mode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Em breve. Estamos preparando o módulo da 2ª fase OAB.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    final isLocked = !isPro && _isModeLockedForFree(mode);
    if (isLocked) {
      ProGateSheet.show(context, feature: mode.label);
      return;
    }
    setState(() => _selectedMode = mode);
  }

  void _onQtyTap(int qty, bool isPro) {
    final isLocked = !isPro && _isQtyLockedForFree(qty);
    if (isLocked) {
      ProGateSheet.show(context, feature: 'simulados com mais questões');
      return;
    }
    setState(() => _selectedQuantity = qty);
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(simuladoUserPlanProvider);
    final isPro = planAsync.valueOrNull == 'pro';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LcfAppBar(showBack: true, fallbackRoute: '/dashboard'),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Simulado', style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.xl),

            // Mode selector
            const _SectionHeader(label: 'Modo do simulado'),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.6,
              children: SimuladoMode.values.map((mode) {
                final comingSoon = _isModeComingSoon(mode);
                final locked = !comingSoon && !isPro && _isModeLockedForFree(mode);
                return ModeOptionCard(
                  mode: mode,
                  isSelected: _selectedMode == mode,
                  isLocked: locked,
                  isComingSoon: comingSoon,
                  onTap: () => _onModeTap(mode, isPro),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Quantity selector
            const _SectionHeader(label: 'Número de questões'),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _quantities.map((qty) {
                final locked = !isPro && _isQtyLockedForFree(qty);
                return QuantityChip(
                  quantity: qty,
                  isSelected: _selectedQuantity == qty,
                  isLocked: locked,
                  onTap: () => _onQtyTap(qty, isPro),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // History
            _HistoricoSection(),
            const SizedBox(height: AppSpacing.xxl),

            // Start button
            LcfButton(
              label: _isStarting ? 'Iniciando...' : 'Iniciar simulado',
              onPressed: _isStarting ? null : _startSimulado,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(label, style: AppTextStyles.h3);
}

class _HistoricoSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histAsync = ref.watch(simuladoHistoryProvider);

    return histAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final recent = items.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(label: 'Histórico recente'),
            const SizedBox(height: AppSpacing.md),
            ...recent.map((item) => _HistoryTile(item: item)),
          ],
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});
  final SimuladoHistoryItem item;

  @override
  Widget build(BuildContext context) {
    // Backend returns score as percentage (0-100), not fraction (0-1).
    final pct = item.score.round();
    final label = _modeLabel(item.mode);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${item.totalQuestions} questões',
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ),
          Text(
            '$pct%',
            style: AppTextStyles.accentMedium,
          ),
        ],
      ),
    );
  }

  String _modeLabel(String mode) => switch (mode) {
        'oab_phase1' => 'OAB Fase 1',
        'oab_phase2' => 'OAB Fase 2',
        'weak_areas' => 'Pontos fracos',
        _ => 'Por matéria',
      };
}
