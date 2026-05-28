import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'models/simulado_models.dart';

part 'simulado_repository.g.dart';

class SimuladoRepository {
  const SimuladoRepository(this._dio);
  final Dio _dio;

  Future<SimuladoAttempt> startSimulado({
    required String mode,
    required int totalQ,
    String? subject,
  }) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/simulados/start',
      data: {
        'mode': mode,
        'totalQ': totalQ,
        if (subject != null) 'subject': subject,
      },
    );
    return SimuladoAttempt.fromJson(resp.data!);
  }

  Future<SimuladoAttempt?> getInProgress() async {
    final resp = await _dio.get<dynamic>('/simulados/in-progress');
    if (resp.statusCode == 204 || resp.data == null) return null;
    return SimuladoAttempt.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<AnswerResult> answerQuestion({
    required String simuladoId,
    required String questionId,
    required String answer,
    int? timeSpentSecs,
  }) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/simulados/$simuladoId/answer',
      data: {
        'questionId': questionId,
        'answer': answer,
        if (timeSpentSecs != null) 'timeSpentSecs': timeSpentSecs,
      },
    );
    return AnswerResult.fromJson(resp.data!);
  }

  Future<void> completeSimulado(String simuladoId) async {
    await _dio.post<void>('/simulados/$simuladoId/complete');
  }

  Future<void> abandonSimulado(String simuladoId) async {
    await _dio.post<void>('/simulados/$simuladoId/abandon');
  }

  Future<SimuladoResult> getResults(String simuladoId) async {
    final resp = await _dio.get<Map<String, dynamic>>(
      '/simulados/$simuladoId/results',
    );
    return SimuladoResult.fromJson(resp.data!);
  }

  Future<List<SimuladoHistoryItem>> getHistory() async {
    final resp = await _dio.get<dynamic>('/simulados/history');
    final raw = (resp.data as List<dynamic>?) ?? [];
    return raw
        .map((e) =>
            SimuladoHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> getUserPlan() async {
    final resp = await _dio
        .get<Map<String, dynamic>>('/subscriptions/status');
    return (resp.data!['plan'] as String?) ?? 'free';
  }
}

@riverpod
SimuladoRepository simuladoRepository(SimuladoRepositoryRef ref) =>
    SimuladoRepository(ref.watch(dioProvider));
