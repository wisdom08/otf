class AppConstants {
  // 앱 정보
  static const String appName = 'OTF';
  static const String appVersion = '1.0.0';

  // 시간 관련
  static const int dayStartHour = 6; // 하루 시작 시간 (06:00)
  static const int dayEndHour = 3; // 하루 종료 시간 (03:00)

  // 목표 관련
  static const int maxDailyGoals = 10; // 하루 최대 목표 수
  static const int maxMonthlyGoals = 5; // 월간 최대 목표 수

  // 피드 관련
  static const int feedPageSize = 20; // 피드 페이지 크기
  static const int maxFeedItems = 50; // 최대 피드 아이템 수

  // Streak 관련
  static const List<int> streakMilestones = [
    3,
    7,
    14,
    30,
    60,
    100,
  ]; // Streak 마일스톤

  // 공유 범위
  static const String visibilityPublic = 'public';
  static const String visibilityFriends = 'friends';
  static const String visibilityPrivate = 'private';

  // 목표 타입
  static const String goalTypeMonthly = 'monthly';
  static const String goalTypeWeekly = 'weekly';
  static const String goalTypeDaily = 'daily';

  // 회고 타입
  static const String reflectionTypeText = 'text';
  static const String reflectionTypeKpt = 'kpt';
  static const String reflectionTypeEmoji = 'emoji';

  // 친구 관계 상태
  static const String friendStatusPending = 'pending';
  static const String friendStatusAccepted = 'accepted';
  static const String friendStatusBlocked = 'blocked';

  // 알림 타입
  static const String notificationTypeGoalCompleted = 'goal_completed';
  static const String notificationTypeComment = 'comment';
  static const String notificationTypeReaction = 'reaction';

  // 이모지 점수
  static const List<String> emojiScores = ['😫', '😕', '😐', '🙂', '😄'];
  static const List<String> reactionEmojis = ['👍', '❤️', '💪', '🌟', '🎉'];

  // 애니메이션 지속 시간
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // 네트워크 타임아웃
  static const Duration networkTimeout = Duration(seconds: 10);
  static const Duration networkConnectTimeout = Duration(seconds: 5);
}
