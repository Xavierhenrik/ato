// Models para o histórico permanente de conversas do Tutor IA.
// Seguem o mesmo padrão de serialização de tutor_models.dart:
// fromJson manual, tolerante a campos opcionais ausentes (backend antigo).

class HistorySession {
  const HistorySession({
    required this.id,
    required this.mode,
    required this.title,
    required this.createdAt,
    required this.msgCount,
    this.topicId,
    this.topicTitle,
  });

  final String id;
  final String mode; // 'direct' | 'reading'
  final String title;
  final DateTime createdAt;
  final int msgCount;
  final String? topicId;
  final String? topicTitle;

  factory HistorySession.fromJson(Map<String, dynamic> json) {
    return HistorySession(
      id: json['id'] as String,
      mode: json['mode'] as String? ?? 'direct',
      title: json['title'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      msgCount: (json['msgCount'] as num?)?.toInt() ?? 0,
      topicId: json['topicId'] as String?,
      topicTitle: json['topicTitle'] as String?,
    );
  }
}

class HistoryListResponse {
  const HistoryListResponse({
    required this.sessions,
    required this.retention,
    this.nextCursor,
  });

  final List<HistorySession> sessions;
  /// 'all' para PRO, '7d' para Free.
  final String retention;
  final String? nextCursor;

  factory HistoryListResponse.fromJson(Map<String, dynamic> json) {
    final rawSessions = json['sessions'] as List<dynamic>? ?? const [];
    return HistoryListResponse(
      sessions: rawSessions
          .map((e) => HistorySession.fromJson(e as Map<String, dynamic>))
          .toList(),
      retention: json['retention'] as String? ?? 'all',
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

class HistoryMessage {
  const HistoryMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.sources,
  });

  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime createdAt;
  final List<dynamic>? sources;

  factory HistoryMessage.fromJson(Map<String, dynamic> json) {
    return HistoryMessage(
      id: json['id'] as String,
      role: json['role'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      sources: json['sources'] as List<dynamic>?,
    );
  }
}

class HistoryDetailResponse {
  const HistoryDetailResponse({
    required this.session,
    required this.messages,
  });

  final HistorySession session;
  final List<HistoryMessage> messages;

  factory HistoryDetailResponse.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? const [];
    return HistoryDetailResponse(
      session:
          HistorySession.fromJson(json['session'] as Map<String, dynamic>),
      messages: rawMessages
          .map((e) => HistoryMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
