import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'LocalStorageService not initialized. Call init() first.',
      );
    }
    return _prefs!;
  }

  // 현재 사용자 ID 저장
  static Future<void> setCurrentUserId(String userId) async {
    await prefs.setString('current_user_id', userId);
  }

  // 현재 사용자 ID 불러오기
  static String getCurrentUserId() {
    return prefs.getString('current_user_id') ?? 'current_user';
  }

  // 목표 저장
  static Future<void> saveGoals(List<Map<String, dynamic>> goals) async {
    await prefs.setString('goals', jsonEncode(goals));
  }

  // 목표 불러오기
  static List<Map<String, dynamic>> getGoals() {
    final goalsString = prefs.getString('goals');
    if (goalsString == null) return [];

    try {
      final List<dynamic> goalsList = jsonDecode(goalsString);
      return goalsList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Streak 저장
  static Future<void> saveStreak(int streak) async {
    await prefs.setInt('streak', streak);
  }

  // Streak 불러오기
  static int getStreak() {
    return prefs.getInt('streak') ?? 0;
  }

  // 사용자 이름 저장
  static Future<void> saveUserName(String name) async {
    await prefs.setString('user_name', name);
  }

  // 사용자 이름 불러오기
  static String getUserName() {
    return prefs.getString('user_name') ?? '사용자';
  }

  // 오늘 완료한 목표 저장
  static Future<void> saveCompletedGoals(List<String> goalIds) async {
    await prefs.setStringList(
      'completed_goals_${DateTime.now().toIso8601String().split('T')[0]}',
      goalIds,
    );
  }

  // 오늘 완료한 목표 불러오기
  static List<String> getCompletedGoals() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return prefs.getStringList('completed_goals_$today') ?? [];
  }

  // 목표 완료 처리
  static Future<void> completeGoal(String goalId) async {
    final completedGoals = getCompletedGoals();
    if (!completedGoals.contains(goalId)) {
      completedGoals.add(goalId);
      await saveCompletedGoals(completedGoals);

      // Streak 업데이트
      final currentStreak = getStreak();
      await saveStreak(currentStreak + 1);
    }
  }

  // 친구 목록 저장
  static Future<void> saveFriends(List<String> friends) async {
    await prefs.setStringList('friends', friends);
  }

  // 친구 목록 불러오기
  static List<String> getFriends() {
    return prefs.getStringList('friends') ?? [];
  }

  // 소셜 액션 저장
  static Future<void> saveSocialActions(
    List<Map<String, dynamic>> actions,
  ) async {
    await prefs.setString('social_actions', jsonEncode(actions));
  }

  // 소셜 액션 불러오기
  static List<Map<String, dynamic>> getSocialActions() {
    final actionsString = prefs.getString('social_actions');
    if (actionsString == null) return [];

    try {
      final List<dynamic> actionsList = jsonDecode(actionsString);
      return actionsList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // 회고 저장
  static Future<void> saveReflections(
    List<Map<String, dynamic>> reflections,
  ) async {
    await prefs.setString('reflections', jsonEncode(reflections));
  }

  // 회고 불러오기
  static List<Map<String, dynamic>> getReflections() {
    final reflectionsString = prefs.getString('reflections');
    if (reflectionsString == null) return [];

    try {
      final List<dynamic> reflectionsList = jsonDecode(reflectionsString);
      return reflectionsList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // 모든 데이터 초기화
  static Future<void> clearAll() async {
    await prefs.clear();
  }
}
