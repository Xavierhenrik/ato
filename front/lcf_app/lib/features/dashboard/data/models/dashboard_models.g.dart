// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreakInfo _$StreakInfoFromJson(Map<String, dynamic> json) => StreakInfo(
      current: (json['current'] as num).toInt(),
      longest: (json['longest'] as num).toInt(),
    );

DailyProgress _$DailyProgressFromJson(Map<String, dynamic> json) =>
    DailyProgress(
      questionsAnsweredToday: (json['questionsAnsweredToday'] as num).toInt(),
      topicsReadToday: (json['topicsReadToday'] as num).toInt(),
      dailyGoalMins: (json['dailyGoalMins'] as num).toInt(),
    );

DashboardData _$DashboardDataFromJson(Map<String, dynamic> json) =>
    DashboardData(
      name: json['name'] as String,
      plan: json['plan'] as String,
      oabMode: json['oabMode'] as bool,
      nivelamentoPendente: json['nivelamentoPendente'] as bool,
      streak: StreakInfo.fromJson(json['streak'] as Map<String, dynamic>),
      dailyProgress:
          DailyProgress.fromJson(json['dailyProgress'] as Map<String, dynamic>),
    );

RevisionCard _$RevisionCardFromJson(Map<String, dynamic> json) => RevisionCard(
      subject: json['subject'] as String,
      lawCode: json['lawCode'] as String,
      errorRate: (json['errorRate'] as num).toDouble(),
      totalAnswered: (json['totalAnswered'] as num).toInt(),
      priority: json['priority'] as String,
    );

SubjectPerformance _$SubjectPerformanceFromJson(Map<String, dynamic> json) =>
    SubjectPerformance(
      subject: json['subject'] as String,
      answered: (json['answered'] as num).toInt(),
      correct: (json['correct'] as num).toInt(),
      accuracyRate: (json['accuracyRate'] as num).toDouble(),
    );

PerformanceData _$PerformanceDataFromJson(Map<String, dynamic> json) =>
    PerformanceData(
      totalAnswered: (json['totalAnswered'] as num).toInt(),
      globalAccuracyRate: (json['globalAccuracyRate'] as num).toDouble(),
      oabBaseline: (json['oabBaseline'] as num).toDouble(),
      bySubject: (json['bySubject'] as List<dynamic>)
          .map((e) => SubjectPerformance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
