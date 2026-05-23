import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/dashboard_repository.dart';
import '../data/models/dashboard_models.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<DashboardData> dashboardData(DashboardDataRef ref) {
  return ref.watch(dashboardRepositoryProvider).getHomeData();
}

@riverpod
Future<List<RevisionCard>> revisionCards(RevisionCardsRef ref) {
  return ref.watch(dashboardRepositoryProvider).getRevisionCards();
}

@riverpod
Future<PerformanceData> performance(PerformanceRef ref) {
  return ref.watch(dashboardRepositoryProvider).getPerformance();
}
