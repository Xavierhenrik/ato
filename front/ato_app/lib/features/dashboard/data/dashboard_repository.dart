import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/cache/isar_schemas.dart';
import '../../../core/cache/isar_service.dart';
import '../../../core/network/api_client.dart';
import 'models/dashboard_models.dart';

part 'dashboard_repository.g.dart';

const _dashboardTtl = Duration(hours: 1);

bool _isCacheExpired(DateTime cachedAt) =>
    DateTime.now().difference(cachedAt) > _dashboardTtl;

class DashboardRepository {
  DashboardRepository(this._dio, this._isar);
  final Dio _dio;
  final Isar _isar;

  // Guard global: evita empilhar refreshes em background quando o usuário
  // troca de aba rapidamente (cada troca destrói e recria os providers).
  static bool _isRefreshing = false;

  Future<DashboardData> getHomeData() async {
    final cached = await _isar.cachedDashboards.get(1);
    if (cached != null &&
        cached.homeDataJson.isNotEmpty &&
        !_isCacheExpired(cached.cachedAt)) {
      unawaited(_refreshAllInBackground());
      return DashboardData.fromJson(
          jsonDecode(cached.homeDataJson) as Map<String, dynamic>);
    }
    try {
      final data = await _doFetchHomeData();
      await _patchCache(homeDataJson: jsonEncode(data.toJson()));
      return data;
    } on DioException catch (_) {
      if (cached != null && cached.homeDataJson.isNotEmpty) {
        return DashboardData.fromJson(
            jsonDecode(cached.homeDataJson) as Map<String, dynamic>);
      }
      rethrow;
    }
  }

  Future<List<RevisionCard>> getRevisionCards() async {
    final cached = await _isar.cachedDashboards.get(1);
    if (cached != null &&
        cached.revisionCardsJson.isNotEmpty &&
        !_isCacheExpired(cached.cachedAt)) {
      // Background refresh é disparado apenas por getHomeData para evitar
      // 3 refreshes concorrentes (todos lêem o mesmo registro Isar).
      final list = jsonDecode(cached.revisionCardsJson) as List<dynamic>;
      return list
          .map((e) => RevisionCard.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    try {
      final cards = await _doFetchRevisionCards();
      await _patchCache(
          revisionCardsJson:
              jsonEncode(cards.map((e) => e.toJson()).toList()));
      return cards;
    } on DioException catch (_) {
      if (cached != null && cached.revisionCardsJson.isNotEmpty) {
        final list = jsonDecode(cached.revisionCardsJson) as List<dynamic>;
        return list
            .map((e) => RevisionCard.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<PerformanceData> getPerformance() async {
    final cached = await _isar.cachedDashboards.get(1);
    if (cached != null &&
        cached.performanceJson.isNotEmpty &&
        !_isCacheExpired(cached.cachedAt)) {
      // Background refresh é disparado apenas por getHomeData.
      return PerformanceData.fromJson(
          jsonDecode(cached.performanceJson) as Map<String, dynamic>);
    }
    try {
      final data = await _doFetchPerformance();
      await _patchCache(performanceJson: jsonEncode(data.toJson()));
      return data;
    } on DioException catch (_) {
      if (cached != null && cached.performanceJson.isNotEmpty) {
        return PerformanceData.fromJson(
            jsonDecode(cached.performanceJson) as Map<String, dynamic>);
      }
      rethrow;
    }
  }

  Future<void> invalidateCache() async {
    await _isar.writeTxn(() => _isar.cachedDashboards.delete(1));
  }

  // ── private helpers ──────────────────────────────────────────────────

  Future<void> _refreshAllInBackground() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      final homeDataFuture = _doFetchHomeData();
      final cardsFuture = _doFetchRevisionCards();
      final perfFuture = _doFetchPerformance();
      final homeData = await homeDataFuture;
      final cards = await cardsFuture;
      final perf = await perfFuture;
      final record = CachedDashboard()
        ..id = 1
        ..homeDataJson = jsonEncode(homeData.toJson())
        ..revisionCardsJson =
            jsonEncode(cards.map((e) => e.toJson()).toList())
        ..performanceJson = jsonEncode(perf.toJson())
        ..cachedAt = DateTime.now();
      await _isar.writeTxn(() => _isar.cachedDashboards.put(record));
    } catch (_) {
      // fire-and-forget — falha não bloqueia o usuário
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _patchCache({
    String? homeDataJson,
    String? revisionCardsJson,
    String? performanceJson,
  }) async {
    final existing = await _isar.cachedDashboards.get(1);
    final record = existing ?? CachedDashboard()..id = 1;
    if (homeDataJson != null) record.homeDataJson = homeDataJson;
    if (revisionCardsJson != null) record.revisionCardsJson = revisionCardsJson;
    if (performanceJson != null) record.performanceJson = performanceJson;
    record.cachedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.cachedDashboards.put(record));
  }

  Future<DashboardData> _doFetchHomeData() async {
    final resp = await _dio.get<Map<String, dynamic>>('/dashboard');
    return DashboardData.fromJson(resp.data!);
  }

  Future<List<RevisionCard>> _doFetchRevisionCards() async {
    final resp =
        await _dio.get<Map<String, dynamic>>('/dashboard/revision-cards');
    final cards = resp.data!['cards'] as List<dynamic>;
    return cards
        .map((e) => RevisionCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PerformanceData> _doFetchPerformance() async {
    final resp =
        await _dio.get<Map<String, dynamic>>('/dashboard/performance');
    return PerformanceData.fromJson(resp.data!);
  }
}

@riverpod
Future<DashboardRepository> dashboardRepository(
    DashboardRepositoryRef ref) async {
  final isar = await ref.watch(isarServiceProvider.future);
  return DashboardRepository(ref.watch(dioProvider), isar);
}
