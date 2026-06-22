import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/dashboard_repository.dart';
import '../data/models/dashboard_models.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<DashboardData> dashboardData(DashboardDataRef ref) async {
  final repo = await ref.watch(dashboardRepositoryProvider.future);
  return repo.getHomeData();
}

@riverpod
Future<List<RevisionCard>> revisionCards(RevisionCardsRef ref) async {
  final repo = await ref.watch(dashboardRepositoryProvider.future);
  return repo.getRevisionCards();
}

@riverpod
Future<PerformanceData> performance(PerformanceRef ref) async {
  final repo = await ref.watch(dashboardRepositoryProvider.future);
  return repo.getPerformance();
}
