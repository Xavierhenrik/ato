import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'models/manual_models.dart';

part 'manual_repository.g.dart';

class ManualRepository {
  const ManualRepository(this._dio);
  final Dio _dio;

  Future<List<Topic>> getTopics({String? lawCode}) async {
    final resp = await _dio.get<dynamic>(
      '/manual/topics',
      queryParameters: lawCode != null ? {'lawCode': lawCode} : null,
    );
    final data = resp.data;
    final List<dynamic> list;
    if (data is Map<String, dynamic>) {
      list = (data['topics'] ?? data['data'] ?? data['items'] ?? const [])
          as List<dynamic>;
    } else {
      list = (data as List<dynamic>?) ?? const [];
    }
    return list
        .map((e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TopicDetail> getTopicDetail(String id) async {
    final resp = await _dio.get<Map<String, dynamic>>('/manual/topics/$id');
    return TopicDetail.fromJson(resp.data!);
  }

  Future<void> markAsRead(String id) async {
    await _dio.post<void>('/manual/topics/$id/read');
  }

  Future<List<ManualSearchResult>> searchTopics(String q) async {
    final resp = await _dio.get<dynamic>(
      '/manual/search',
      queryParameters: {'q': q},
    );
    final data = resp.data;
    final List<dynamic> list;
    if (data is Map<String, dynamic>) {
      list = (data['results'] ?? data['data'] ?? data['items'] ?? const [])
          as List<dynamic>;
    } else {
      list = (data as List<dynamic>?) ?? const [];
    }
    return list
        .map((e) => ManualSearchResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

@riverpod
ManualRepository manualRepository(ManualRepositoryRef ref) {
  return ManualRepository(ref.watch(dioProvider));
}
