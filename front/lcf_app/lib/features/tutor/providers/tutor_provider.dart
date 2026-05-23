import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/tutor_models.dart';
import '../data/tutor_repository.dart';

part 'tutor_provider.g.dart';

class TutorChatState {
  const TutorChatState({
    this.messages = const [],
    this.isLoading = false,
  });

  final List<TutorMessage> messages;
  final bool isLoading;

  TutorChatState copyWith({
    List<TutorMessage>? messages,
    bool? isLoading,
  }) =>
      TutorChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
      );
}

@riverpod
class TutorNotifier extends _$TutorNotifier {
  String? _sessionId;

  @override
  TutorChatState build() => const TutorChatState();

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
          .sendMessage(_sessionId!, content);

      state = state.copyWith(
        messages: [...state.messages, response.message],
        isLoading: false,
      );

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

  /// Clears messages and fires DELETE /tutor/session/:id (fire-and-forget).
  Future<void> endSession() async {
    final sid = _sessionId;
    _sessionId = null;
    state = const TutorChatState();
    if (sid == null) return;

    // Capture repo reference before any await to avoid ref access after dispose
    final repo = ref.read(tutorRepositoryProvider);
    try {
      await repo.deleteSession(sid);
    } catch (_) {
      // Cleanup errors are non-critical
    }
  }
}
