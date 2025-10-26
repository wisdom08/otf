import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../../services/local_storage_service.dart';
import '../../../services/goal_service.dart';
import '../goal/goal_creation_wizard.dart';
import '../goal/monthly_goal_detail_page.dart';
import '../feed/feed_page.dart';
import '../profile/profile_page.dart';
import '../reflection/reflection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Goal> _goals = [];
  int _streak = 0;
  Timer? _timer;
  final GlobalKey<_GoalTabState> _goalTabKey = GlobalKey<_GoalTabState>();
  final GlobalKey<ProfilePageState> _profilePageKey =
      GlobalKey<ProfilePageState>();

  @override
  void initState() {
    super.initState();
    _loadData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // 시간 기록 중인 목표가 있으면 UI 업데이트
      bool hasActiveTracking = _goals.any(
        (goal) =>
            goal.type == GoalType.daily &&
            GoalService.isTimeTrackingActive(goal.id),
      );

      if (hasActiveTracking) {
        setState(() {});
      }
    });
  }

  Future<void> _loadData() async {
    await LocalStorageService.init();
    setState(() {
      _goals = GoalService.getGoals();
      _streak = LocalStorageService.getStreak();
    });

    // 목표 탭과 프로필 페이지도 새로고침 (다음 프레임에서 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_goalTabKey.currentState != null) {
        _goalTabKey.currentState!._loadGoals();
      }
      if (_profilePageKey.currentState != null) {
        _profilePageKey.currentState!.refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(
            goals: _goals,
            streak: _streak,
            onGoalAdded: _addGoal,
            onGoalCompleted: _completeGoal,
            onTimeTrackingToggled: _toggleTimeTracking,
            onRefresh: _loadData,
          ),
          GoalTab(key: _goalTabKey, onGoalChanged: _loadData),
          const FeedPage(),
          ReflectionPage(onReflectionAdded: _loadData),
          ProfilePage(key: _profilePageKey),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag),
            label: '목표',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: '피드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_outlined),
            activeIcon: Icon(Icons.edit_note),
            label: '회고',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }

  Future<void> _addGoal(
    String title,
    String description,
    GoalType type, {
    int targetMinutes = 0,
    String? parentGoalId,
    int? targetYear,
    int? targetMonth,
    int? targetWeek,
    GoalPrivacy privacy = GoalPrivacy.private,
  }) async {
    await GoalService.addGoal(
      title,
      description,
      type,
      targetMinutes: targetMinutes,
      parentGoalId: parentGoalId,
      targetYear: targetYear,
      targetMonth: targetMonth,
      targetWeek: targetWeek,
      privacy: privacy,
    );
    await _loadData();
  }

  Future<void> _completeGoal(String goalId) async {
    await GoalService.completeGoal(goalId);
    await _loadData();

    // 진행률 업데이트를 위해 추가 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _goals = GoalService.getGoals();
      });
      if (_goalTabKey.currentState != null) {
        _goalTabKey.currentState!._loadGoals();
      }
      if (_profilePageKey.currentState != null) {
        _profilePageKey.currentState!.refreshData();
      }
    });
  }

  Future<void> _toggleTimeTracking(String goalId) async {
    if (GoalService.isTimeTrackingActive(goalId)) {
      await GoalService.stopTimeTracking(goalId);
    } else {
      await GoalService.startTimeTracking(goalId);
    }
    await _loadData();
  }
}

class HomeTab extends StatelessWidget {
  final List<Goal> goals;
  final int streak;
  final Function(
    String,
    String,
    GoalType, {
    int targetMinutes,
    String? parentGoalId,
    int? targetYear,
    int? targetMonth,
    int? targetWeek,
    GoalPrivacy privacy,
  })
  onGoalAdded;
  final Function(String) onGoalCompleted;
  final Function(String) onTimeTrackingToggled;
  final VoidCallback onRefresh;

