import '../services/local_storage_service.dart';
import 'package:flutter/material.dart';

// 목표 타입 정의
enum GoalType { monthly, weekly, daily }

// 목표 공개 설정 정의
enum GoalPrivacy { private, friends, public }

// 소셜 액션 모델
class SocialAction {
  final String id;
  final String goalId;
  final String userId;
  final SocialActionType type;
  final DateTime createdAt;
  final String? content; // 댓글 내용

  SocialAction({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.type,
    required this.createdAt,
    this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'userId': userId,
      'type': type.toString(),
      'createdAt': createdAt.toIso8601String(),
      'content': content,
    };
  }

  factory SocialAction.fromMap(Map<String, dynamic> map) {
    return SocialAction(
      id: map['id'] ?? '',
      goalId: map['goalId'] ?? '',
      userId: map['userId'] ?? '',
      type: SocialActionType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => SocialActionType.like,
      ),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      content: map['content'],
    );
  }
}

// 소셜 액션 타입
enum SocialActionType { like, comment, share }

// 회고 타입
enum ReflectionType {
  oneLine, // 한 줄 회고
  kpt, // KPT 방식
  emoji, // 이모지 회고
}

// 회고 모델
class Reflection {
  final String id;
  final String goalId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final int rating; // 1-5점 만족도
  final List<String> tags; // 태그들 (예: ["성취감", "어려움", "다음계획"])
  final ReflectionType type; // 회고 방식
  final Map<String, dynamic>? typeData; // 타입별 추가 데이터

  Reflection({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.rating,
    this.tags = const [],
    this.type = ReflectionType.oneLine,
    this.typeData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'rating': rating,
      'tags': tags,
      'type': type.toString(),
      'typeData': typeData,
    };
  }

