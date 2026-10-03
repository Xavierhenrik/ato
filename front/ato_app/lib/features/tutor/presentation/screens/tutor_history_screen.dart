import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/utils/ato_dialogs.dart';
import '../../../../shared/widgets/ato_app_bar.dart';
import '../../../../shared/widgets/ato_empty_state.dart';
import '../../../../shared/widgets/ato_error_state.dart';
import '../../../../shared/widgets/ato_loading_shimmer.dart';
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
    final confirmed = await atoConfirmDialog(
      context,
      title: 'Excluir conversa?',
      body: 'Esta ação é permanente e não pode ser desfeita.',
      confirmLabel: 'Excluir',
    );

    if (confirmed && mounted) {
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
      appBar: const AtoAppBar(
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
                child: AtoListShimmer(itemCount: 6, itemHeight: 90),
              ),
              error: (e, _) => AtoErrorState(
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

// ── Seletor de segmentos (padrão glass — mesma linguagem da nav bar) ──────

const double _kSegmentHeight = 42.0;

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(_kSegmentHeight / 2);
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: kGlassFrostSigma,
            sigmaY: kGlassFrostSigma,
          ),
          child: Container(
            height: _kSegmentHeight,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard.withValues(alpha: 0.18),
              borderRadius: radius,
              border: Border.all(
                color: AppColors.accent.withValues(alpha: kGlassTrimOpacity),
                width: kGlassTrimStroke,
              ),
            ),
            child: Row(
              children: [
                _Segment(
                  label: 'Diretas',
                  isSelected: selected == 0,
                  onTap: () => onChanged(0),
                  isLeft: true,
                ),
                // Divisor vertical
                VerticalDivider(
                  width: kGlassTrimStroke,
                  thickness: kGlassTrimStroke,
                  color: AppColors.accent.withValues(alpha: kGlassTrimOpacity),
                  indent: 8,
                  endIndent: 8,
                ),
                _Segment(
                  label: 'Do Manual',
                  isSelected: selected == 1,
                  onTap: () => onChanged(1),
                  isLeft: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isLeft,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.horizontal(
      left: isLeft ? const Radius.circular(_kSegmentHeight / 2) : Radius.zero,
      right: isLeft ? Radius.zero : const Radius.circular(_kSegmentHeight / 2),
    );
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.88)
                : Colors.transparent,
            borderRadius: borderRadius,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
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
    return AtoEmptyState(
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
