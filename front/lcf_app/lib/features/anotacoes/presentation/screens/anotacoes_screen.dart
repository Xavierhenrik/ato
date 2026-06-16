import 'dart:async';

import 'package:dio/dio.dart';
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
import '../../data/anotacao_repository.dart';
import '../../data/models/anotacao_models.dart';
import '../../providers/anotacao_provider.dart';
import '../widgets/anotacao_card.dart';
import '../widgets/anotacao_filter_chips.dart';
import '../widgets/anotacao_search_bar.dart';

class AnotacoesScreen extends ConsumerStatefulWidget {
  const AnotacoesScreen({super.key});

  @override
  ConsumerState<AnotacoesScreen> createState() => _AnotacoesScreenState();
}

class _AnotacoesScreenState extends ConsumerState<AnotacoesScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _searchQuery = value.trim());
    });
  }

  void _openSearch() => setState(() => _isSearching = true);

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
    _searchController.clear();
    _debounce?.cancel();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(anotacoesProvider);
    try {
      final subject = ref.read(selectedSubjectFilterProvider);
      await ref.read(anotacoesProvider(subject: subject).future);
    } catch (_) {}
  }

  Future<bool> _onDeleteRequest(Anotacao anotacao) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('Excluir anotação', style: AppTextStyles.h3),
        content: Text(
          'Esta ação não pode ser desfeita.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Excluir',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return false;

    try {
      await ref
          .read(anotacaoRepositoryProvider)
          .deleteAnnotation(anotacao.id);
      ref.invalidate(anotacoesProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LcfAppBar(
        actions: _isSearching
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  color: AppColors.textPrimary,
                  onPressed: _openSearch,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: AppColors.textPrimary,
                  onPressed: () => context.push('/anotacoes/nova'),
                ),
              ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSearching) ...[
            AnotacaoSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClose: _closeSearch,
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            const AnotacaoFilterChips(),
          ],
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _isSearching
                ? _SearchResultsView(
                    query: _searchQuery,
                    onDeleteRequest: _onDeleteRequest,
                  )
                : RefreshIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.backgroundCard,
                    onRefresh: _onRefresh,
                    child: _AnotacoesListView(onDeleteRequest: _onDeleteRequest),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/anotacoes/nova'),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ── Normal list (with filter) ─────────────────────────────────────────────────

class _AnotacoesListView extends ConsumerWidget {
  const _AnotacoesListView({required this.onDeleteRequest});
  final Future<bool> Function(Anotacao) onDeleteRequest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = ref.watch(selectedSubjectFilterProvider);
    final anotacoesAsync = ref.watch(anotacoesProvider(subject: subject));

    return anotacoesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: LcfListShimmer(itemCount: 6, itemHeight: 100),
      ),
      error: (e, _) {
        if (e is DioException && e.response?.statusCode == 401) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => context.go('/login'),
          );
          return const SizedBox.shrink();
        }
        return LcfErrorState(
          message: 'Erro ao carregar anotações. Tente novamente.',
          onRetry: () => ref.invalidate(anotacoesProvider),
        );
      },
      data: (anotacoes) {
        if (anotacoes.isEmpty) {
          return LcfEmptyState(
            title: 'Nenhuma anotação ainda',
            subtitle: 'Crie sua primeira anotação para começar',
            icon: Icons.bookmark_outline,
            ctaLabel: 'Criar primeira anotação',
            onCta: () => context.push('/anotacoes/nova'),
          );
        }
        final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
        return ListView.separated(
          padding: AppSpacing.screenPadding.copyWith(
            bottom: bottomPad,
          ),
          itemCount: anotacoes.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, i) => _SwipeToDeleteCard(
            anotacao: anotacoes[i],
            onDeleteRequest: () => onDeleteRequest(anotacoes[i]),
            onTap: () => context.push(
              '/anotacoes/${anotacoes[i].id}/editar',
              extra: anotacoes[i],
            ),
          ),
        );
      },
    );
  }
}

// ── Search results ────────────────────────────────────────────────────────────

class _SearchResultsView extends ConsumerWidget {
  const _SearchResultsView({
    required this.query,
    required this.onDeleteRequest,
  });
  final String query;
  final Future<bool> Function(Anotacao) onDeleteRequest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) {
      return const LcfEmptyState(
        title: 'Digite para buscar',
        subtitle: 'Pesquise por título ou conteúdo',
        icon: Icons.search,
      );
    }

    final anotacoesAsync = ref.watch(anotacoesProvider(q: query));

    return anotacoesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: LcfListShimmer(itemCount: 4, itemHeight: 100),
      ),
      error: (e, _) => const LcfErrorState(
        message: 'Erro ao buscar. Tente novamente.',
      ),
      data: (anotacoes) {
        if (anotacoes.isEmpty) {
          return LcfEmptyState(
            title: 'Nenhum resultado para "$query"',
            icon: Icons.bookmark_outline,
          );
        }
        final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
        return ListView.separated(
          padding: AppSpacing.screenPadding.copyWith(
            bottom: bottomPad,
          ),
          itemCount: anotacoes.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, i) => _SwipeToDeleteCard(
            anotacao: anotacoes[i],
            onDeleteRequest: () => onDeleteRequest(anotacoes[i]),
            onTap: () => context.push(
              '/anotacoes/${anotacoes[i].id}/editar',
              extra: anotacoes[i],
            ),
          ),
        );
      },
    );
  }
}

// ── Dismissible wrapper ───────────────────────────────────────────────────────

class _SwipeToDeleteCard extends StatelessWidget {
  const _SwipeToDeleteCard({
    required this.anotacao,
    required this.onDeleteRequest,
    required this.onTap,
  });

  final Anotacao anotacao;
  final Future<bool> Function() onDeleteRequest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(anotacao.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onDeleteRequest(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: AppRadius.card,
        ),
        child: const Icon(
          Icons.delete_outline,
          color: AppColors.error,
          size: 24,
        ),
      ),
      child: AnotacaoCard(anotacao: anotacao, onTap: onTap),
    );
  }
}
