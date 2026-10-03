/// Contexto de leitura de tópico do Manual — injetado no system prompt do Tutor.
class TutorTopicContext {
  const TutorTopicContext({
    required this.topicTitle,
    required this.topicContent,
    this.topicId,
  });

  final String topicTitle;
  final String topicContent;
  /// ID do tópico no backend — necessário para que o histórico do Manual
  /// mostre o badge com o nome do tópico (batch lookup por topicId).
  final String? topicId;

  Map<String, dynamic> toJson() => {
        'topic_title': topicTitle,
        'topic_content': topicContent,
        if (topicId != null) 'topic_id': topicId,
      };
}

/// Args para navegação via /tutor/context (pushed desde o Manual).
class TutorScreenArgs {
  const TutorScreenArgs({
    this.initialMessage,
    this.topicContext,
  });

  final String? initialMessage;
  final TutorTopicContext? topicContext;
}

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
