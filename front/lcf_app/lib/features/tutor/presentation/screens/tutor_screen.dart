import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/lcf_app_bar.dart';
import '../../../../shared/widgets/pro_gate_sheet.dart';
import '../../data/models/tutor_models.dart';
import '../../providers/tutor_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chips_row.dart';
import '../widgets/tutor_empty_state.dart';
import '../widgets/typing_indicator.dart';

class TutorScreen extends ConsumerStatefulWidget {
  const TutorScreen({super.key});

  @override
  ConsumerState<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends ConsumerState<TutorScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  bool _pendingScroll = false;
  String? _lastNewAssistantId;
  String? _previousLastAssistantId;

  @override
  void dispose() {
    // Fire-and-forget — capture notifier before dispose chain starts
    ref.read(tutorNotifierProvider.notifier).endSession();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onSend(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    _inputController.clear();
    FocusScope.of(context).unfocus();

    try {
      final annotationId = await ref
          .read(tutorNotifierProvider.notifier)
          .sendMessage(trimmed);

      if (annotationId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anotação salva automaticamente ✓')),
        );
      }
      _scrollToBottom();
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      if (status == 429) {
        ProGateSheet.show(context, feature: 'Limite diário atingido');
      } else if (status == 401) {
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao conectar. Tente novamente.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem conexão. Tente novamente.')),
      );
    }
  }

  void _scrollToBottom() {
    if (_pendingScroll) return;
    _pendingScroll = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingScroll = false;
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _confirmEndSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('Encerrar conversa?', style: AppTextStyles.h3),
        content: Text(
          'O histórico desta sessão será apagado.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancelar',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Encerrar',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(tutorNotifierProvider.notifier).endSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(tutorNotifierProvider);
    final hasMessages =
        chatState.messages.isNotEmpty || chatState.streamingContent != null;

    // Track latest assistant message id to drive typewriter animation only on
    // messages received after the screen mounted (not on history load).
    String? latestAssistantId;
    for (var i = chatState.messages.length - 1; i >= 0; i--) {
      if (chatState.messages[i].role == 'assistant') {
        latestAssistantId = chatState.messages[i].id;
        break;
      }
    }
    if (latestAssistantId != null &&
        latestAssistantId != _previousLastAssistantId) {
      // Only mark as "new" when the previous tracked id was non-null
      // (skip initial history load — those should not animate).
      if (_previousLastAssistantId != null) {
        _lastNewAssistantId = latestAssistantId;
      }
      _previousLastAssistantId = latestAssistantId;
    }

    // Scroll to bottom on every streaming tick so text stays in view.
    ref.listen<TutorChatState>(tutorNotifierProvider, (prev, next) {
      if (next.streamingContent != null) _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LcfTutorAppBar(
        actions: [
          if (hasMessages)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.textSecondary,
              ),
              onPressed: _confirmEndSession,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: hasMessages
                ? _ChatListView(
                    messages: chatState.messages,
                    isLoading: chatState.isLoading,
                    streamingContent: chatState.streamingContent,
                    scrollController: _scrollController,
                    onChipTap: _onSend,
                    animatedMessageId: _lastNewAssistantId,
                  )
                : TutorEmptyState(onChipTap: _onSend),
          ),
          ChatInputBar(
            controller: _inputController,
            onSend: _onSend,
            // Disable input while loading OR streaming to avoid overlapping messages.
            enabled: !chatState.isLoading && chatState.streamingContent == null,
          ),
        ],
      ),
    );
  }
}

class _ChatListView extends StatelessWidget {
  const _ChatListView({
    required this.messages,
    required this.isLoading,
    required this.scrollController,
    required this.onChipTap,
    this.streamingContent,
    this.animatedMessageId,
  });

  final List<TutorMessage> messages;
  final bool isLoading;
  final ScrollController scrollController;
  final ValueChanged<String> onChipTap;
  final String? streamingContent;
  final String? animatedMessageId;

  @override
  Widget build(BuildContext context) {
    // Find last assistant message to show continuation chips there only
    final lastAiIndex =
        messages.lastIndexWhere((m) => m.role == 'assistant');
    final isStreaming = streamingContent != null;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      // One extra slot: TypingIndicator while loading OR streaming bubble.
      itemCount: messages.length + ((isLoading || isStreaming) ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          if (isLoading) return const TypingIndicator();
          if (isStreaming) {
            return ChatBubble(
              message: TutorMessage(
                id: 'streaming',
                role: 'assistant',
                content: streamingContent!,
                createdAt: DateTime.now(),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final msg = messages[index];
        // Hide chips while a response is still streaming to avoid layout jump.
        final showChips = msg.role == 'assistant' &&
            index == lastAiIndex &&
            msg.continuationChips.isNotEmpty &&
            !isLoading &&
            !isStreaming;
        final shouldAnimate = animatedMessageId != null &&
            msg.id == animatedMessageId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatBubble(
              key: ValueKey(msg.id),
              message: msg,
              animate: shouldAnimate,
            ),
            if (showChips)
              ChipsRow(chips: msg.continuationChips, onTap: onChipTap),
          ],
        );
      },
    );
  }
}
