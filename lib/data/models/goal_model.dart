import 'package:json_annotation/json_annotation.dart';

part 'goal_model.g.dart';

@JsonSerializable()
class GoalModel {
  final int id;
  final String title;
  final String? description;
  final String type; // 'monthly', 'weekly', 'daily'
  final int? parentId;
  final String userId;
  final bool isShared;
  final String visibility; // 'public', 'friends', 'private'
  final DateTime createdAt;
  final DateTime updatedAt;

  const GoalModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.parentId,
    required this.userId,
    required this.isShared,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);
  Map<String, dynamic> toJson() => _$GoalModelToJson(this);

  GoalModel copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    int? parentId,
    String? userId,
    bool? isShared,
    String? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      userId: userId ?? this.userId,
      isShared: isShared ?? this.isShared,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GoalModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.type == type &&
        other.parentId == parentId &&
        other.userId == userId &&
        other.isShared == isShared &&
        other.visibility == visibility &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        type.hashCode ^
        parentId.hashCode ^
        userId.hashCode ^
        isShared.hashCode ^
        visibility.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
