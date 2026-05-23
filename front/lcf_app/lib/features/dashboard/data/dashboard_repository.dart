import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'models/dashboard_models.dart';

part 'dashboard_repository.g.dart';

class DashboardRepository {
  const DashboardRepository(this._dio);
  final Dio _dio;

  Future<DashboardData> getHomeData() async {
    final resp = await _dio.get<Map<String, dynamic>>('/dashboard');
    return DashboardData.fromJson(resp.data!);
  }

  Future<List<RevisionCard>> getRevisionCards() async {
    final resp =
        await _dio.get<Map<String, dynamic>>('/dashboard/revision-cards');
    final cards = resp.data!['cards'] as List<dynamic>;
    return cards
        .map((e) => RevisionCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PerformanceData> getPerformance() async {
    final resp =
        await _dio.get<Map<String, dynamic>>('/dashboard/performance');
    return PerformanceData.fromJson(resp.data!);
  }
}

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  return DashboardRepository(ref.watch(dioProvider));
}
