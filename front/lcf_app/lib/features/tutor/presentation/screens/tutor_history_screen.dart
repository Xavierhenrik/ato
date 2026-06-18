import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_app_bar.dart';
import '../../../../shared/widgets/lcf_empty_state.dart';
import '../../../../shared/widgets/lcf_error_state.dart';
import '../../../../shared/widgets/lcf_loading_shimmer.dart';
import '../../../../shared/widgets/pro_gate_sheet.dart';
import '../../data/models/tutor_history_models.dart';
import '../../providers/tutor_history_provider.dart';
import '../widgets/history_session_card.dart';

/// Tela de histórico de conversas do Tutor IA.
///
/// - Dois segmentos: "Diretas" (mode: direct) e "Do Manual" (mode: reading).
/// - Scroll infinito com paginação por cursor.
/// - Long-press no card abre dialog de confirmação de exclusão.
/// - Banner fixo quando retention == '7d' (Free).
class TutorHistoryScreen extends ConsumerStatefulWidget {
  const TutorHistoryScreen({super.key});

  @override
  ConsumerState<TutorHistoryScreen> createState() =>
      _TutorHistoryScreenState();
}

class _TutorHistoryScreenState extends ConsumerState<TutorHistoryScreen> {
  int _selectedSegment = 0; // 0 = Diretas, 1 = Do Manual
  final _scrollController = ScrollController();

  String get _mode => _selectedSegment == 0 ? 'direct' : 'reading';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    // Dispara loadMore quando estiver a 200px do fim
    if (current >= maxExtent - 200) {
      final notifier = ref.read(tutorHistoryNotifierProvider(_mode).notifier);
      final st = ref.read(tutorHistoryNotifierProvider(_mode)).valueOrNull;
      if (st != null && !st.isLoadingMore && st.hasMore) {
        notifier.loadMore();
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HistorySession session,
  ) async {
    // Captura messenger antes de qualquer gap assíncrono
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Excluir conversa?', style: AppTextStyles.h3),
        content: Text(
          'Esta ação é permanente e não pode ser desfeita.',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancelar',
              style:
                  AppTextStyles.labelLarge.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Excluir',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(tutorHistoryNotifierProvider(_mode).notifier)
            .deleteSession(session.id);
      } catch (_) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir conversa. Tente novamente.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(tutorHistoryNotifierProvider(_mode));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LcfAppBar(
        showBack: true,
        fallbackRoute: '/tutor',
        actions: [],
      ),
      body: Column(
        children: [
          // Seletor de segmentos
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: _SegmentedControl(
              selected: _selectedSegment,
              onChanged: (idx) {
                setState(() {
                  _selectedSegment = idx;
                });
              },
            ),
          ),
          // Conteúdo principal
          Expanded(
            child: historyAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: LcfListShimmer(itemCount: 6, itemHeight: 90),
              ),
              error: (e, _) => LcfErrorState(
                message: 'Não foi possível carregar o histórico.',
                onRetry: () => ref.invalidate(
                  tutorHistoryNotifierProvider(_mode),
                ),
              ),
              data: (state) {
                if (state.sessions.isEmpty) {
                  return _EmptyHistory(mode: _mode);
                }
                return _HistoryList(
                  state: state,
                  mode: _mode,
                  scrollController: _scrollController,
                  onTap: (session) =>
                      context.push('/tutor/history/${session.id}'),
                  onLongPress: (session) =>
                      _confirmDelete(context, session),
                  onBannerTap: () =>
                      ProGateSheet.show(context, feature: 'histórico completo'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Seletor de segmentos ──────────────────────────────────────────────────

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.chip,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Diretas',
            isSelected: selected == 0,
            onTap: () => onChanged(0),
            isFirst: true,
          ),
          _Segment(
            label: 'Do Manual',
            isSelected: selected == 1,
            onTap: () => onChanged(1),
            isFirst: false,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isFirst,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: isFirst
                ? const BorderRadius.horizontal(
                    left: Radius.circular(AppRadius.full),
                  )
                : const BorderRadius.horizontal(
                    right: Radius.circular(AppRadius.full),
                  ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ── Lista de histórico ────────────────────────────────────────────────────

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.state,
    required this.mode,
    required this.scrollController,
    required this.onTap,
    required this.onLongPress,
    required this.onBannerTap,
  });

  final TutorHistoryState state;
  final String mode;
  final ScrollController scrollController;
  final ValueChanged<HistorySession> onTap;
  final ValueChanged<HistorySession> onLongPress;
  final VoidCallback onBannerTap;

  @override
  Widget build(BuildContext context) {
    final showBanner = state.retention == '7d';

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount:
                state.sessions.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              if (index == state.sessions.length) {
                // Loading indicator de paginação
                return const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                );
              }

              final session = state.sessions[index];
              return HistorySessionCard(
                session: session,
                onTap: () => onTap(session),
                onLongPress: () => onLongPress(session),
              );
            },
          ),
        ),
        // Banner Free 7d
        if (showBanner)
          _FreeBanner(onTap: onBannerTap),
      ],
    );
  }
}

// ── Banner Free ───────────────────────────────────────────────────────────

class _FreeBanner extends StatelessWidget {
  const _FreeBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              color: AppColors.accent,
              size: 16,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Mostrando os últimos 7 dias · ',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              'PRO guarda tudo',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Estado vazio ──────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    final isReading = mode == 'reading';
    return LcfEmptyState(
      icon: Icons.history_rounded,
      title: isReading
          ? 'Nenhuma conversa do Manual'
          : 'Nenhuma conversa direta',
      subtitle: isReading
          ? 'Abra um tópico no Manual e toque no orbe para iniciar uma conversa.'
          : 'Inicie uma conversa com o Tutor IA para vê-la aqui.',
    );
  }
}
