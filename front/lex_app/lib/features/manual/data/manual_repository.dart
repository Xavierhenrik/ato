import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cache/isar_schemas.dart';
import '../../../core/cache/isar_service.dart';
import '../../../core/network/api_client.dart';
import 'models/manual_models.dart';

part 'manual_repository.g.dart';

const _topicListTtl = Duration(hours: 24);

bool _isTopicCacheExpired(DateTime cachedAt) =>
    DateTime.now().difference(cachedAt) > _topicListTtl;

class ManualRepository {
  ManualRepository(this._dio, this._isar);
  final Dio _dio;
  final Isar _isar;

  // Guard global: evita empilhar writes Isar concorrentes quando o usuário
  // navega rapidamente entre filtros de matéria ou troca de aba.
  static bool _isRefreshing = false;

  Future<List<Topic>> getTopics({String? lawCode}) async {
    final cacheKey = 'topics_${lawCode ?? 'all'}';
    final cached = await _isar.cachedTopicLists
        .where()
        .cacheKeyEqualTo(cacheKey)
        .findFirst();

    if (cached != null && !_isTopicCacheExpired(cached.cachedAt)) {
      unawaited(_refreshTopicsInBackground(lawCode: lawCode, cacheKey: cacheKey));
      final list = jsonDecode(cached.topicsJson) as List<dynamic>;
      return list
          .map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    try {
      final topics = await _doFetchTopics(lawCode: lawCode);
      await _saveTopicsCache(cacheKey: cacheKey, topics: topics);
      return topics;
    } on DioException catch (_) {
      if (cached != null) {
        final list = jsonDecode(cached.topicsJson) as List<dynamic>;
        return list
            .map((e) => Topic.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<void> invalidateCache({String? lawCode}) async {
    await _isar.writeTxn(() async {
      if (lawCode != null) {
        await _isar.cachedTopicLists
            .where()
            .cacheKeyEqualTo('topics_$lawCode')
            .deleteAll();
      } else {
        await _isar.cachedTopicLists.clear();
      }
    });
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

  // ── private helpers ──────────────────────────────────────────────────

  Future<void> _refreshTopicsInBackground({
    String? lawCode,
    required String cacheKey,
  }) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      final topics = await _doFetchTopics(lawCode: lawCode);
      await _saveTopicsCache(cacheKey: cacheKey, topics: topics);
    } catch (_) {
      // fire-and-forget — falha não bloqueia o usuário
    } finally {
      _isRefreshing = false;
    }
  }

  Future<List<Topic>> _doFetchTopics({String? lawCode}) async {
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

  Future<void> _saveTopicsCache({
    required String cacheKey,
    required List<Topic> topics,
  }) async {
    final existing = await _isar.cachedTopicLists
        .where()
        .cacheKeyEqualTo(cacheKey)
        .findFirst();
    final record = existing ?? (CachedTopicList()..cacheKey = cacheKey);
    record.topicsJson = jsonEncode(topics.map((e) => e.toJson()).toList());
    record.cachedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.cachedTopicLists.put(record));
  }
}

@riverpod
Future<ManualRepository> manualRepository(ManualRepositoryRef ref) async {
  final isar = await ref.watch(isarServiceProvider.future);
  return ManualRepository(ref.watch(dioProvider), isar);
}
