import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/manual_repository.dart';
import '../data/models/manual_models.dart';

part 'manual_provider.g.dart';

@riverpod
Future<List<Topic>> manualTopics(
  ManualTopicsRef ref, {
  String? lawCode,
}) async {
  final repo = await ref.watch(manualRepositoryProvider.future);
  return repo.getTopics(lawCode: lawCode);
}

@riverpod
Future<TopicDetail> manualTopicDetail(
  ManualTopicDetailRef ref,
  String id,
) async {
  final repo = await ref.watch(manualRepositoryProvider.future);
  return repo.getTopicDetail(id);
}

@riverpod
Future<List<ManualSearchResult>> manualSearch(
  ManualSearchRef ref,
  String q,
) async {
  if (q.trim().isEmpty) return const [];
  final repo = await ref.watch(manualRepositoryProvider.future);
  return repo.searchTopics(q);
}

@riverpod
class SelectedLawCode extends _$SelectedLawCode {
  @override
  String? build() => null;

  void select(String? code) => state = code;
}

@riverpod
Future<List<Topic>> filteredTopics(FilteredTopicsRef ref) async {
  final code = ref.watch(selectedLawCodeProvider);
  return ref.watch(manualTopicsProvider(lawCode: code).future);
}