  factory Reflection.fromMap(Map<String, dynamic> map) {
    return Reflection(
      id: map['id'] ?? '',
      goalId: map['goalId'] ?? '',
      userId: map['userId'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      rating: map['rating'] ?? 5,
      tags: List<String>.from(map['tags'] ?? []),
      type: ReflectionType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => ReflectionType.oneLine,
      ),
      typeData: map['typeData'] != null
          ? Map<String, dynamic>.from(map['typeData'])
          : null,
    );
  }
}

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
  final DateTime? completedAt; // 완료일시

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
    this.completedAt,
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
      'completedAt': completedAt?.toIso8601String(),
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
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
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
    DateTime? completedAt,
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
      completedAt: completedAt ?? this.completedAt,
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

    // 하위 목표를 추가한 경우 상위 목표의 진행률 재계산
    if (parentGoalId != null) {
      await _updateParentGoalProgress(goal);
    }

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
        completedAt: DateTime.now(),
      );

      // 상위 목표의 진행률 업데이트
      await _updateParentGoalProgress(goal);

      await saveGoals();
      await LocalStorageService.completeGoal(goalId);
    }
  }

  // 목표 미완료 처리 (계층적 진행률 업데이트 포함)
  static Future<void> uncompleteGoal(String goalId) async {
    final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];

      // 진행률 계산
      double newProgress = 0.0;

      // 월간 목표나 주간 목표의 경우 하위 목표들의 완료 상태를 기반으로 진행률 재계산
      if (goal.type == GoalType.monthly || goal.type == GoalType.weekly) {
        final subGoals = _goals
            .where((g) => g.parentGoalId == goal.id)
            .toList();
        if (subGoals.isNotEmpty) {
          final completedSubGoals = subGoals.where((g) => g.isCompleted).length;
          newProgress = completedSubGoals / subGoals.length;
        }
      }

      // 목표 미완료 처리
      _goals[goalIndex] = _goals[goalIndex].copyWith(
        isCompleted: false,
        progress: newProgress,
        completedAt: null,
      );

      // 상위 목표도 미완료 처리 (계층적)
      await _uncompleteParentGoals(goal);

      // 상위 목표의 진행률 재계산
      await _updateParentGoalProgress(goal);

      await saveGoals();
      // Streak는 유지 (미완료 처리해도 이미 달성한 것은 유지)
    }
  }

  // 상위 목표들을 재귀적으로 미완료 처리
  static Future<void> _uncompleteParentGoals(Goal goal) async {
    if (goal.parentGoalId == null) return;

    final parentGoalIndex = _goals.indexWhere((g) => g.id == goal.parentGoalId);
    if (parentGoalIndex == -1) return;

    final parentGoal = _goals[parentGoalIndex];

    // 상위 목표가 완료 상태인 경우에만 미완료 처리
    if (parentGoal.isCompleted) {
      // 진행률 재계산
      final subGoals = _goals
          .where((g) => g.parentGoalId == parentGoal.id)
          .toList();
      double newProgress = 0.0;
      if (subGoals.isNotEmpty) {
        final completedSubGoals = subGoals.where((g) => g.isCompleted).length;
        newProgress = completedSubGoals / subGoals.length;
      }

      _goals[parentGoalIndex] = _goals[parentGoalIndex].copyWith(
        isCompleted: false,
        progress: newProgress,
        completedAt: null,
      );

      // 상위 목표의 상위 목표도 재귀적으로 미완료 처리
      await _uncompleteParentGoals(_goals[parentGoalIndex]);
    }
  }

  // 목표 완료 처리 (회고 포함)
  static Future<void> completeGoalWithReflection(
    String goalId,
    String reflectionContent,
    int rating, {
    List<String> tags = const [],
    String userId = 'current_user',
    ReflectionType type = ReflectionType.oneLine,
    Map<String, dynamic>? typeData,
  }) async {
    // 목표 완료 처리
    await completeGoal(goalId);

    // 회고 추가
    await addReflection(
      goalId,
      reflectionContent,
      rating,
      tags: tags,
      userId: userId,
      type: type,
      typeData: typeData,
    );
  }

  // 상위 목표의 진행률 업데이트
  static Future<void> _updateParentGoalProgress(Goal changedGoal) async {
    if (changedGoal.parentGoalId == null) return;

    final parentGoalIndex = _goals.indexWhere(
      (goal) => goal.id == changedGoal.parentGoalId,
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
    // 월간 목표와 주간 목표는 자동으로 완료되지 않음 (수동 완료 처리)
    final shouldAutoComplete = parentGoal.type == GoalType.daily;

    _goals[parentGoalIndex] = _goals[parentGoalIndex].copyWith(
      progress: newProgress,
      isCompleted: shouldAutoComplete
          ? newProgress >= 1.0
          : parentGoal.isCompleted,
    );

    // 상위 목표의 상위 목표도 업데이트 (재귀적)
    if (_goals[parentGoalIndex].parentGoalId != null) {
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

  // 소셜 액션 관리
  static List<SocialAction> _socialActions = [];

  // 회고 관리
  static List<Reflection> _reflections = [];

  // 소셜 액션 추가
  static Future<void> addSocialAction(
    String goalId,
    SocialActionType type, {
    String? content,
    String userId = 'current_user',
  }) async {
    final action = SocialAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      goalId: goalId,
      userId: userId,
      type: type,
      createdAt: DateTime.now(),
      content: content,
    );

    _socialActions.add(action);
    await _saveSocialActions();
  }

  // 목표의 소셜 액션 가져오기
  static List<SocialAction> getSocialActions(String goalId) {
    return _socialActions.where((action) => action.goalId == goalId).toList();
  }

  // 좋아요 수 가져오기
  static int getLikeCount(String goalId) {
    return _socialActions
        .where(
          (action) =>
              action.goalId == goalId && action.type == SocialActionType.like,
        )
        .length;
  }

  // 댓글 수 가져오기
  static int getCommentCount(String goalId) {
    return _socialActions
        .where(
          (action) =>
              action.goalId == goalId &&
              action.type == SocialActionType.comment,
        )
        .length;
  }

  // 공유 수 가져오기
  static int getShareCount(String goalId) {
    return _socialActions
        .where(
          (action) =>
              action.goalId == goalId && action.type == SocialActionType.share,
        )
        .length;
  }

  // 사용자가 좋아요를 눌렀는지 확인
  static bool hasUserLiked(String goalId, {String userId = 'current_user'}) {
    return _socialActions.any(
      (action) =>
          action.goalId == goalId &&
          action.userId == userId &&
          action.type == SocialActionType.like,
    );
  }

  // 좋아요 토글
  static Future<void> toggleLike(
    String goalId, {
    String userId = 'current_user',
  }) async {
    final existingLike = _socialActions.firstWhere(
      (action) =>
          action.goalId == goalId &&
          action.userId == userId &&
          action.type == SocialActionType.like,
      orElse: () => SocialAction(
        id: '',
        goalId: '',
        userId: '',
        type: SocialActionType.like,
        createdAt: DateTime.now(),
      ),
    );

    if (existingLike.id.isNotEmpty) {
      _socialActions.remove(existingLike);
    } else {
      await addSocialAction(goalId, SocialActionType.like, userId: userId);
    }
    await _saveSocialActions();
  }

  // 소셜 액션 저장
  static Future<void> _saveSocialActions() async {
    final actionsJson = _socialActions.map((action) => action.toMap()).toList();
    await LocalStorageService.saveSocialActions(actionsJson);
  }

  // 소셜 액션 불러오기
  static Future<void> _loadSocialActions() async {
    final actionsJson = LocalStorageService.getSocialActions();
    _socialActions = actionsJson
        .map((json) => SocialAction.fromMap(json))
        .toList();
  }

  // 테스트 데이터 초기화
  static Future<void> initializeTestData() async {
    // 기존 데이터가 있으면 초기화하지 않음
    if (_goals.isNotEmpty) return;

    // 테스트용 목표 데이터
    final testGoals = [
      Goal(
        id: 'goal_1',
        title: '2024년 새해 목표 달성하기',
        description: '건강한 생활습관을 만들고 새로운 기술을 배우는 것이 목표입니다.',
        type: GoalType.monthly,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        targetMinutes: 1200, // 20시간
        targetYear: 2024,
        targetMonth: 1,
        privacy: GoalPrivacy.public,
        userId: 'user_alice',
      ),
      Goal(
        id: 'goal_2',
        title: '주간 운동 계획',
        description: '매주 3회 이상 운동하기',
        type: GoalType.weekly,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        targetMinutes: 180, // 3시간
        parentGoalId: 'goal_1',
        targetYear: 2024,
        targetMonth: 1,
        targetWeek: 1,
        privacy: GoalPrivacy.public,
        userId: 'user_alice',
      ),
      Goal(
        id: 'goal_3',
        title: '오늘의 독서 시간',
        description: '매일 30분씩 책 읽기',
        type: GoalType.daily,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        targetMinutes: 30,
        parentGoalId: 'goal_2',
        targetYear: 2024,
        targetMonth: 1,
        targetWeek: 1,
        privacy: GoalPrivacy.public,
        userId: 'user_alice',
      ),
      Goal(
        id: 'goal_4',
        title: 'Flutter 앱 개발 마스터하기',
        description: 'Flutter를 이용한 모바일 앱 개발 실력을 향상시키기',
        type: GoalType.monthly,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        targetMinutes: 2400, // 40시간
        targetYear: 2024,
        targetMonth: 1,
        privacy: GoalPrivacy.friends,
        userId: 'user_bob',
      ),
      Goal(
        id: 'goal_5',
        title: '주간 코딩 프로젝트',
        description: '매주 작은 프로젝트 하나씩 완성하기',
        type: GoalType.weekly,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        targetMinutes: 300, // 5시간
        parentGoalId: 'goal_4',
        targetYear: 2024,
        targetMonth: 1,
        targetWeek: 2,
        privacy: GoalPrivacy.friends,
        userId: 'user_bob',
      ),
      Goal(
        id: 'goal_6',
        title: '매일 알고리즘 문제 풀기',
        description: '하루에 최소 1문제씩 알고리즘 문제 해결',
        type: GoalType.daily,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        targetMinutes: 60,
        parentGoalId: 'goal_5',
        targetYear: 2024,
        targetMonth: 1,
        targetWeek: 2,
        privacy: GoalPrivacy.friends,
        userId: 'user_bob',
      ),
      Goal(
        id: 'goal_7',
        title: '건강한 다이어트 계획',
        description: '체중 감량과 건강한 식단 관리',
        type: GoalType.monthly,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        targetMinutes: 1800, // 30시간
        targetYear: 2024,
        targetMonth: 1,
        privacy: GoalPrivacy.private,
        userId: 'user_charlie',
      ),
      Goal(
        id: 'goal_8',
        title: '주간 운동 루틴',
        description: '매주 4회 헬스장 가기',
        type: GoalType.weekly,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        targetMinutes: 240, // 4시간
        parentGoalId: 'goal_7',
        targetYear: 2024,
        targetMonth: 1,
        targetWeek: 3,
        privacy: GoalPrivacy.private,
        userId: 'user_charlie',
      ),
    ];

    // 목표 저장 (일부 목표를 완료 상태로 설정)
    _goals = testGoals;

    // 회고가 있는 목표들을 완료 상태로 설정 (월간 목표는 제외)
    final completedGoalIds = ['goal_2', 'goal_4']; // goal_1(월간) 제외
    for (int i = 0; i < _goals.length; i++) {
      if (completedGoalIds.contains(_goals[i].id)) {
        _goals[i] = _goals[i].copyWith(isCompleted: true, progress: 1.0);
        // completedAt은 별도로 설정 (Goal 생성자에 completedAt 파라미터가 없으므로)
        final completedAt = DateTime.now().subtract(Duration(hours: i + 1));
        _goals[i] = Goal(
          id: _goals[i].id,
          title: _goals[i].title,
          description: _goals[i].description,
          type: _goals[i].type,
          createdAt: _goals[i].createdAt,
          isCompleted: true,
          progress: 1.0,
          targetMinutes: _goals[i].targetMinutes,
          parentGoalId: _goals[i].parentGoalId,
          targetYear: _goals[i].targetYear,
          targetMonth: _goals[i].targetMonth,
          targetWeek: _goals[i].targetWeek,
          userId: _goals[i].userId,
          privacy: _goals[i].privacy,
        );
        // completedAt은 copyWith로 설정
        _goals[i] = _goals[i].copyWith(completedAt: completedAt);
      }
    }

    await saveGoals();

    // 테스트용 친구 데이터
    await addFriend('user_alice');
    await addFriend('user_bob');
    await addFriend('user_charlie');

    // 테스트용 소셜 액션 데이터
    final testSocialActions = [
      SocialAction(
        id: 'action_1',
        goalId: 'goal_1',
        userId: 'user_bob',
        type: SocialActionType.like,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SocialAction(
        id: 'action_2',
        goalId: 'goal_1',
        userId: 'user_charlie',
        type: SocialActionType.like,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      SocialAction(
        id: 'action_3',
        goalId: 'goal_1',
        userId: 'user_bob',
        type: SocialActionType.comment,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        content: '정말 멋진 목표네요! 화이팅! 💪',
      ),
      SocialAction(
        id: 'action_4',
        goalId: 'goal_4',
        userId: 'user_alice',
        type: SocialActionType.like,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      SocialAction(
        id: 'action_5',
        goalId: 'goal_4',
        userId: 'user_charlie',
        type: SocialActionType.comment,
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        content: 'Flutter 개발 화이팅! 저도 배우고 있어요 🚀',
      ),
      SocialAction(
        id: 'action_6',
        goalId: 'goal_4',
        userId: 'user_alice',
        type: SocialActionType.share,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      SocialAction(
        id: 'action_7',
        goalId: 'goal_2',
        userId: 'user_bob',
        type: SocialActionType.like,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      SocialAction(
        id: 'action_8',
        goalId: 'goal_5',
        userId: 'user_alice',
        type: SocialActionType.comment,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        content: '프로젝트 완성하시면 공유해주세요!',
      ),
    ];

    _socialActions = testSocialActions;
    await _saveSocialActions();

    // 테스트용 회고 데이터
    final testReflections = [
      Reflection(
        id: 'reflection_1',
        goalId: 'goal_1',
        userId: 'user_alice',
        content:
            '새해 목표를 달성하며 정말 뿌듯합니다! 건강한 생활습관을 만들기 위해 매일 운동을 했고, 새로운 기술도 배웠어요. 다음 달에는 더 도전적인 목표를 세워보려고 합니다.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        rating: 5,
        tags: ['성취감', '다음계획', '보람'],
        type: ReflectionType.oneLine,
      ),
      Reflection(
        id: 'reflection_2',
        goalId: 'goal_4',
        userId: 'user_bob',
        content: 'KPT 회고',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        rating: 4,
        tags: ['성장', '도전', '기쁨'],
        type: ReflectionType.kpt,
        typeData: {
          'keep': '매일 2시간씩 Flutter 공부를 꾸준히 했다',
          'problem': '복잡한 상태 관리에서 어려움을 겪었다',
          'try': 'Provider 패턴을 더 깊이 공부해보자',
        },
      ),
      Reflection(
        id: 'reflection_3',
        goalId: 'goal_2',
        userId: 'user_alice',
        content: '이모지 회고: 🙂',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        rating: 4,
        tags: ['성취감', '성장', '다음계획'],
        type: ReflectionType.emoji,
        typeData: {'emoji': '🙂', 'rating': 4},
      ),
    ];

    _reflections = testReflections;
    await _saveReflections();

    // Streak 데이터 초기화
    await LocalStorageService.saveStreak(7);
  }

  // 회고 추가
  static Future<void> addReflection(
    String goalId,
    String content,
    int rating, {
    List<String> tags = const [],
    String userId = 'current_user',
    ReflectionType type = ReflectionType.oneLine,
    Map<String, dynamic>? typeData,
  }) async {
    final reflection = Reflection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      goalId: goalId,
      userId: userId,
      content: content,
      createdAt: DateTime.now(),
      rating: rating,
      tags: tags,
      type: type,
      typeData: typeData,
    );

    _reflections.add(reflection);
    await _saveReflections();
  }

  // 목표의 회고 가져오기
  static List<Reflection> getReflections(String goalId) {
    return _reflections
        .where((reflection) => reflection.goalId == goalId)
        .toList();
  }

  // 모든 회고 가져오기
  static List<Reflection> getAllReflections() {
    return _reflections;
  }

  // 회고 저장
  static Future<void> _saveReflections() async {
    final reflectionsJson = _reflections
        .map((reflection) => reflection.toMap())
        .toList();
    await LocalStorageService.saveReflections(reflectionsJson);
  }

  // 회고 불러오기
  static Future<void> _loadReflections() async {
    final reflectionsJson = LocalStorageService.getReflections();
    _reflections = reflectionsJson
        .map((json) => Reflection.fromMap(json))
        .toList();
  }

  // 주간 목표 완료 가능 여부 확인 (모든 일간 목표가 완료되어야 함)
  static bool canCompleteWeeklyGoal(String weeklyGoalId) {
    final dailyGoals = getSubGoals(
      weeklyGoalId,
    ).where((goal) => goal.type == GoalType.daily).toList();

    if (dailyGoals.isEmpty) return true; // 일간 목표가 없으면 완료 가능

    return dailyGoals.every((goal) => goal.isCompleted);
  }

  // 월간 목표 완료 가능 여부 확인 (모든 주간 목표와 그 하위 일간 목표가 완료되어야 함)
  static bool canCompleteMonthlyGoal(String monthlyGoalId) {
    final weeklyGoals = getSubGoals(
      monthlyGoalId,
    ).where((goal) => goal.type == GoalType.weekly).toList();

    if (weeklyGoals.isEmpty) return false; // 주간 목표가 없으면 완료할 수 없음

    // 모든 주간 목표가 완료되었는지 확인
    for (final weeklyGoal in weeklyGoals) {
      if (!weeklyGoal.isCompleted) return false;

      // 각 주간 목표의 하위 일간 목표들이 모두 완료되었는지 확인
      if (!canCompleteWeeklyGoal(weeklyGoal.id)) return false;
    }

    return true;
  }

  // 목표 완료 가능 여부 확인 (계층적 조건 포함)
  static bool canCompleteGoal(String goalId) {
    final goal = _goals.firstWhere((g) => g.id == goalId);

    switch (goal.type) {
      case GoalType.daily:
        return true; // 일간 목표는 언제든 완료 가능
      case GoalType.weekly:
        return canCompleteWeeklyGoal(goalId);
      case GoalType.monthly:
        return canCompleteMonthlyGoal(goalId);
    }
  }
}
