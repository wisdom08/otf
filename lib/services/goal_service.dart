import '../services/local_storage_service.dart';

class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isCompleted;
  final double progress;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isCompleted = false,
    this.progress = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'progress': progress,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isCompleted: map['isCompleted'] ?? false,
      progress: (map['progress'] ?? 0.0).toDouble(),
    );
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isCompleted,
    double? progress,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
    );
  }
}

class GoalService {
  static List<Goal> _goals = [];

  // 목표 목록 불러오기
  static List<Goal> getGoals() {
    final goalsData = LocalStorageService.getGoals();
    _goals = goalsData.map((data) => Goal.fromMap(data)).toList();
    return _goals;
  }

  // 목표 저장
  static Future<void> saveGoals() async {
    final goalsData = _goals.map((goal) => goal.toMap()).toList();
    await LocalStorageService.saveGoals(goalsData);
  }

  // 새 목표 추가
  static Future<void> addGoal(String title, String description) async {
    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    _goals.add(goal);
    await saveGoals();
  }

  // 목표 완료 처리
  static Future<void> completeGoal(String goalId) async {
    final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
    if (goalIndex != -1) {
      _goals[goalIndex] = _goals[goalIndex].copyWith(
        isCompleted: true,
        progress: 1.0,
      );
      await saveGoals();
      await LocalStorageService.completeGoal(goalId);
    }
  }

  // 목표 삭제
  static Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((goal) => goal.id == goalId);
    await saveGoals();
  }

  // 목표 진행률 업데이트
  static Future<void> updateProgress(String goalId, double progress) async {
    final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
    if (goalIndex != -1) {
      _goals[goalIndex] = _goals[goalIndex].copyWith(progress: progress);
      await saveGoals();
    }
  }

  // 오늘의 목표 가져오기
  static List<Goal> getTodayGoals() {
    final today = DateTime.now();
    return _goals.where((goal) {
      return goal.createdAt.year == today.year &&
          goal.createdAt.month == today.month &&
          goal.createdAt.day == today.day;
    }).toList();
  }

  // 진행 중인 목표 가져오기
  static List<Goal> getActiveGoals() {
    return _goals
        .where((goal) => !goal.isCompleted && goal.progress < 1.0)
        .toList();
  }
}
