import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'models/anotacao_models.dart';

part 'anotacao_repository.g.dart';

class AnotacaoRepository {
  const AnotacaoRepository(this._dio);
  final Dio _dio;

  Future<List<Anotacao>> getAnnotations({
    String? subject,
    String? q,
    String? tag,
  }) async {
    final params = <String, dynamic>{};
    if (subject != null) params['subject'] = subject;
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (tag != null) params['tag'] = tag;

    final resp = await _dio.get<dynamic>(
      '/annotations',
      queryParameters: params.isEmpty ? null : params,
    );
    final data = resp.data;
    final List<dynamic> list;
    if (data is Map<String, dynamic>) {
      list =
          (data['annotations'] ?? data['data'] ?? data['items'] ?? const [])
              as List<dynamic>;
    } else {
      list = (data as List<dynamic>?) ?? const [];
    }
    return list
        .map((e) => Anotacao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Anotacao> createAnnotation({
    required String title,
    required String content,
    List<String>? tags,
    String? subject,
    String? topicId,
    String? lawCode,
    String? articleRef,
  }) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/annotations',
      data: {
        'title': title,
        'content': content,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
        if (subject != null) 'subject': subject,
        if (topicId != null) 'topicId': topicId,
        if (lawCode != null) 'lawCode': lawCode,
        if (articleRef != null) 'articleRef': articleRef,
      },
    );
    return Anotacao.fromJson(resp.data!);
  }

  Future<Anotacao> updateAnnotation({
    required String id,
    required String content,
    String? title,
    List<String>? tags,
    String? subject,
  }) async {
    final resp = await _dio.put<Map<String, dynamic>>(
      '/annotations/$id',
      data: {
        'content': content,
        if (title != null) 'title': title,
        if (tags != null) 'tags': tags,
        if (subject != null) 'subject': subject,
      },
    );
    return Anotacao.fromJson(resp.data!);
  }

  Future<void> deleteAnnotation(String id) async {
    await _dio.delete<void>('/annotations/$id');
  }
}

@riverpod
AnotacaoRepository anotacaoRepository(AnotacaoRepositoryRef ref) {
  return AnotacaoRepository(ref.watch(dioProvider));
}
