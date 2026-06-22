import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/anotacao_repository.dart';
import '../data/models/anotacao_models.dart';

part 'anotacao_provider.g.dart';

@riverpod
Future<List<Anotacao>> anotacoes(
  AnotacoesRef ref, {
  String? subject,
  String? q,
}) async {
  return ref.watch(anotacaoRepositoryProvider).getAnnotations(
        subject: subject,
        q: q,
      );
}

/// Currently selected subject for filter chips (null = "Todas").
@riverpod
class SelectedSubjectFilter extends _$SelectedSubjectFilter {
  @override
  String? build() => null;

  void select(String? subject) => state = subject;
}
