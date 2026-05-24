enum SimuladoMode {
  oabPhase1,
  oabPhase2,
  custom,
  weakAreas;

  String get apiValue => switch (this) {
        SimuladoMode.oabPhase1 => 'oab_phase1',
        SimuladoMode.oabPhase2 => 'oab_phase2',
        SimuladoMode.custom => 'custom',
        SimuladoMode.weakAreas => 'weak_areas',
      };

  String get label => switch (this) {
        SimuladoMode.oabPhase1 => 'OAB Fase 1',
        SimuladoMode.oabPhase2 => 'OAB Fase 2',
        SimuladoMode.custom => 'Por matéria',
        SimuladoMode.weakAreas => 'Pontos fracos',
      };
}

class Question {
  const Question({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    this.subject,
    this.lawCode,
    this.year,
  });

  final String id;
  final String enunciado;
  final Map<String, String> opcoes;
  final String? subject;
  final String? lawCode;
  final int? year;

  factory Question.fromJson(Map<String, dynamic> json) {
    final raw = json['opcoes'] as Map<String, dynamic>? ?? {};
    return Question(
      id: json['id'] as String? ?? '',
      enunciado: json['enunciado'] as String? ??
          json['statement'] as String? ??
          '',
      opcoes: raw.map((k, v) => MapEntry(k, v.toString())),
      subject: json['subject'] as String?,
      lawCode: json['lawCode'] as String?,
      year: json['year'] as int?,
    );
  }
}

class SimuladoAttempt {
  const SimuladoAttempt({
    required this.id,
    required this.totalQuestions,
    required this.questions,
  });

  final String id;
  final int totalQuestions;
  final List<Question> questions;

  factory SimuladoAttempt.fromJson(Map<String, dynamic> json) {
    final raw = json['questions'] as List<dynamic>? ?? [];
    final questions =
        raw.map((q) => Question.fromJson(q as Map<String, dynamic>)).toList();
    return SimuladoAttempt(
      id: json['id'] as String? ?? '',
      totalQuestions:
          json['totalQuestions'] as int? ?? questions.length,
      questions: questions,
    );
  }
}

class AnswerResult {
  const AnswerResult({
    required this.correct,
    required this.correctAnswer,
    this.explanation,
  });

  final bool correct;
  final String correctAnswer;
  final String? explanation;

  factory AnswerResult.fromJson(Map<String, dynamic> json) => AnswerResult(
        correct: json['correct'] as bool? ?? false,
        correctAnswer: (json['correctAnswer'] ?? json['correct_answer'] ?? '') as String,
        explanation: json['explanation'] as String?,
      );
}

class QuestionReview {
  const QuestionReview({
    required this.questionId,
    required this.enunciado,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    this.subject,
    this.explanation,
  });

  final String questionId;
  final String enunciado;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String? subject;
  final String? explanation;

  factory QuestionReview.fromJson(Map<String, dynamic> json) => QuestionReview(
        questionId:
            json['questionId'] as String? ?? json['id'] as String? ?? '',
        enunciado: json['enunciado'] as String? ??
            json['statement'] as String? ??
            '',
        userAnswer: json['userAnswer'] as String? ?? '',
        correctAnswer: json['correctAnswer'] as String? ?? '',
        isCorrect: json['isCorrect'] as bool? ?? false,
        subject: json['subject'] as String?,
        explanation: json['explanation'] as String?,
      );
}

class SimuladoResult {
  const SimuladoResult({
    required this.id,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.score,
    required this.bySubject,
    required this.questions,
  });

  final String id;
  final int total;
  final int correct;
  final int wrong;
  final double score;
  final Map<String, double> bySubject;
  final List<QuestionReview> questions;

  factory SimuladoResult.fromJson(Map<String, dynamic> json) {
    final rawBy = json['bySubject'] as Map<String, dynamic>? ?? {};
    final rawQ = json['questions'] as List<dynamic>? ?? [];
    final total = json['total'] as int? ?? 0;
    final correct = json['correct'] as int? ?? 0;
    return SimuladoResult(
      id: json['id'] as String? ?? '',
      total: total,
      correct: correct,
      wrong: json['wrong'] as int? ?? (total - correct),
      // Score is percentage (0-100) per API contract.
      // Fallback computes locally if backend omits it.
      score: (json['score'] as num?)?.toDouble() ??
          (total > 0 ? (correct / total) * 100 : 0.0),
      // bySubject values are accuracy percentages (0-100) per API contract.
      bySubject: rawBy.map((k, v) => MapEntry(k, (v as num).toDouble())),
      questions: rawQ
          .map((q) => QuestionReview.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SimuladoHistoryItem {
  const SimuladoHistoryItem({
    required this.id,
    required this.mode,
    required this.totalQuestions,
    required this.score,
    this.completedAt,
    this.subject,
  });

  final String id;
  final String mode;
  final int totalQuestions;
  final double score;
  final DateTime? completedAt;
  final String? subject;

  factory SimuladoHistoryItem.fromJson(Map<String, dynamic> json) =>
      SimuladoHistoryItem(
        id: json['id'] as String? ?? '',
        mode: json['mode'] as String? ?? 'custom',
        totalQuestions: json['totalQuestions'] as int? ?? 0,
        score: (json['score'] as num?)?.toDouble() ?? 0.0,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        subject: json['subject'] as String?,
      );
}
