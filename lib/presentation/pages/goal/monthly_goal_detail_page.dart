import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/goal_service.dart';
import '../../widgets/hierarchical_goal_card.dart';
import '../../widgets/reflection_dialog.dart';

class MonthlyGoalDetailPage extends StatefulWidget {
  final Goal monthlyGoal;
  final VoidCallback? onGoalChanged; // 목표 변경 시 콜백

  const MonthlyGoalDetailPage({
    super.key,
    required this.monthlyGoal,
    this.onGoalChanged,
  });

  @override
  State<MonthlyGoalDetailPage> createState() => _MonthlyGoalDetailPageState();
}

class _MonthlyGoalDetailPageState extends State<MonthlyGoalDetailPage> {
  List<Goal> _subGoals = [];
  late Goal _currentMonthlyGoal;

  @override
  void initState() {
    super.initState();
    _currentMonthlyGoal = widget.monthlyGoal;
    _loadSubGoals();
  }

  void _loadSubGoals() {
    setState(() {
      _subGoals = GoalService.getSubGoals(_currentMonthlyGoal.id);

      // 월간 목표의 최신 상태도 업데이트
      final updatedGoals = GoalService.getGoals();
      final updatedMonthlyGoal = updatedGoals.firstWhere(
        (goal) => goal.id == _currentMonthlyGoal.id,
        orElse: () => _currentMonthlyGoal,
      );
      _currentMonthlyGoal = updatedMonthlyGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentMonthlyGoal.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSubGoals),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 월간 목표 정보 카드
            _buildMonthlyGoalInfoCard(),
            SizedBox(height: 24.h),

            // 하위 목표 섹션
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '하위 목표 (${_subGoals.length})',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 하위 목표 리스트
            if (_subGoals.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 48.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '아직 하위 목표가 없습니다',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '주간 목표와 오늘의 목표를 추가해보세요!',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._subGoals.map(
                (goal) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: HierarchicalGoalCard(
                    goal: goal,
                    subGoals: GoalService.getSubGoals(goal.id),
                    onGoalCompleted: _completeGoal,
                    onTimeTrackingToggled: _toggleTimeTracking,
                    onDataChanged: _loadSubGoals,
                  ),
                ),
              ),

            SizedBox(height: 24.h),

            // 새 목표 추가 버튼
            _buildAddSubGoalButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyGoalInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.calendar_month,
                  size: 20.sp,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentMonthlyGoal.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '월간 목표',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _currentMonthlyGoal.isCompleted
                      ? Colors.green[50]
                      : Colors.indigo[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _currentMonthlyGoal.isCompleted
                        ? Colors.green[200]!
                        : Colors.indigo[200]!,
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    _currentMonthlyGoal.isCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: _currentMonthlyGoal.isCompleted
                        ? Colors.green[600]
                        : Colors.red[600],
                    size: 24.sp,
                  ),
                  onPressed: () {
                    _completeGoal(_currentMonthlyGoal.id);
                  },
                ),
              ),
            ],
          ),

          if (_currentMonthlyGoal.description.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              _currentMonthlyGoal.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],

          SizedBox(height: 16.h),

          // 진행률 바
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _currentMonthlyGoal.progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.purple.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // 진행률 텍스트
          Text(
            '진행률: ${(_currentMonthlyGoal.progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSubGoalButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddSubGoalDialog,
          borderRadius: BorderRadius.circular(12.r),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  '하위 목표 추가하기',
                  style: TextStyle(
                    color: Colors.blue,
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

  void _showAddSubGoalDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetMinutesController = TextEditingController();
    GoalType selectedType = GoalType.weekly;
    String? parentGoalId;
    int selectedWeek = 1; // 주차 선택 변수 추가

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            '하위 목표 추가',
            style: TextStyle(color: Colors.black87),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 목표 타입 선택
                DropdownButtonFormField<GoalType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: '목표 기간',
                    labelStyle: TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black87),
                  items: [
                    DropdownMenuItem(
                      value: GoalType.weekly,
                      child: Text(
                        _getTypeLabel(GoalType.weekly),
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    DropdownMenuItem(
                      value: GoalType.daily,
                      child: Text(
                        _getTypeLabel(GoalType.daily),
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                      parentGoalId = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // 주차 선택 (주간 목표인 경우)
                if (selectedType == GoalType.weekly) ...[
                  Text(
                    '주차 선택',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: List.generate(4, (index) {
                      final week = index + 1;
                      final isSelected = selectedWeek == week;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedWeek = week;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue[600]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue[600]!
                                    : Colors.blue[200]!,
                              ),
                            ),
                            child: Text(
                              'week$week',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16.h),
                ],

                // 상위 목표 선택 (오늘의 목표인 경우)
                if (selectedType == GoalType.daily)
                  DropdownButtonFormField<String>(
                    value: parentGoalId,
                    decoration: const InputDecoration(
                      labelText: '주간 목표 선택',
                      labelStyle: TextStyle(color: Colors.black87),
                      border: OutlineInputBorder(),
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black87),
                    items: GoalService.getGoalsByType(GoalType.weekly)
                        .where(
                          (goal) => goal.parentGoalId == _currentMonthlyGoal.id,
                        )
                        .map((goal) {
                          return DropdownMenuItem(
                            value: goal.id,
                            child: Text(
                              goal.title,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          );
                        })
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        parentGoalId = value;
                      });
                    },
                  ),
                const SizedBox(height: 16),

                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    labelText: '목표 제목',
                    labelStyle: TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    labelText: '목표 설명',
                    labelStyle: TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: targetMinutesController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    labelText: '목표 시간 (분) - 선택사항',
                    labelStyle: TextStyle(color: Colors.black87),
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
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final targetMinutes =
                      int.tryParse(targetMinutesController.text) ?? 0;
                  _addSubGoal(
                    titleController.text,
                    descriptionController.text,
                    selectedType,
                    targetMinutes: targetMinutes,
                    parentGoalId: selectedType == GoalType.weekly
                        ? _currentMonthlyGoal.id
                        : parentGoalId,
                    targetWeek: selectedType == GoalType.weekly
                        ? selectedWeek
                        : null,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('하위 목표가 추가되었습니다!')),
                  );
                }
              },
              child: const Text('추가', style: TextStyle(color: Colors.black87)),
            ),
          ],
        ),
      ),
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

  Future<void> _addSubGoal(
    String title,
    String description,
    GoalType type, {
    int targetMinutes = 0,
    String? parentGoalId,
    int? targetWeek,
  }) async {
    await GoalService.addGoal(
      title,
      description,
      type,
      targetMinutes: targetMinutes,
      parentGoalId: parentGoalId,
      targetWeek: targetWeek,
    );
    _loadSubGoals();
  }

  Future<void> _completeGoal(String goalId) async {
    // 목표의 현재 상태를 확인하여 완료/미완료 처리
    final goal = GoalService.getGoals().firstWhere(
      (g) => g.id == goalId,
      orElse: () => _currentMonthlyGoal,
    );

    if (goal.isCompleted) {
      // 이미 완료된 목표는 미완료 처리 (월간 목표는 회고 없이 바로 처리)
      await GoalService.uncompleteGoal(goalId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('목표가 미완료 상태로 변경되었습니다'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      // 계층적 완료 조건 확인
      if (GoalService.canCompleteGoal(goalId)) {
        _showReflectionDialog(goal);
      } else {
        _showCannotCompleteDialog(goal);
      }
    }

    _loadSubGoals();

    // 목표 변경 시 콜백 호출
    if (widget.onGoalChanged != null) {
      widget.onGoalChanged!();
    }
  }

  // 회고 다이얼로그 표시
  void _showReflectionDialog(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => ReflectionDialog(
        goal: goal,
        onReflectionAdded: () {
          // ReflectionDialog에서 이미 목표 완료 처리를 했으므로
          // UI 업데이트만 위해 데이터 새로고침
          _loadSubGoals();

          // 목표 변경 시 콜백 호출
          if (widget.onGoalChanged != null) {
            widget.onGoalChanged!();
          }
        },
      ),
    );
  }

  // 완료할 수 없다는 다이얼로그 표시
  void _showCannotCompleteDialog(Goal goal) {
    String title = '완료할 수 없습니다';
    String message = '';
    List<Widget> contentWidgets = [];

    switch (goal.type) {
      case GoalType.weekly:
        final incompleteDailyGoals = GoalService.getSubGoals(
          goal.id,
        ).where((g) => g.type == GoalType.daily && !g.isCompleted).toList();

        message = '모든 일간 목표를 완료해야 주간 목표를 완료할 수 있습니다.';
        contentWidgets = [
          Text(message),
          const SizedBox(height: 16),
          const Text(
            '미완료된 일간 목표:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...incompleteDailyGoals
              .take(5)
              .map(
                (g) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text('• ${g.title}'),
                ),
              ),
          if (incompleteDailyGoals.length > 5)
            Text(
              '... 외 ${incompleteDailyGoals.length - 5}개',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
        ];
        break;

      case GoalType.monthly:
        final incompleteWeeklyGoals = GoalService.getSubGoals(
          goal.id,
        ).where((g) => g.type == GoalType.weekly && !g.isCompleted).toList();

        message = '모든 주간 목표와 그 하위 일간 목표를 완료해야 월간 목표를 완료할 수 있습니다.';
        contentWidgets = [
          Text(message),
          const SizedBox(height: 16),
          const Text(
            '미완료된 주간 목표:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...incompleteWeeklyGoals
              .take(5)
              .map(
                (g) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Text('• ${g.title}'),
                ),
              ),
          if (incompleteWeeklyGoals.length > 5)
            Text(
              '... 외 ${incompleteWeeklyGoals.length - 5}개',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
        ];
        break;

      case GoalType.daily:
        // 일간 목표는 항상 완료 가능하므로 이 경우는 발생하지 않음
        return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: contentWidgets,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTimeTracking(String goalId) async {
    if (GoalService.isTimeTrackingActive(goalId)) {
      await GoalService.stopTimeTracking(goalId);
    } else {
      await GoalService.startTimeTracking(goalId);
    }
    _loadSubGoals();
  }
}
