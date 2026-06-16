import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_button.dart';
import '../../../../shared/widgets/lcf_glass_sheet.dart';
import '../../../../shared/widgets/pro_gate_sheet.dart';
import '../../../simulados/data/simulado_repository.dart';
import '../../data/models/dashboard_models.dart';
import '../../providers/dashboard_provider.dart';

class RevisarSheet extends ConsumerStatefulWidget {
  const RevisarSheet({super.key, required this.card});

  final RevisionCard card;

  static Future<void> show(BuildContext context, {required RevisionCard card}) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => RevisarSheet(card: card),
    );
  }

  @override
  ConsumerState<RevisarSheet> createState() => _RevisarSheetState();
}

class _RevisarSheetState extends ConsumerState<RevisarSheet> {
  bool _isLoading = false;
  String? _errorMessage;

  RevisionCard get card => widget.card;

  bool get _isPro =>
      ref.read(dashboardDataProvider).valueOrNull?.plan == 'pro';

  Future<void> _startPractice() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final attempt = await ref
          .read(simuladoRepositoryProvider)
          .startSimulado(mode: 'custom', totalQ: 10, subject: card.subject);

      if (!mounted) return;
      final router = GoRouter.of(context);
      final nav = Navigator.of(context);
      nav.pop();
      router.push('/simulados/${attempt.id}', extra: attempt);
    } on DioException catch (e) {
      if (!mounted) return;
      final errorCode =
          e.response?.data is Map ? e.response?.data['error'] as String? : null;
      final status = e.response?.statusCode;

      final String msg;
      if (status == 404 || errorCode?.contains('NOT_FOUND') == true) {
        msg = 'Ainda não há questões de revisão para ${card.subject}.';
      } else if (status == 409) {
        msg = 'Você tem um simulado em andamento. Conclua-o primeiro.';
      } else {
        msg = 'Erro ao iniciar simulado. Tente novamente.';
      }
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erro ao iniciar simulado. Tente novamente.';
        _isLoading = false;
      });
    }
  }

  void _onReadSummary() {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    if (_isPro && card.topTopics.isNotEmpty) {
      router.push('/manual/topic/${card.topTopics.first.id}');
    } else {
      router.push('/manual?subject=${Uri.encodeComponent(card.subject)}');
    }
  }

  void _onTopicTap(RevisionTopic topic) {
    if (!_isPro) {
      ProGateSheet.show(context, feature: 'revisão direcionada por tópico');
      return;
    }
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push('/manual/topic/${topic.id}');
  }

  @override
  Widget build(BuildContext context) {
    final pct = (card.errorRate * 100).round();
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final topics = card.topTopics;
    final isPro = ref.watch(dashboardDataProvider).valueOrNull?.plan == 'pro';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: LcfGlassSheet(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.lg + bottomPad,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Título e contexto de desempenho
              Text(card.subject, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Você errou $pct% · ${card.totalAnswered} respondidas',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),

              // Seção "Onde você mais errou"
              if (topics.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Onde você mais errou',
                    style: AppTextStyles.labelMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...topics.map(
                  (topic) => _TopicRow(
                    topic: topic,
                    isPro: isPro,
                    onTap: () => _onTopicTap(topic),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // Mensagem de erro (ex.: sem questões de revisão)
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: AppRadius.card,
                  ),
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Ler resumo — PRO com tópicos: abre o tópico #1; senão: subject filter
              LcfButton(
                label: 'Ler resumo',
                variant: LcfButtonVariant.secondary,
                prefixIcon: const Icon(
                  Icons.menu_book_outlined,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                onPressed: _onReadSummary,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Praticar questões → simulado custom type:review
              LcfButton(
                label: 'Praticar questões',
                isLoading: _isLoading,
                prefixIcon: _isLoading
                    ? null
                    : const Icon(
                        Icons.quiz_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                onPressed: _startPractice,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({
    required this.topic,
    required this.isPro,
    required this.onTap,
  });

  final RevisionTopic topic;
  final bool isPro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(
              isPro ? Icons.chevron_right : Icons.lock_outline,
              size: 16,
              color: isPro ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                topic.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isPro ? AppColors.textPrimary : AppColors.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: AppRadius.chip,
              ),
              child: Text(
                '${topic.errors} erros',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isPro ? AppColors.textSecondary : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
