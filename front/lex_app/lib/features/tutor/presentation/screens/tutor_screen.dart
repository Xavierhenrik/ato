import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/nav_bar_provider.dart';
import '../../../../shared/widgets/lex_top_scrim.dart';
import '../../../../shared/widgets/pro_gate_sheet.dart';
import '../../data/models/tutor_models.dart';
import '../../providers/tutor_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chips_row.dart';
import '../widgets/tutor_consent_modal.dart';
import '../widgets/tutor_empty_state.dart';
import '../widgets/typing_indicator.dart';

class TutorScreen extends ConsumerStatefulWidget {
  const TutorScreen({
    super.key,
    this.initialMessage,
    this.topicContext,
  });

  /// Mensagem enviada automaticamente ao abrir a tela (e.g. "Resumo para prova").
  final String? initialMessage;

  /// Contexto de leitura do Manual. Quando presente, o Tutor recebe o conteúdo
  /// do tópico no system prompt e responde os chips de modo 'reading'.
  final TutorTopicContext? topicContext;

  @override
  ConsumerState<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends ConsumerState<TutorScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  bool _pendingScroll = false;
  bool _chipJustTapped = false;
  late final TutorNotifier _tutorNotifier;

  @override
  void initState() {
    super.initState();
    _tutorNotifier = ref.read(tutorNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Consentimento obrigatório (Guideline 5.1.2.i) antes de qualquer envio
      final prefs = await SharedPreferences.getInstance();
      final accepted = prefs.getBool('tutor_ai_consent_accepted') ?? false;
      if (!accepted) {
        if (!mounted) return;
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const TutorConsentModal(),
        );
        if (result != true) {
          if (mounted) context.go('/dashboard');
          return;
        }
        await prefs.setBool('tutor_ai_consent_accepted', true);
      }

      if (!mounted) return;
      if (widget.topicContext != null) {
        ref.read(tutorNotifierProvider.notifier).initWithContext(
              mode: 'reading',
              topicContext: widget.topicContext,
            );
      }
      if (widget.initialMessage != null) {
        _onSend(widget.initialMessage!);
      }
    });
  }

  @override
  void dispose() {
    // Restaura nav bar ao sair do tutor.
    Future(() {
      _tutorNotifier.endSession();
      try {
        ref.read(navBarModeProvider.notifier).state = NavBarMode.expanded;
      } catch (_) { /* fire-and-forget no dispose */ }
    });
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

  // Chip tapped: marca flag ANTES do GestureDetector pai disparar, evitando
  // que o toque no chip expanda a barra indevidamente.
  void _handleChipTap(String chip) {
    _chipJustTapped = true;
    _onSend(chip);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chipJustTapped = false;
    });
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

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(tutorNotifierProvider);
    final hasMessages =
        chatState.messages.isNotEmpty || chatState.streamingContent != null;

    // Compacta a nav bar ao iniciar a conversa E ao término de cada resposta da IA.
    // Isso garante que após o usuário restaurar a barra (double-tap) e mandar
    // outra mensagem, a barra volta para compacto ao fim do streaming — sem
    // exigir que seja a primeira mensagem.
    ref.listen<TutorChatState>(tutorNotifierProvider, (prev, next) {
      final wasActive = (prev?.messages.isNotEmpty ?? false) ||
          (prev?.streamingContent != null);
      final isActive =
          next.messages.isNotEmpty || next.streamingContent != null;
      final justFinishedStreaming = (prev?.streamingContent != null) &&
          next.streamingContent == null &&
          next.messages.isNotEmpty;

      if ((!wasActive && isActive) || justFinishedStreaming) {
        ref.read(navBarModeProvider.notifier).state = NavBarMode.compact;
      }
      if (next.streamingContent != null) _scrollToBottom();
    });

    final viewPadTop = MediaQuery.viewPaddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Conteúdo principal
          Column(
            children: [
              // Espaço reservado para o scrim superior (status bar + toolbar)
              SizedBox(height: viewPadTop + kToolbarHeight),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_chipJustTapped) return;
                    FocusScope.of(context).unfocus();
                    ref.read(navBarModeProvider.notifier).state =
                        NavBarMode.expanded;
                  },
                  child: hasMessages
                      ? _ChatListView(
                          messages: chatState.messages,
                          isLoading: chatState.isLoading,
                          streamingContent: chatState.streamingContent,
                          scrollController: _scrollController,
                          onChipTap: _handleChipTap,
                        )
                      : TutorEmptyState(onChipTap: _handleChipTap),
                ),
              ),
              ChatInputBar(
                controller: _inputController,
                onSend: _onSend,
                enabled:
                    !chatState.isLoading && chatState.streamingContent == null,
              ),
            ],
          ),
          // Gradiente de vidro no topo — substitui o AppBar
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LexTopScrim(),
          ),
          // Botão voltar mínimo — só no modo contexto (aberto desde o Manual)
          if (widget.topicContext != null)
            Positioned(
              top: viewPadTop,
              left: AppSpacing.xs,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/manual');
                  }
                },
              ),
            ),
          // Ícone de histórico — só no modo padrão (sem contexto de tópico)
          if (widget.topicContext == null)
            Positioned(
              top: viewPadTop,
              right: AppSpacing.xs,
              child: IconButton(
                icon: const Icon(
                  Icons.history_rounded,
                  color: AppColors.textSecondary,
                ),
                tooltip: 'Histórico',
                onPressed: () => context.push('/tutor/history'),
              ),
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
  });

  final List<TutorMessage> messages;
  final bool isLoading;
  final ScrollController scrollController;
  final ValueChanged<String> onChipTap;
  final String? streamingContent;

  @override
  Widget build(BuildContext context) {
    final lastAiIndex =
        messages.lastIndexWhere((m) => m.role == 'assistant');
    final isStreaming = streamingContent != null;

    return RepaintBoundary(
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
          final showChips = msg.role == 'assistant' &&
              index == lastAiIndex &&
              msg.continuationChips.isNotEmpty &&
              !isLoading &&
              !isStreaming;

          return Column(
            key: ValueKey(msg.id),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChatBubble(message: msg),
              if (showChips)
                ChipsRow(chips: msg.continuationChips, onTap: onChipTap),
            ],
          );
        },
      ),
    );
  }
}
