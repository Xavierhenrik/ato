import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'onboarding_repository.g.dart';

// ── Models ────────────────────────────────────────────────────────────────────

@JsonSerializable()
class OnboardingRequest {
  const OnboardingRequest({
    required this.academicPhase,
    required this.dailyStudyMins,
  });

  final String academicPhase;
  final int dailyStudyMins;

  Map<String, dynamic> toJson() => _$OnboardingRequestToJson(this);
}

@JsonSerializable()
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

@JsonSerializable()
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

@RestApi()
abstract class OnboardingRepository {
  factory OnboardingRepository(Dio dio, {String? baseUrl}) =
      _OnboardingRepository;

  @POST('/onboarding/complete')
  Future<OnboardingResponse> complete(@Body() OnboardingRequest body);

  @POST('/onboarding/diagnostic/complete')
  Future<void> diagnosticComplete();

  @POST('/onboarding/diagnostic/dismiss')
  Future<void> diagnosticDismiss();
}

@riverpod
OnboardingRepository onboardingRepository(OnboardingRepositoryRef ref) {
  return OnboardingRepository(ref.watch(dioProvider));
}
