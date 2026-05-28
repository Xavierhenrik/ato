import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'models/tutor_models.dart';

part 'tutor_repository.g.dart';

class TutorRepository {
  const TutorRepository(this._dio);
  final Dio _dio;

  Future<TutorSession> createSession() async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/tutor/session/new',
      data: <String, dynamic>{}, // explicit empty body — Fastify rejects Content-Type:json with no body
    );
    return TutorSession(id: resp.data!['session_id'] as String);
  }

  Future<SendMessageResponse> sendMessage(
    String sessionId,
    String content, {
    String mode = 'direct',
  }) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/tutor/message',
      data: {
        'session_id': sessionId,
        'message': content,
        'mode': mode,
      },
    );
    final data = resp.data!;

    // Backend returns 'reply' (REST contract) or 'message' (arch spec fallback)
    final replyText =
        (data['reply'] ?? data['message'] ?? '') as String;
    final rawChips = data['chips'] as List<dynamic>? ?? const <dynamic>[];
    final chips = rawChips.map((e) => e.toString()).toList();

    return SendMessageResponse(
      message: TutorMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        role: 'assistant',
        content: replyText,
        continuationChips: chips,
        createdAt: DateTime.now(),
      ),
      autoSavedAnnotationId: data['autoSavedAnnotationId'] as String?,
    );
  }

  Future<void> deleteSession(String sessionId) async {
    await _dio.delete<void>('/tutor/session/$sessionId');
  }
}

@riverpod
TutorRepository tutorRepository(TutorRepositoryRef ref) {
  return TutorRepository(ref.watch(dioProvider));
}
