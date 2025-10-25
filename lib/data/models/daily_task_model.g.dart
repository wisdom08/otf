// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyTaskModel _$DailyTaskModelFromJson(Map<String, dynamic> json) =>
    DailyTaskModel(
      id: (json['id'] as num).toInt(),
      goalId: (json['goalId'] as num).toInt(),
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DailyTaskModelToJson(DailyTaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalId': instance.goalId,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'isCompleted': instance.isCompleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
