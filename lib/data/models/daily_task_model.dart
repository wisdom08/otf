import 'package:json_annotation/json_annotation.dart';

part 'daily_task_model.g.dart';

@JsonSerializable()
class DailyTaskModel {
  final int id;
  final int goalId;
  final String userId;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyTaskModel({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.date,
    this.startTime,
    this.endTime,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyTaskModel.fromJson(Map<String, dynamic> json) =>
      _$DailyTaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$DailyTaskModelToJson(this);

  DailyTaskModel copyWith({
    int? id,
    int? goalId,
    String? userId,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyTaskModel(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 진행 시간 계산 (분 단위)
  int? get durationInMinutes {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!).inMinutes;
  }

  // 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    if (isCompleted) return 1.0;
    if (startTime == null) return 0.0;

    final now = DateTime.now();
    final totalDuration =
        endTime?.difference(startTime!) ?? const Duration(hours: 1);
    final elapsed = now.difference(startTime!);

    if (elapsed >= totalDuration) return 1.0;
    return elapsed.inMinutes / totalDuration.inMinutes;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyTaskModel &&
        other.id == id &&
        other.goalId == goalId &&
        other.userId == userId &&
        other.date == date &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        goalId.hashCode ^
        userId.hashCode ^
        date.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        isCompleted.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
