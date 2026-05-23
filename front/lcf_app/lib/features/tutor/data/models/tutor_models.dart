class TutorMessage {
  const TutorMessage({
    required this.id,
    required this.role,
    required this.content,
    this.continuationChips = const [],
    required this.createdAt,
  });

  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final List<String> continuationChips; // populated for role == 'assistant'
  final DateTime createdAt;
}

class TutorSession {
  const TutorSession({required this.id});
  final String id;
}

class SendMessageResponse {
  const SendMessageResponse({
    required this.message,
    this.autoSavedAnnotationId,
  });

  final TutorMessage message;
  final String? autoSavedAnnotationId; // PRO only — triggers auto-save snackbar
}