  const HomeTab({
    super.key,
    required this.goals,
    required this.streak,
    required this.onGoalAdded,
    required this.onGoalCompleted,
    required this.onTimeTrackingToggled,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          '💪WE GROW!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: onRefresh),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak 위젯
            _buildStreakCard(),
            SizedBox(height: 24.h),

            // 오늘의 목표 섹션
            const Text(
              '오늘의 목표는?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),

            // 목표 추가 버튼
            _buildAddGoalButton(context),
            SizedBox(height: 24.h),

            // 진행 중인 목표
            const Text(
              '진행 중인 목표',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),

            // 목표 리스트
            _buildGoalList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '연속 달성',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$streak일',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.white.withOpacity(0.9),
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  '화이팅! 계속해서 목표를 달성해보세요 🔥',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddGoalButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo.withOpacity(0.3), width: 2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showGoalCreationOptions(context),
          borderRadius: BorderRadius.circular(12.r),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.indigo, size: 20),
                SizedBox(width: 8),
                Text(
                  '새 목표 추가하기',
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalList(BuildContext context) {
    if (goals.isEmpty) {
      return const Center(
        child: Text(
          '아직 목표가 없습니다.\n새 목표를 추가해보세요!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // 월간 목표만 표시
    final monthlyGoals = goals
        .where((g) => g.type == GoalType.monthly)
        .toList();

    if (monthlyGoals.isEmpty) {
      return const Center(
        child: Text(
          '월간 목표를 먼저 생성해주세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // 월간 목표만 표시 (하위 목표는 상세페이지에서만)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGoalSectionHeader('월간 목표', monthlyGoals.length, Colors.purple),
        SizedBox(height: 8.h),
        ...monthlyGoals.map(
          (monthlyGoal) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildMonthlyGoalCard(context, monthlyGoal),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyGoalCard(BuildContext context, Goal monthlyGoal) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MonthlyGoalDetailPage(
              monthlyGoal: monthlyGoal,
              onGoalChanged: onRefresh,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.purple.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.purple.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: Colors.purple,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthlyGoal.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (monthlyGoal.description.isNotEmpty)
                        Text(
                          monthlyGoal.description,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16.sp,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3.r),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: monthlyGoal.progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.purple.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '진행률: ${(monthlyGoal.progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$title ($count)',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getTypeLabel(GoalType type) {
    switch (type) {
      case GoalType.monthly:
        return '한 달';
      case GoalType.weekly:
        return '일주일';
      case GoalType.daily:
        return '오늘';
    }
  }

  void _showGoalCreationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '목표 생성 방법을 선택하세요',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),

            // 마법사로 생성
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: Colors.purple),
              title: const Text('목표 설정 마법사'),
              subtitle: const Text('한 달 → 일주일 → 오늘의 목표를 단계별로 설정'),
              onTap: () {
                Navigator.pop(context);
                _openGoalWizard(context);
              },
            ),

            // 개별 목표 생성
            ListTile(
              leading: const Icon(Icons.add, color: Colors.indigo),
              title: const Text('개별 목표 추가'),
              subtitle: const Text('하나의 목표만 빠르게 추가'),
              onTap: () {
                Navigator.pop(context);
                _showAddGoalDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openGoalWizard(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const GoalCreationWizard()),
    );

    if (result == true) {
      // 목표가 성공적으로 생성되었으므로 데이터 새로고침
      onRefresh();
    }
  }

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetMinutesController = TextEditingController();
    GoalType selectedType = GoalType.daily;
    String? parentGoalId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('새 목표 추가'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 목표 타입 선택
                DropdownButtonFormField<GoalType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: '목표 기간',
                    border: OutlineInputBorder(),
                  ),
                  items: GoalType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                      parentGoalId = null; // 타입 변경 시 상위 목표 초기화
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 상위 목표 선택 (일주일/하루 목표인 경우)
                if (selectedType != GoalType.monthly)
                  DropdownButtonFormField<String>(
                    value: parentGoalId,
                    decoration: InputDecoration(
                      labelText: selectedType == GoalType.weekly
                          ? '월간 목표 선택'
                          : '주간 목표 선택',
                      border: const OutlineInputBorder(),
                    ),
                    items:
                        GoalService.getGoalsByType(
                          selectedType == GoalType.weekly
                              ? GoalType.monthly
                              : GoalType.weekly,
                        ).map((goal) {
                          return DropdownMenuItem(
                            value: goal.id,
                            child: Text(goal.title),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        parentGoalId = value;
                      });
                    },
                  ),
                const SizedBox(height: 16),

                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '목표 제목',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '목표 설명',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: targetMinutesController,
                  decoration: const InputDecoration(
                    labelText: '목표 시간 (분) - 선택사항',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final targetMinutes =
                      int.tryParse(targetMinutesController.text) ?? 0;
                  onGoalAdded(
                    titleController.text,
                    descriptionController.text,
                    selectedType,
                    targetMinutes: targetMinutes,
                    parentGoalId: parentGoalId,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('목표가 추가되었습니다!')));
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalTab extends StatefulWidget {
  final VoidCallback? onGoalChanged; // 목표 변경 시 콜백

  const GoalTab({super.key, this.onGoalChanged});

  @override
  State<GoalTab> createState() => _GoalTabState();
}

class _GoalTabState extends State<GoalTab> {
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _goals = GoalService.getGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthlyGoals = _goals
        .where((g) => g.type == GoalType.monthly)
        .toList();
    final weeklyGoals = _goals.where((g) => g.type == GoalType.weekly).toList();
    final dailyGoals = _goals.where((g) => g.type == GoalType.daily).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          '목표 대시보드',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGoals),
        ],
      ),
      body: _goals.isEmpty
          ? const Center(
              child: Text(
                '아직 목표가 없습니다.\n새 목표를 추가해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 월간 목표 섹션
                  if (monthlyGoals.isNotEmpty) ...[
                    _buildSectionHeader(
                      '월간 목표',
                      monthlyGoals.length,
                      Colors.purple,
                    ),
                    SizedBox(height: 12.h),
                    ...monthlyGoals.map(
                      (goal) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildGoalCard(goal, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MonthlyGoalDetailPage(
                                monthlyGoal: goal,
                                onGoalChanged: widget.onGoalChanged,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // 주간 목표 섹션
                  if (weeklyGoals.isNotEmpty) ...[
                    _buildSectionHeader(
                      '주간 목표',
                      weeklyGoals.length,
                      Colors.blue,
                    ),
                    SizedBox(height: 12.h),
                    ...weeklyGoals.map(
                      (goal) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildGoalCard(goal, null),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // 오늘의 목표 섹션
                  if (dailyGoals.isNotEmpty) ...[
                    _buildSectionHeader(
                      '오늘의 목표',
                      dailyGoals.length,
                      Colors.green,
                    ),
                    SizedBox(height: 12.h),
                    ...dailyGoals.map(
                      (goal) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildGoalCard(goal, null),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$title ($count)',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(Goal goal, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [Colors.white, _getTypeColor(goal.type).withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: _getTypeColor(goal.type).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: _getTypeColor(goal.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: _getTypeColor(goal.type).withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    _getTypeIcon(goal.type),
                    color: _getTypeColor(goal.type),
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (goal.description.isNotEmpty)
                        Text(
                          goal.description,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                    ],
                  ),
                ),
                if (goal.type == GoalType.monthly)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16.sp,
                  ),
                if (goal.type != GoalType.monthly)
                  Icon(
                    goal.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: goal.isCompleted ? Colors.green : Colors.grey[400],
                    size: 20.sp,
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3.r),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: goal.progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getTypeColor(goal.type),
                        _getTypeColor(goal.type).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '진행률: ${(goal.progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (goal.isCompleted)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      '완료',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.monthly:
        return Icons.calendar_month;
      case GoalType.weekly:
        return Icons.calendar_view_week;
      case GoalType.daily:
        return Icons.check_circle_outline;
    }
  }

  Color _getTypeColor(GoalType type) {
    switch (type) {
      case GoalType.monthly:
        return Colors.purple;
      case GoalType.weekly:
        return Colors.blue;
      case GoalType.daily:
        return Colors.green;
    }
  }
}

class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '피드 탭',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
