import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/onboarding_repository.dart';

part 'onboarding_provider.g.dart';

// ── Enums de seleção na UI ────────────────────────────────────────────────────

enum AcademicPhase {
  graduationStart('graduation_start', 'Início da faculdade'),
  graduationMid('graduation_mid', 'Meio da faculdade'),
  graduationEnd('graduation_end', 'Final da faculdade'),
  oabPrep('oab_prep', 'Estudando para OAB');

  const AcademicPhase(this.value, this.label);
  final String value;
  final String label;
}

enum DailyStudyMins {
  min30(30, '30 min'),
  min60(60, '1 hora'),
  min120(120, '2 horas'),
  min180(180, '3+ horas');

  const DailyStudyMins(this.value, this.label);
  final int value;
  final String label;
}

// ── Estado do formulário de onboarding ───────────────────────────────────────

class OnboardingState {
  const OnboardingState({
    this.selectedPhase,
    this.selectedMins,
    this.isLoading = false,
    this.error,
    this.result,
  });

  final AcademicPhase? selectedPhase;
  final DailyStudyMins? selectedMins;
  final bool isLoading;
  final Object? error;
  final OnboardingResponse? result;

  bool get canSubmit => selectedPhase != null && selectedMins != null;

  OnboardingState copyWith({
    AcademicPhase? selectedPhase,
    DailyStudyMins? selectedMins,
    bool? isLoading,
    Object? error,
    OnboardingResponse? result,
  }) {
    return OnboardingState(
      selectedPhase: selectedPhase ?? this.selectedPhase,
      selectedMins: selectedMins ?? this.selectedMins,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState();

  void selectPhase(AcademicPhase phase) {
    state = state.copyWith(selectedPhase: phase);
  }

  void selectMins(DailyStudyMins mins) {
    state = state.copyWith(selectedMins: mins);
  }

  Future<OnboardingResponse?> complete() async {
    if (!state.canSubmit) return null;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ref.read(onboardingRepositoryProvider).complete(
            OnboardingRequest(
              academicPhase: state.selectedPhase!.value,
              dailyStudyMins: state.selectedMins!.value,
            ),
          );
      state = state.copyWith(isLoading: false, result: response);
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return null;
    }
  }
}

// ── Diagnóstico ───────────────────────────────────────────────────────────────

enum DiagnosticoStep { intro, answering, done }

@riverpod
class DiagnosticoNotifier extends _$DiagnosticoNotifier {
  @override
  DiagnosticoStep build() => DiagnosticoStep.intro;

  void startAnswering() => state = DiagnosticoStep.answering;

  Future<void> complete() async {
    await ref.read(onboardingRepositoryProvider).diagnosticComplete();
    state = DiagnosticoStep.done;
  }

  Future<void> dismiss() async {
    await ref.read(onboardingRepositoryProvider).diagnosticDismiss();
  }
}
