import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/goal_service.dart';
import '../../widgets/hierarchical_goal_card.dart';

class MonthlyGoalDetailPage extends StatefulWidget {
  final Goal monthlyGoal;

  const MonthlyGoalDetailPage({super.key, required this.monthlyGoal});

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
                        : Colors.indigo[600],
                    size: 24.sp,
                  ),
                  onPressed: _currentMonthlyGoal.isCompleted
                      ? null
                      : () {
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
          title: const Text('하위 목표 추가'),
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
                  items: [
                    DropdownMenuItem(
                      value: GoalType.weekly,
                      child: Text(_getTypeLabel(GoalType.weekly)),
                    ),
                    DropdownMenuItem(
                      value: GoalType.daily,
                      child: Text(_getTypeLabel(GoalType.daily)),
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
                      color: Colors.blue[800],
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
                                    : Colors.blue[600],
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
                      border: OutlineInputBorder(),
                    ),
                    items: GoalService.getGoalsByType(GoalType.weekly)
                        .where(
                          (goal) => goal.parentGoalId == _currentMonthlyGoal.id,
                        )
                        .map((goal) {
                          return DropdownMenuItem(
                            value: goal.id,
                            child: Text(goal.title),
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
              child: const Text('추가'),
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
    await GoalService.completeGoal(goalId);
    _loadSubGoals();
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
