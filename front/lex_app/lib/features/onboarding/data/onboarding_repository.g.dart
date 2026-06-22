// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$OnboardingRequestToJson(OnboardingRequest instance) =>
    <String, dynamic>{
      'academicPhase': instance.academicPhase,
      'dailyStudyMins': instance.dailyStudyMins,
    };

StudyPlan _$StudyPlanFromJson(Map<String, dynamic> json) => StudyPlan(
      id: json['id'] as String,
      durationDays: (json['durationDays'] as num).toInt(),
      dailyMins: (json['dailyMins'] as num).toInt(),
    );

OnboardingResponse _$OnboardingResponseFromJson(Map<String, dynamic> json) =>
    OnboardingResponse(
      done: json['done'] as bool,
      flow: json['flow'] as String,
      nivelamentoPendente: json['nivelamentoPendente'] as bool,
      nivelamentoPath: json['nivelamentoPath'] as String,
      studyPlan: StudyPlan.fromJson(json['studyPlan'] as Map<String, dynamic>),
    );

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingRepositoryHash() =>
    r'10a5ffca0f9973d1fd18002c4c7ed14dcba8772a';

/// See also [onboardingRepository].
@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider =
    AutoDisposeProvider<OnboardingRepository>.internal(
  onboardingRepository,
  name: r'onboardingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OnboardingRepositoryRef = AutoDisposeProviderRef<OnboardingRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
