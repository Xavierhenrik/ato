// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreakInfo _$StreakInfoFromJson(Map<String, dynamic> json) => StreakInfo(
      current: (json['current'] as num).toInt(),
      longest: (json['longest'] as num).toInt(),
    );

Map<String, dynamic> _$StreakInfoToJson(StreakInfo instance) =>
    <String, dynamic>{
      'current': instance.current,
      'longest': instance.longest,
    };

DailyProgress _$DailyProgressFromJson(Map<String, dynamic> json) =>
    DailyProgress(
      questionsAnsweredToday: (json['questionsAnsweredToday'] as num).toInt(),
      topicsReadToday: (json['topicsReadToday'] as num).toInt(),
      dailyGoalMins: (json['dailyGoalMins'] as num).toInt(),
    );

Map<String, dynamic> _$DailyProgressToJson(DailyProgress instance) =>
    <String, dynamic>{
      'questionsAnsweredToday': instance.questionsAnsweredToday,
      'topicsReadToday': instance.topicsReadToday,
      'dailyGoalMins': instance.dailyGoalMins,
    };

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

Map<String, dynamic> _$DashboardDataToJson(DashboardData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'plan': instance.plan,
      'oabMode': instance.oabMode,
      'nivelamentoPendente': instance.nivelamentoPendente,
      'streak': instance.streak,
      'dailyProgress': instance.dailyProgress,
    };

RevisionCard _$RevisionCardFromJson(Map<String, dynamic> json) => RevisionCard(
      subject: json['subject'] as String,
      lawCode: json['lawCode'] as String,
      errorRate: (json['errorRate'] as num).toDouble(),
      totalAnswered: (json['totalAnswered'] as num).toInt(),
      priority: json['priority'] as String,
    );

Map<String, dynamic> _$RevisionCardToJson(RevisionCard instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'lawCode': instance.lawCode,
      'errorRate': instance.errorRate,
      'totalAnswered': instance.totalAnswered,
      'priority': instance.priority,
    };

SubjectPerformance _$SubjectPerformanceFromJson(Map<String, dynamic> json) =>
    SubjectPerformance(
      subject: json['subject'] as String,
      answered: (json['answered'] as num).toInt(),
      correct: (json['correct'] as num).toInt(),
      accuracyRate: (json['accuracyRate'] as num).toDouble(),
    );

Map<String, dynamic> _$SubjectPerformanceToJson(SubjectPerformance instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'answered': instance.answered,
      'correct': instance.correct,
      'accuracyRate': instance.accuracyRate,
    };

PerformanceData _$PerformanceDataFromJson(Map<String, dynamic> json) =>
    PerformanceData(
      totalAnswered: (json['totalAnswered'] as num).toInt(),
      globalAccuracyRate: (json['globalAccuracyRate'] as num).toDouble(),
      oabBaseline: (json['oabBaseline'] as num).toDouble(),
      bySubject: (json['bySubject'] as List<dynamic>)
          .map((e) => SubjectPerformance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PerformanceDataToJson(PerformanceData instance) =>
    <String, dynamic>{
      'totalAnswered': instance.totalAnswered,
      'globalAccuracyRate': instance.globalAccuracyRate,
      'oabBaseline': instance.oabBaseline,
      'bySubject': instance.bySubject,
    };
