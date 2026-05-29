import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/tutor_models.dart';
import '../data/tutor_repository.dart';

part 'tutor_provider.g.dart';

class TutorChatState {
  const TutorChatState({
    this.messages = const [],
    this.isLoading = false,
    this.streamingContent,
    this.mode = 'direct',
    this.topicContext,
  });

  final List<TutorMessage> messages;
  final bool isLoading;
  // Non-null while fake-streaming an AI response character by character.
  final String? streamingContent;
  // Tutor mode: 'direct' | 'reading' | 'simulado'
  final String mode;
  // Populated when opened from the Manual (mode == 'reading').
  final TutorTopicContext? topicContext;

  TutorChatState copyWith({
    List<TutorMessage>? messages,
    bool? isLoading,
    String? streamingContent,
    bool clearStreamingContent = false,
    String? mode,
    TutorTopicContext? topicContext,
  }) =>
      TutorChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        streamingContent: clearStreamingContent
            ? null
            : (streamingContent ?? this.streamingContent),
        mode: mode ?? this.mode,
        topicContext: topicContext ?? this.topicContext,
      );
}

@riverpod
class TutorNotifier extends _$TutorNotifier {
  String? _sessionId;
  Timer? _streamingTimer;

  @override
  TutorChatState build() {
    ref.onDispose(() => _streamingTimer?.cancel());
    return const TutorChatState();
  }

  /// Inicializa o contexto da sessão antes da primeira mensagem.
  /// Chamado pelo TutorScreen quando aberto com topicContext (modo 'reading').
  void initWithContext({
    required String mode,
    TutorTopicContext? topicContext,
  }) {
    state = state.copyWith(mode: mode, topicContext: topicContext);
  }

  /// Sends a message and returns autoSavedAnnotationId if present (PRO only).
  /// Throws DioException on HTTP errors — screen handles 429, 401, 5xx.
  Future<String?> sendMessage(String content) async {
    final userMsg = TutorMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );

    // Optimistic insert + show typing indicator
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      // Lazy session creation on first message
      _sessionId ??=
          (await ref.read(tutorRepositoryProvider).createSession()).id;

      final response = await ref
          .read(tutorRepositoryProvider)
          .sendMessage(
            _sessionId!,
            content,
            mode: state.mode,
            topicContext: state.topicContext,
          );

      _startStreaming(response);

      return response.autoSavedAnnotationId;
    } catch (_) {
      // Revert optimistic insert and hide typing indicator
      state = state.copyWith(
        messages: state.messages.where((m) => m.id != userMsg.id).toList(),
        isLoading: false,
      );
      rethrow;
    }
  }

  // Reveals the AI response progressively, character by character.
  // Faster for long responses so the UX doesn't feel slow.
  void _startStreaming(SendMessageResponse response) {
    final fullText = response.message.content;

    if (fullText.isEmpty) {
      state = TutorChatState(
        messages: [...state.messages, response.message],
        mode: state.mode,
        topicContext: state.topicContext,
      );
      return;
    }

    final intervalMs = fullText.length > 300 ? 8 : 12;
    var revealedCount = 1;

    // Show first character immediately — avoids an empty-bubble flash.
    state = state.copyWith(
      isLoading: false,
      streamingContent: fullText.substring(0, 1),
    );

    _streamingTimer?.cancel();
    _streamingTimer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (timer) {
        revealedCount++;
        if (revealedCount >= fullText.length) {
          timer.cancel();
          _streamingTimer = null;
          // Replace streaming bubble with the final, persisted message.
          state = TutorChatState(
            messages: [...state.messages, response.message],
            mode: state.mode,
            topicContext: state.topicContext,
          );
        } else {
          state = state.copyWith(
            streamingContent: fullText.substring(0, revealedCount),
          );
        }
      },
    );
  }

  /// Clears messages and fires DELETE /tutor/session/:id (fire-and-forget).
  Future<void> endSession() async {
    _streamingTimer?.cancel();
    _streamingTimer = null;
    final sid = _sessionId;
    final mode = state.mode;
    _sessionId = null;
    state = const TutorChatState();
    if (sid == null) return;

    // Capture repo reference before any await to avoid ref access after dispose
    final repo = ref.read(tutorRepositoryProvider);
    try {
      await repo.deleteSession(sid, mode: mode);
    } catch (_) {
      // Cleanup errors are non-critical
    }
  }
}
