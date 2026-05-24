import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'onboarding_repository.g.dart';

// ── Models ────────────────────────────────────────────────────────────────────

@JsonSerializable(createFactory: false)
class OnboardingRequest {
  const OnboardingRequest({
    required this.academicPhase,
    required this.dailyStudyMins,
  });

  final String academicPhase;
  final int dailyStudyMins;

  Map<String, dynamic> toJson() => _$OnboardingRequestToJson(this);
}

@JsonSerializable(createToJson: false)
class StudyPlan {
  const StudyPlan({
    required this.id,
    required this.durationDays,
    required this.dailyMins,
  });

  final String id;
  final int durationDays;
  final int dailyMins;

  factory StudyPlan.fromJson(Map<String, dynamic> json) =>
      _$StudyPlanFromJson(json);
}

@JsonSerializable(createToJson: false)
class OnboardingResponse {
  const OnboardingResponse({
    required this.done,
    required this.flow,
    required this.nivelamentoPendente,
    required this.nivelamentoPath,
    required this.studyPlan,
  });

  final bool done;
  final String flow;
  final bool nivelamentoPendente;
  final String nivelamentoPath;
  final StudyPlan studyPlan;

  factory OnboardingResponse.fromJson(Map<String, dynamic> json) =>
      _$OnboardingResponseFromJson(json);
}

// ── Repository ────────────────────────────────────────────────────────────────

class OnboardingRepository {
  const OnboardingRepository(this._dio);
  final Dio _dio;

  Future<OnboardingResponse> complete(OnboardingRequest body) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/onboarding/complete',
      data: body.toJson(),
    );
    return OnboardingResponse.fromJson(resp.data!);
  }

  Future<void> diagnosticComplete() {
    return _dio.post<void>('/onboarding/diagnostic/complete');
  }

  Future<void> diagnosticDismiss() {
    return _dio.post<void>('/onboarding/diagnostic/dismiss');
  }
}

@riverpod
OnboardingRepository onboardingRepository(OnboardingRepositoryRef ref) {
  return OnboardingRepository(ref.watch(dioProvider));
}
