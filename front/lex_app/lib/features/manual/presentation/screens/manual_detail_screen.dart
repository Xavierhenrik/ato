import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/category_tag.dart';
import '../../../../shared/widgets/lex_app_bar.dart';
import '../../../../shared/utils/async_value_handler.dart';
import '../../../../shared/widgets/lex_loading_shimmer.dart';
import '../../data/models/manual_models.dart';
import '../../data/manual_repository.dart';
import '../../providers/manual_provider.dart';
import '../widgets/manual_tutor_orb.dart';
import '../widgets/sobre_este_resumo_card.dart';
import '../widgets/topic_section_tile.dart';

class ManualDetailScreen extends ConsumerStatefulWidget {
  const ManualDetailScreen({super.key, required this.topicId});

  final String topicId;

  @override
  ConsumerState<ManualDetailScreen> createState() =>
      _ManualDetailScreenState();
}

class _ManualDetailScreenState extends ConsumerState<ManualDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fire-and-forget: mark as read on screen entry
    WidgetsBinding.instance.addPostFrameCallback((_) => _fireMarkAsRead());
  }

  void _fireMarkAsRead() {
    ref
        .read(manualRepositoryProvider.future)
        .then((repo) => repo.markAsRead(widget.topicId))
        .then((_) {
          if (!mounted) return;
          final selectedCode = ref.read(selectedLawCodeProvider);
          ref.invalidate(manualTopicsProvider(lawCode: selectedCode));
          ref.invalidate(filteredTopicsProvider);
        })
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(manualTopicDetailProvider(widget.topicId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LexAppBar(
        showBack: true,
        fallbackRoute: '/manual',
      ),
      body: detailAsync.when(
        loading: () => const _DetailShimmer(),
        error: (e, _) => handleAsyncError(
          e,
          context,
          message: 'Erro ao carregar o tópico. Tente novamente.',
          onRetry: () => ref.invalidate(manualTopicDetailProvider(widget.topicId)),
        ),
        data: (topic) => Stack(
          children: [
            _DetailBody(topic: topic),
            Positioned.fill(
              child: ManualTutorOrb(topic: topic),
            ),
          ],
        ),
      ),
    );
  }

}

// ── Detail body ───────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.topic});
  final TopicDetail topic;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryTag(label: topic.lawLabel),
          const SizedBox(height: AppSpacing.sm),
          Text(topic.title, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          _MetaRow(topic: topic),
          const SizedBox(height: AppSpacing.lg),
          const SobreEsteResumoCard(),
          const SizedBox(height: AppSpacing.xl),
          _SectionDivider(),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(
            topic.sections.length,
            (i) => TopicSectionTile(
              section: topic.sections[i],
              index: i,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.topic});
  final TopicDetail topic;

  @override
  Widget build(BuildContext context) {
    final updatedLabel = _formatDate(topic.updatedAt);
    return Row(
      children: [
        const Icon(
          Icons.timer_outlined,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '${topic.readTimeMinutes} min de leitura',
          style: AppTextStyles.labelMedium,
        ),
        if (updatedLabel != null) ...[
          const SizedBox(width: AppSpacing.lg),
          const Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Atualizado em $updatedLabel',
            style: AppTextStyles.labelMedium,
          ),
        ],
      ],
    );
  }

  String? _formatDate(DateTime? dt) {
    if (dt == null) return null;
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${months[dt.month - 1]}/${dt.year}';
  }
}

class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('Resumo', style: AppTextStyles.labelMedium),
        ),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    );
  }
}

// ── Loading shimmer ───────────────────────────────────────────────────────────

class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LexLoadingShimmer(width: 100, height: 28),
          const SizedBox(height: AppSpacing.md),
          const LexLoadingShimmer(height: 32),
          const SizedBox(height: AppSpacing.sm),
          const LexLoadingShimmer(width: 200, height: 16),
          const SizedBox(height: AppSpacing.xl),
          const LexLoadingShimmer(height: 96),
          const SizedBox(height: AppSpacing.xl),
          ...List.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.lg),
              child: LexLoadingShimmer(height: 80),
            ),
          ),
        ],
      ),
    );
  }
}
