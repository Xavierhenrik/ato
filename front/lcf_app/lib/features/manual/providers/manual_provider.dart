import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/manual_repository.dart';
import '../data/models/manual_models.dart';

part 'manual_provider.g.dart';

/// All topics, optionally filtered by lawCode (server-side).
@riverpod
Future<List<Topic>> manualTopics(
  ManualTopicsRef ref, {
  String? lawCode,
}) async {
  return ref.watch(manualRepositoryProvider).getTopics(lawCode: lawCode);
}

/// Full detail for a single topic.
@riverpod
Future<TopicDetail> manualTopicDetail(
  ManualTopicDetailRef ref,
  String id,
) async {
  return ref.watch(manualRepositoryProvider).getTopicDetail(id);
}

/// Full-text search results. Returns empty list if query is blank.
@riverpod
Future<List<ManualSearchResult>> manualSearch(
  ManualSearchRef ref,
  String q,
) async {
  if (q.trim().isEmpty) return const [];
  return ref.watch(manualRepositoryProvider).searchTopics(q);
}

/// Currently selected lawCode for filter chips (null = "Todos").
@riverpod
class SelectedLawCode extends _$SelectedLawCode {
  @override
  String? build() => null;

  void select(String? code) => state = code;
}

/// Topics filtered by the currently selected lawCode.
/// Automatically rebuilds when selectedLawCode changes.
@riverpod
Future<List<Topic>> filteredTopics(FilteredTopicsRef ref) async {
  final code = ref.watch(selectedLawCodeProvider);
  return ref.watch(manualTopicsProvider(lawCode: code).future);
}
