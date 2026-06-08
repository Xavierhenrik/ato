import 'package:json_annotation/json_annotation.dart';

part 'dashboard_models.g.dart';

@JsonSerializable()
class StreakInfo {
  const StreakInfo({required this.current, required this.longest});
  final int current;
  final int longest;
  factory StreakInfo.fromJson(Map<String, dynamic> json) =>
      _$StreakInfoFromJson(json);
  Map<String, dynamic> toJson() => _$StreakInfoToJson(this);
}

@JsonSerializable()
class DailyProgress {
  const DailyProgress({
    required this.questionsAnsweredToday,
    required this.topicsReadToday,
    required this.dailyGoalMins,
  });
  final int questionsAnsweredToday;
  final int topicsReadToday;
  final int dailyGoalMins;
  factory DailyProgress.fromJson(Map<String, dynamic> json) =>
      _$DailyProgressFromJson(json);
  Map<String, dynamic> toJson() => _$DailyProgressToJson(this);
}

@JsonSerializable()
class DashboardData {
  const DashboardData({
    required this.name,
    required this.plan,
    required this.oabMode,
    required this.nivelamentoPendente,
    required this.streak,
    required this.dailyProgress,
  });
  final String name;
  final String plan;
  final bool oabMode;
  final bool nivelamentoPendente;
  final StreakInfo streak;
  final DailyProgress dailyProgress;
  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardDataToJson(this);
}

@JsonSerializable()
class RevisionCard {
  const RevisionCard({
    required this.subject,
    required this.lawCode,
    required this.errorRate,
    required this.totalAnswered,
    required this.priority,
  });
  final String subject;
  final String lawCode;
  final double errorRate;
  final int totalAnswered;
  final String priority;
  factory RevisionCard.fromJson(Map<String, dynamic> json) =>
      _$RevisionCardFromJson(json);
  Map<String, dynamic> toJson() => _$RevisionCardToJson(this);
}

@JsonSerializable()
class SubjectPerformance {
  const SubjectPerformance({
    required this.subject,
    required this.answered,
    required this.correct,
    required this.accuracyRate,
  });
  final String subject;
  final int answered;
  final int correct;
  final double accuracyRate;
  factory SubjectPerformance.fromJson(Map<String, dynamic> json) =>
      _$SubjectPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectPerformanceToJson(this);
}

@JsonSerializable()
class PerformanceData {
  const PerformanceData({
    required this.totalAnswered,
    required this.globalAccuracyRate,
    required this.oabBaseline,
    required this.bySubject,
  });
  final int totalAnswered;
  final double globalAccuracyRate;
  final double oabBaseline;
  final List<SubjectPerformance> bySubject;
  factory PerformanceData.fromJson(Map<String, dynamic> json) =>
      _$PerformanceDataFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceDataToJson(this);
}
