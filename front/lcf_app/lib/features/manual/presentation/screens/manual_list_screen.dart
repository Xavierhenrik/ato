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
import '../../data/models/manual_models.dart';
import '../../providers/manual_provider.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/manual_search_bar.dart';
import '../widgets/topic_card.dart';

class ManualListScreen extends ConsumerStatefulWidget {
  const ManualListScreen({super.key});

  @override
  ConsumerState<ManualListScreen> createState() => _ManualListScreenState();
}

class _ManualListScreenState extends ConsumerState<ManualListScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LcfAppBar(
        showBack: true,
        fallbackRoute: '/dashboard',
        actions: _isSearching
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  color: AppColors.textPrimary,
                  onPressed: _openSearch,
                ),
              ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSearching) ...[
            ManualSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClose: _closeSearch,
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            const FilterChipsRow(),
          ],
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _isSearching
                ? _SearchResultsView(query: _searchQuery)
                : const _TopicsListView(),
          ),
        ],
      ),
    );
  }
}

// ── Topics list (normal mode) ─────────────────────────────────────────────────

class _TopicsListView extends ConsumerWidget {
  const _TopicsListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(filteredTopicsProvider);
    return topicsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: LcfListShimmer(itemCount: 8, itemHeight: 88),
      ),
      error: (e, _) {
        if (e is DioException && e.response?.statusCode == 401) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => context.go('/login'),
          );
          return const SizedBox.shrink();
        }
        return LcfErrorState(
          message: 'Erro ao carregar tópicos. Tente novamente.',
          onRetry: () => ref.invalidate(filteredTopicsProvider),
        );
      },
      data: (topics) {
        if (topics.isEmpty) {
          return const LcfEmptyState(
            title: 'Nenhum tópico encontrado',
            icon: Icons.menu_book_outlined,
          );
        }
        return ListView.separated(
          padding: AppSpacing.screenPadding,
          itemCount: topics.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, i) => TopicCard(
            topic: topics[i],
            onTap: () => context.push('/manual/topic/${topics[i].id}'),
          ),
        );
      },
    );
  }
}

// ── Search results (search mode) ─────────────────────────────────────────────

class _SearchResultsView extends ConsumerWidget {
  const _SearchResultsView({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.isEmpty) {
      return const LcfEmptyState(
        title: 'Digite para buscar',
        subtitle: 'Pesquise por tópicos ou artigos',
        icon: Icons.search,
      );
    }
    final resultsAsync = ref.watch(manualSearchProvider(query));
    return resultsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: LcfListShimmer(itemCount: 5, itemHeight: 80),
      ),
      error: (e, _) => const LcfErrorState(
        message: 'Erro ao buscar. Tente novamente.',
      ),
      data: (results) {
        if (results.isEmpty) {
          return LcfEmptyState(
            title: 'Nenhum resultado para "$query"',
            icon: Icons.menu_book_outlined,
          );
        }
        return ListView.separated(
          padding: AppSpacing.screenPadding,
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, i) => _SearchResultCard(
            result: results[i],
            onTap: () => context.push('/manual/topic/${results[i].id}'),
          ),
        );
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.result, required this.onTap});
  final ManualSearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.title,
              style: AppTextStyles.labelLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (result.snippet.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                result.snippet,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
