import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/ato_button.dart';
import '../../../../shared/widgets/ato_error_state.dart';
import '../../../../shared/widgets/ato_loading_shimmer.dart';
import '../../../manual/data/manual_repository.dart';
import '../../data/models/tutor_history_models.dart';
import '../../data/models/tutor_models.dart';
import '../../data/tutor_repository.dart';
import '../../providers/tutor_provider.dart';
import '../widgets/chat_bubble.dart';

/// Provider de detalhe do histórico (scoped por sessionId).
final _historyDetailProvider = FutureProvider.autoDispose
    .family<HistoryDetailResponse, String>((ref, sessionId) async {
  final repo = ref.read(tutorRepositoryProvider);
  return repo.getHistoryDetail(sessionId);
});

/// Tela read-only do detalhe de uma conversa do histórico.
///
/// - Exibe as mensagens usando [ChatBubble] (com markdown via AtoMarkdownBody).
/// - Sem ChatInputBar, sem chips, sem typing indicator.
/// - Rodapé fixo com CTA "Nova conversa sobre isso":
///   - mode 'reading' + topicId: reabre /tutor/context com o conteúdo do tópico.
///   - mode 'direct' (ou topicId null): abre /tutor com sessão limpa.
class TutorHistoryDetailScreen extends ConsumerWidget {
  const TutorHistoryDetailScreen({
    super.key,
    required this.sessionId,
  });

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(_historyDetailProvider(sessionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: detailAsync.maybeWhen(
          data: (detail) => Text(
            detail.session.title.isNotEmpty
                ? detail.session.title
                : 'Conversa',
            style: AppTextStyles.labelLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.backgroundCard, AppColors.background],
            ),
          ),
        ),
      ),
      body: detailAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: AtoListShimmer(itemCount: 5, itemHeight: 80),
        ),
        error: (e, _) => AtoErrorState(
          message: 'Não foi possível carregar esta conversa.',
          onRetry: () => ref.invalidate(_historyDetailProvider(sessionId)),
        ),
        data: (detail) => _DetailContent(
          detail: detail,
          onNewConversation: () =>
              _onNewConversation(context, ref, detail.session),
        ),
      ),
    );
  }

  Future<void> _onNewConversation(
    BuildContext context,
    WidgetRef ref,
    HistorySession session,
  ) async {
    if (session.mode == 'reading' && session.topicId != null) {
      // Busca o conteúdo completo do tópico e reabre /tutor/context
      try {
        final repo = await ref.read(manualRepositoryProvider.future);
        final topicDetail = await repo.getTopicDetail(session.topicId!);
        if (context.mounted) {
          // Constrói o conteúdo concatenando as seções do tópico
          final content = topicDetail.sections
              .map((s) => '## ${s.title}\n${s.content}')
              .join('\n\n');
          context.push(
            '/tutor/context',
            extra: TutorScreenArgs(
              topicContext: TutorTopicContext(
                topicTitle: topicDetail.title,
                topicContent: content,
              ),
            ),
          );
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Não foi possível carregar o tópico. Tente novamente.'),
            ),
          );
        }
      }
    } else {
      // Modo direct ou topicId null: abre /tutor com sessão limpa
      await ref.read(tutorNotifierProvider.notifier).endSession();
      if (context.mounted) {
        context.go('/tutor');
      }
    }
  }
}

// ── Conteúdo da tela ─────────────────────────────────────────────────────

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.detail,
    required this.onNewConversation,
  });

  final HistoryDetailResponse detail;
  final VoidCallback onNewConversation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            itemCount: detail.messages.length,
            itemBuilder: (context, index) {
              final msg = detail.messages[index];
              // Converte HistoryMessage → TutorMessage para reusar ChatBubble
              final tutorMsg = TutorMessage(
                id: msg.id,
                role: msg.role,
                content: msg.content,
                createdAt: msg.createdAt,
              );
              return ChatBubble(
                key: ValueKey(msg.id),
                message: tutorMsg,
              );
            },
          ),
        ),
        // Rodapé com CTA
        _NewConversationFooter(onPressed: onNewConversation),
      ],
    );
  }
}

// ── Rodapé CTA ───────────────────────────────────────────────────────────

class _NewConversationFooter extends StatelessWidget {
  const _NewConversationFooter({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + bottomPad,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
        color: AppColors.background,
      ),
      child: AtoButton(
        label: 'Nova conversa sobre isso',
        prefixIcon: const Icon(
          Icons.add_comment_outlined,
          size: 18,
          color: Colors.white,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
