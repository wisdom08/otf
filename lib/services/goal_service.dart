import '../services/local_storage_service.dart';
import 'package:flutter/material.dart';

// 목표 타입 정의
enum GoalType { monthly, weekly, daily }

// 목표 공개 설정 정의
enum GoalPrivacy { private, friends, public }

// 사용자 모델
class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

// 시간 기록 모델
class TimeEntry {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;

  TimeEntry({
    required this.id,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
    };
  }

  factory TimeEntry.fromMap(Map<String, dynamic> map) {
    return TimeEntry(
      id: map['id'] ?? '',
      startTime: DateTime.parse(
        map['startTime'] ?? DateTime.now().toIso8601String(),
      ),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      durationMinutes: map['durationMinutes'] ?? 0,
    );
  }
}

class Goal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final DateTime createdAt;
  final bool isCompleted;
  final double progress;
  final List<TimeEntry> timeEntries;
  final int targetMinutes; // 목표 시간 (분)
  final String? parentGoalId; // 상위 목표 ID
  final int? targetYear; // 목표 년도 (한 달 목표용)
  final int? targetMonth; // 목표 월 (한 달 목표용)
  final int? targetWeek; // 목표 주 (일주일 목표용)
  final GoalPrivacy privacy; // 공개 설정
  final String userId; // 목표 소유자 ID

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    this.isCompleted = false,
    this.progress = 0.0,
    this.timeEntries = const [],
    this.targetMinutes = 0,
    this.parentGoalId,
    this.targetYear,
    this.targetMonth,
    this.targetWeek,
    this.privacy = GoalPrivacy.private,
    this.userId = 'current_user',
  });

  // 총 시간 계산 (분)
  int get totalMinutes {
    return timeEntries.fold(0, (sum, entry) => sum + entry.durationMinutes);
  }

  // 진행률 계산 (시간 기반)
  double get timeProgress {
    if (targetMinutes == 0) return 0.0;
    return (totalMinutes / targetMinutes).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'progress': progress,
      'timeEntries': timeEntries.map((e) => e.toMap()).toList(),
      'targetMinutes': targetMinutes,
      'parentGoalId': parentGoalId,
      'targetYear': targetYear,
      'targetMonth': targetMonth,
      'targetWeek': targetWeek,
      'privacy': privacy.toString(),
      'userId': userId,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: GoalType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => GoalType.daily,
      ),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isCompleted: map['isCompleted'] ?? false,
      progress: (map['progress'] ?? 0.0).toDouble(),
      timeEntries:
          (map['timeEntries'] as List<dynamic>?)
              ?.map((e) => TimeEntry.fromMap(e))
              .toList() ??
          [],
      targetMinutes: map['targetMinutes'] ?? 0,
      parentGoalId: map['parentGoalId'],
      targetYear: map['targetYear'],
      targetMonth: map['targetMonth'],
      targetWeek: map['targetWeek'],
      privacy: GoalPrivacy.values.firstWhere(
        (e) => e.toString() == map['privacy'],
        orElse: () => GoalPrivacy.private,
      ),
      userId: map['userId'] ?? 'current_user',
    );
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    DateTime? createdAt,
    bool? isCompleted,
    double? progress,
    List<TimeEntry>? timeEntries,
    int? targetMinutes,
    String? parentGoalId,
    int? targetYear,
    int? targetMonth,
    int? targetWeek,
    GoalPrivacy? privacy,
    String? userId,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      timeEntries: timeEntries ?? this.timeEntries,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      parentGoalId: parentGoalId ?? this.parentGoalId,
      targetYear: targetYear ?? this.targetYear,
      targetMonth: targetMonth ?? this.targetMonth,
      targetWeek: targetWeek ?? this.targetWeek,
      privacy: privacy ?? this.privacy,
      userId: userId ?? this.userId,
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

  // 새 목표 추가 (타입별)
  static Future<void> addGoal(
    String title,
    String description,
    GoalType type, {
    int targetMinutes = 0,
    String? parentGoalId,
    int? targetYear,
    int? targetMonth,
    int? targetWeek,
    GoalPrivacy privacy = GoalPrivacy.private,
    String userId = 'current_user',
  }) async {
    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      createdAt: DateTime.now(),
      targetMinutes: targetMinutes,
      parentGoalId: parentGoalId,
      targetYear: targetYear,
      targetMonth: targetMonth,
      targetWeek: targetWeek,
      privacy: privacy,
      userId: userId,
    );

    _goals.add(goal);
    await saveGoals();
  }

  // 시간 기록 시작
  static Future<void> startTimeTracking(String goalId) async {
    final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
    if (goalIndex != -1) {
      final newTimeEntry = TimeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
      );

      final updatedTimeEntries = List<TimeEntry>.from(
        _goals[goalIndex].timeEntries,
      );
      updatedTimeEntries.add(newTimeEntry);

      _goals[goalIndex] = _goals[goalIndex].copyWith(
        timeEntries: updatedTimeEntries,
      );
      await saveGoals();
    }
  }

  // 시간 기록 중지
  static Future<void> stopTimeTracking(String goalId) async {
    final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final timeEntries = List<TimeEntry>.from(goal.timeEntries);

      // 마지막 시간 기록 찾기
      if (timeEntries.isNotEmpty) {
        final lastEntry = timeEntries.last;
        if (lastEntry.endTime == null) {
          final endTime = DateTime.now();
          final duration = endTime.difference(lastEntry.startTime).inMinutes;

          final updatedEntry = TimeEntry(
            id: lastEntry.id,
            startTime: lastEntry.startTime,
            endTime: endTime,
            durationMinutes: duration,
          );

          timeEntries[timeEntries.length - 1] = updatedEntry;

          _goals[goalIndex] = _goals[goalIndex].copyWith(
            timeEntries: timeEntries,
          );
          await saveGoals();
        }
      }
    }
  }

  // 목표 완료 처리 (계층적 진행률 업데이트 포함)
  static Future<void> completeGoal(String goalId) async {
    final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];

      // 목표 완료 처리
      _goals[goalIndex] = _goals[goalIndex].copyWith(
        isCompleted: true,
        progress: 1.0,
      );

      // 상위 목표의 진행률 업데이트
      await _updateParentGoalProgress(goal);

      await saveGoals();
      await LocalStorageService.completeGoal(goalId);
    }
  }

  // 상위 목표의 진행률 업데이트
  static Future<void> _updateParentGoalProgress(Goal completedGoal) async {
    if (completedGoal.parentGoalId == null) return;

    final parentGoalIndex = _goals.indexWhere(
      (goal) => goal.id == completedGoal.parentGoalId,
    );
    if (parentGoalIndex == -1) return;

    final parentGoal = _goals[parentGoalIndex];

    // 하위 목표들의 완료 상태 확인
    final subGoals = _goals
        .where((goal) => goal.parentGoalId == parentGoal.id)
        .toList();

    if (subGoals.isEmpty) return;

    // 완료된 하위 목표 수 계산
    final completedSubGoals = subGoals.where((goal) => goal.isCompleted).length;

    // 상위 목표의 진행률 계산 (완료된 하위 목표 수 / 전체 하위 목표 수)
    final newProgress = completedSubGoals / subGoals.length;

    // 상위 목표 진행률 업데이트
    _goals[parentGoalIndex] = _goals[parentGoalIndex].copyWith(
      progress: newProgress,
    );

    // 상위 목표도 완료되었는지 확인
    if (newProgress >= 1.0) {
      _goals[parentGoalIndex] = _goals[parentGoalIndex].copyWith(
        isCompleted: true,
      );

      // 상위 목표의 상위 목표도 업데이트 (재귀적)
      await _updateParentGoalProgress(_goals[parentGoalIndex]);
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

  // 타입별 목표 가져오기
  static List<Goal> getGoalsByType(GoalType type) {
    return _goals.where((goal) => goal.type == type).toList();
  }

  // 하위 목표 가져오기
  static List<Goal> getSubGoals(String parentGoalId) {
    return _goals.where((goal) => goal.parentGoalId == parentGoalId).toList();
  }

  // 오늘의 목표 가져오기 (오늘의 목표만)
  static List<Goal> getTodayGoals() {
    final today = DateTime.now();
    return _goals.where((goal) {
      return goal.type == GoalType.daily &&
          goal.createdAt.year == today.year &&
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

  // 현재 진행 중인 시간 기록이 있는지 확인
  static bool isTimeTrackingActive(String goalId) {
    final goal = _goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => Goal(
        id: '',
        title: '',
        description: '',
        type: GoalType.daily,
        createdAt: DateTime.now(),
      ),
    );
    if (goal.timeEntries.isEmpty) return false;

    final lastEntry = goal.timeEntries.last;
    return lastEntry.endTime == null;
  }

  // 현재 진행 중인 시간 기록의 실시간 시간 계산 (초 단위)
  static int getCurrentTrackingSeconds(String goalId) {
    final goal = _goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => Goal(
        id: '',
        title: '',
        description: '',
        type: GoalType.daily,
        createdAt: DateTime.now(),
      ),
    );

    if (goal.timeEntries.isEmpty) return 0;

    final lastEntry = goal.timeEntries.last;
    if (lastEntry.endTime == null) {
      // 현재 진행 중인 시간 기록 (초 단위)
      return DateTime.now().difference(lastEntry.startTime).inSeconds;
    }

    return 0;
  }

  // 현재 진행 중인 시간 기록의 실시간 시간 계산 (분 단위)
  static int getCurrentTrackingMinutes(String goalId) {
    return getCurrentTrackingSeconds(goalId) ~/ 60;
  }

  // 총 시간 + 현재 진행 중인 시간
  static int getTotalTimeWithCurrent(String goalId) {
    final goal = _goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => Goal(
        id: '',
        title: '',
        description: '',
        type: GoalType.daily,
        createdAt: DateTime.now(),
      ),
    );

    return goal.totalMinutes + getCurrentTrackingMinutes(goalId);
  }

  // 시간 기록 포맷팅 (분 단위만)
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}시간 ${mins}분';
    } else {
      return '${mins}분';
    }
  }

  // 시간 기록 포맷팅 (초 단위 포함)
  static String formatDurationWithSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}분 ${remainingSeconds}초';
    } else {
      return '${remainingSeconds}초';
    }
  }

  // 친구 목록 관리
  static List<String> _friends = [];

  // 친구 추가
  static Future<void> addFriend(String userId) async {
    if (!_friends.contains(userId)) {
      _friends.add(userId);
      await LocalStorageService.saveFriends(_friends);
    }
  }

  // 친구 제거
  static Future<void> removeFriend(String userId) async {
    _friends.remove(userId);
    await LocalStorageService.saveFriends(_friends);
  }

  // 친구 목록 가져오기
  static List<String> getFriends() {
    _friends = LocalStorageService.getFriends();
    return _friends;
  }

  // 친구인지 확인
  static bool isFriend(String userId) {
    return _friends.contains(userId);
  }

  // 피드용 목표 가져오기 (친구공개 + 전체공개)
  static List<Goal> getFeedGoals() {
    final allGoals = getGoals();
    final friends = getFriends();

    return allGoals.where((goal) {
      // 내 목표는 제외
      if (goal.userId == 'current_user') return false;

      // 전체공개 목표
      if (goal.privacy == GoalPrivacy.public) return true;

      // 친구공개 목표 (친구인 경우만)
      if (goal.privacy == GoalPrivacy.friends &&
          friends.contains(goal.userId)) {
        return true;
      }

      return false;
    }).toList();
  }

  // 공개 설정 라벨 가져오기
  static String getPrivacyLabel(GoalPrivacy privacy) {
    switch (privacy) {
      case GoalPrivacy.private:
        return '비공개';
      case GoalPrivacy.friends:
        return '친구공개';
      case GoalPrivacy.public:
        return '전체공개';
    }
  }

  // 공개 설정 아이콘 가져오기
  static IconData getPrivacyIcon(GoalPrivacy privacy) {
    switch (privacy) {
      case GoalPrivacy.private:
        return Icons.lock;
      case GoalPrivacy.friends:
        return Icons.people;
      case GoalPrivacy.public:
        return Icons.public;
    }
  }
}
