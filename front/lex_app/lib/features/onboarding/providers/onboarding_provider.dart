import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/auth/providers/auth_provider.dart';
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
      // Persiste no metadata Supabase (para guard no router após restart)
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'onboarding_done': true}),
        );
      } catch (e) { debugPrint('[Onboarding] Erro: $e'); }
      // Marca na sessão atual (garante que o guard funciona mesmo se updateUser falhar)
      ref.read(onboardingDoneProvider.notifier).markDone();
      state = state.copyWith(isLoading: false, result: response);
      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return null;
    }
  }
}

// ── Diagnóstico — step ────────────────────────────────────────────────────────

enum DiagnosticoStep { intro, answering, done }

@riverpod
class DiagnosticoNotifier extends _$DiagnosticoNotifier {
  @override
  DiagnosticoStep build() => DiagnosticoStep.intro;

  void startAnswering() => state = DiagnosticoStep.answering;

  Future<void> complete() async {
    try {
      await ref.read(onboardingRepositoryProvider).diagnosticComplete();
    } catch (e) { debugPrint('[Onboarding] Erro: $e'); }
    state = DiagnosticoStep.done;
  }

  Future<void> dismiss() async {
    await ref.read(onboardingRepositoryProvider).diagnosticDismiss();
  }
}

// ── Diagnóstico — estado do quiz ──────────────────────────────────────────────

class DiagnosticoQuizState {
  const DiagnosticoQuizState({
    this.isLoading = true,
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswer,
    this.error,
  });

  final bool isLoading;
  final List<DiagnosticoQuestion> questions;
  final int currentIndex;
  final String? selectedAnswer;
  final Object? error;

  bool get canAdvance => selectedAnswer != null;
  bool get isLastQuestion =>
      questions.isNotEmpty && currentIndex >= questions.length - 1;
  DiagnosticoQuestion? get currentQuestion =>
      questions.isEmpty ? null : questions[currentIndex];
}

@riverpod
class DiagnosticoQuizNotifier extends _$DiagnosticoQuizNotifier {
  @override
  DiagnosticoQuizState build() => const DiagnosticoQuizState();

  Future<void> loadQuestions() async {
    state = const DiagnosticoQuizState();
    try {
      final response = await ref
          .read(onboardingRepositoryProvider)
          .getDiagnosticQuestions();
      state = DiagnosticoQuizState(
        isLoading: false,
        questions: response.questions,
      );
    } catch (e) {
      state = DiagnosticoQuizState(isLoading: false, error: e);
    }
  }

  void selectAnswer(String answer) {
    state = DiagnosticoQuizState(
      isLoading: false,
      questions: state.questions,
      currentIndex: state.currentIndex,
      selectedAnswer: answer,
    );
  }

  Future<void> advance() async {
    if (state.isLastQuestion) {
      await ref.read(diagnosticoNotifierProvider.notifier).complete();
    } else {
      state = DiagnosticoQuizState(
        isLoading: false,
        questions: state.questions,
        currentIndex: state.currentIndex + 1,
      );
    }
  }
}
