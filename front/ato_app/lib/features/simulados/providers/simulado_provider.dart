import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/simulado_models.dart';
import '../data/simulado_repository.dart';

part 'simulado_provider.g.dart';

@riverpod
Future<List<SimuladoHistoryItem>> simuladoHistory(SimuladoHistoryRef ref) =>
    ref.watch(simuladoRepositoryProvider).getHistory();

@riverpod
Future<SimuladoResult> simuladoResult(
  SimuladoResultRef ref,
  String simuladoId,
) =>
    ref.watch(simuladoRepositoryProvider).getResults(simuladoId);

/// User plan for gating UI. Falls back to 'free' on error.
@riverpod
Future<String> simuladoUserPlan(SimuladoUserPlanRef ref) async {
  try {
    return await ref.watch(simuladoRepositoryProvider).getUserPlan();
  } catch (_) {
    return 'free';
  }
}
