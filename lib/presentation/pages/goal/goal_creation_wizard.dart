import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/goal_service.dart';

class GoalCreationWizard extends StatefulWidget {
  const GoalCreationWizard({super.key});

  @override
  State<GoalCreationWizard> createState() => _GoalCreationWizardState();
}

class _GoalCreationWizardState extends State<GoalCreationWizard> {
  int _currentStep = 0;

  // 월간 목표 데이터
  String _monthlyTitle = '';
  String _monthlyDescription = '';
  int _monthlyTargetMinutes = 0;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  GoalPrivacy _monthlyPrivacy = GoalPrivacy.private;

  // 주간 목표 데이터
  List<WeeklyGoalData> _weeklyGoals = [];
  int _selectedWeek = 1; // 선택된 주 (1-4)

  // 하루 목표 데이터
  List<DailyGoalData> _dailyGoals = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          '목표 설정 마법사',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 진행률 표시
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
          ),
          SizedBox(height: 16.h),

          // 단계별 내용
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildMonthlyGoalStep(),
                _buildWeeklyGoalsStep(),
                _buildDailyGoalsStep(),
                _buildSummaryStep(),
              ],
            ),
          ),

          // 네비게이션 버튼
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton(onPressed: _previousStep, child: const Text('이전'))
                else
                  const SizedBox.shrink(),

                if (_currentStep < 3)
                  ElevatedButton(
                    onPressed: _canProceedToNext() ? _nextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canProceedToNext()
                          ? Colors.indigo
                          : Colors.grey,
                    ),
                    child: Text(
                      _canProceedToNext()
                          ? '다음 (${_currentStep + 1}/4)'
                          : '입력 필요',
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _createGoals,
                    child: const Text('목표 생성'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyGoalStep() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1단계: 월간 목표 설정',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '이번 달에 달성하고 싶은 큰 목표를 설정해주세요.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 24.h),

            // 년월 선택
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: '년도',
                      labelStyle: TextStyle(color: Colors.black87),
                      border: OutlineInputBorder(),
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(
                          '$year년',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: '월',
                      labelStyle: TextStyle(color: Colors.black87),
                      border: OutlineInputBorder(),
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child: Text(
                          '$month월',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 공개 설정
            DropdownButtonFormField<GoalPrivacy>(
              value: _monthlyPrivacy,
              decoration: const InputDecoration(
                labelText: '공개 설정',
                labelStyle: TextStyle(color: Colors.black87),
                border: OutlineInputBorder(),
                helperText: '목표를 누구와 공유할지 선택하세요',
                helperStyle: TextStyle(color: Colors.grey),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              items: GoalPrivacy.values.map((privacy) {
                return DropdownMenuItem(
                  value: privacy,
                  child: Row(
                    children: [
                      Icon(
                        GoalService.getPrivacyIcon(privacy),
                        size: 16.sp,
                        color: _getPrivacyColor(privacy),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        GoalService.getPrivacyLabel(privacy),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _monthlyPrivacy = value!;
                });
              },
            ),
            SizedBox(height: 16.h),

            TextField(
              key: const ValueKey('monthly_title'),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '월간 목표 제목',
                labelStyle: const TextStyle(color: Colors.white),
                hintText: '예: Flutter 앱 개발 완성하기',
                hintStyle: const TextStyle(color: Colors.grey),
                border: const OutlineInputBorder(),
                suffixIcon: _monthlyTitle.isNotEmpty
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.error_outline, color: Colors.red),
              ),
              onChanged: (value) {
                setState(() {
                  _monthlyTitle = value.trim();
                });
              },
            ),
            SizedBox(height: 16.h),

            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '목표 설명',
                labelStyle: TextStyle(color: Colors.black87),
                hintText: '구체적인 목표 내용을 작성해주세요',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _monthlyDescription = value;
                });
              },
            ),
            SizedBox(height: 16.h),

            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '목표 시간 (분) - 선택사항',
                labelStyle: TextStyle(color: Colors.black87),
                hintText: '예: 120 (2시간)',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _monthlyTargetMinutes = int.tryParse(value) ?? 0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyGoalsStep() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2단계: 주간 목표 설정',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '월간 목표를 달성하기 위한 주간 목표를 설정해주세요.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 24.h),

          // 주 선택
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '목표 주차 선택',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '주차를 선택하면 주간 목표를 추가할 수 있습니다',
                  style: TextStyle(fontSize: 12.sp, color: Colors.blue[600]),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: List.generate(4, (index) {
                    final week = index + 1;
                    final isSelected = _selectedWeek == week;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print('주차 $week 선택됨');
                          setState(() {
                            _selectedWeek = week;
                          });
                          // 주차 선택 시 주간 목표 추가 팝업 표시
                          print('주간 목표 추가 팝업 호출');
                          _showWeeklyGoalDialog();
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[600] : Colors.white,
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
              ],
            ),
          ),
          SizedBox(height: 16.h),

          Expanded(
            child: ListView.builder(
              itemCount: _weeklyGoals.length,
              itemBuilder: (context, index) {
                final weeklyGoal = _weeklyGoals[index];
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                weeklyGoal.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeWeeklyGoal(index),
                            ),
                          ],
                        ),
                        if (weeklyGoal.description.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            weeklyGoal.description,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                        if (weeklyGoal.targetMinutes > 0) ...[
                          SizedBox(height: 4.h),
                          Text(
                            '목표 시간: ${GoalService.formatDuration(weeklyGoal.targetMinutes)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalsStep() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3단계: 오늘의 목표 설정',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '주간 목표를 달성하기 위한 오늘의 목표를 설정해주세요.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 24.h),

          Expanded(
            child: ListView.builder(
              itemCount: _dailyGoals.length + 1,
              itemBuilder: (context, index) {
                if (index == _dailyGoals.length) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.add, color: Colors.indigo),
                      title: const Text('오늘의 목표 추가'),
                      onTap: _addDailyGoal,
                    ),
                  );
                }

                final dailyGoal = _dailyGoals[index];
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dailyGoal.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeDailyGoal(index),
                            ),
                          ],
                        ),
                        if (dailyGoal.description.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            dailyGoal.description,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                        if (dailyGoal.targetMinutes > 0) ...[
                          SizedBox(height: 4.h),
                          Text(
                            '목표 시간: ${GoalService.formatDuration(dailyGoal.targetMinutes)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '4단계: 목표 확인',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '설정한 목표들을 확인하고 생성해주세요.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 24.h),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 월간 목표
                  _buildSummaryCard(
                    '월간 목표',
                    _monthlyTitle,
                    _monthlyDescription,
                    _monthlyTargetMinutes,
                    Colors.purple,
                  ),

                  SizedBox(height: 16.h),

                  // 주간 목표들
                  Text(
                    '주간 목표 (${_weeklyGoals.length}개)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8.h),

                  ..._weeklyGoals.asMap().entries.map((entry) {
                    final index = entry.key;
                    final goal = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _buildSummaryCard(
                        'week${index + 1}',
                        goal.title,
                        goal.description,
                        goal.targetMinutes,
                        Colors.blue,
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 16.h),

                  // 오늘의 목표들
                  Text(
                    '오늘의 목표 (${_dailyGoals.length}개)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8.h),

                  ..._dailyGoals.asMap().entries.map((entry) {
                    final index = entry.key;
                    final goal = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _buildSummaryCard(
                        '오늘 ${index + 1}',
                        goal.title,
                        goal.description,
                        goal.targetMinutes,
                        Colors.green,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String period,
    String title,
    String description,
    int targetMinutes,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (description.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
            ),
          ],
          if (targetMinutes > 0) ...[
            SizedBox(height: 2.h),
            Text(
              '목표 시간: ${GoalService.formatDuration(targetMinutes)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
            ),
          ],
        ],
      ),
    );
  }

  bool _canProceedToNext() {
    bool canProceed = false;
    switch (_currentStep) {
      case 0:
        canProceed = _monthlyTitle.isNotEmpty;
        print(
          'Step 0: monthlyTitle="${_monthlyTitle}", canProceed=$canProceed',
        );
        break;
      case 1:
        canProceed = _weeklyGoals.isNotEmpty;
        print(
          'Step 1: weeklyGoals.length=${_weeklyGoals.length}, canProceed=$canProceed',
        );
        break;
      case 2:
        canProceed = _dailyGoals.isNotEmpty;
        print(
          'Step 2: dailyGoals.length=${_dailyGoals.length}, canProceed=$canProceed',
        );
        break;
      default:
        canProceed = true;
        break;
    }
    return canProceed;
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _showWeeklyGoalDialog() {
    print('_showWeeklyGoalDialog 메서드 호출됨');
    _showGoalDialog('week$_selectedWeek 주간 목표 추가', (
      title,
      description,
      targetMinutes,
    ) {
      print('주간 목표 추가됨: $title');
      setState(() {
        _weeklyGoals.add(
          WeeklyGoalData(
            title: title,
            description: description,
            targetMinutes: targetMinutes,
          ),
        );
      });
    });
  }

  void _removeWeeklyGoal(int index) {
    setState(() {
      _weeklyGoals.removeAt(index);
    });
  }

  void _addDailyGoal() {
    _showGoalDialog('오늘의 목표 추가', (title, description, targetMinutes) {
      setState(() {
        _dailyGoals.add(
          DailyGoalData(
            title: title,
            description: description,
            targetMinutes: targetMinutes,
          ),
        );
      });
    });
  }

  void _removeDailyGoal(int index) {
    setState(() {
      _dailyGoals.removeAt(index);
    });
  }

  void _showGoalDialog(String title, Function(String, String, int) onSave) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '목표 제목',
                labelStyle: TextStyle(color: Colors.black87),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '목표 설명',
                labelStyle: TextStyle(color: Colors.black87),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '목표 시간 (분) - 선택사항',
                labelStyle: TextStyle(color: Colors.black87),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final targetMinutes = int.tryParse(targetController.text) ?? 0;
                onSave(
                  titleController.text,
                  descriptionController.text,
                  targetMinutes,
                );
                Navigator.pop(context);
              }
            },
            child: const Text(
              '추가',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createGoals() async {
    try {
      // 월간 목표 생성
      await GoalService.addGoal(
        _monthlyTitle,
        _monthlyDescription,
        GoalType.monthly,
        targetMinutes: _monthlyTargetMinutes,
        targetYear: _selectedYear,
        targetMonth: _selectedMonth,
        privacy: _monthlyPrivacy,
      );

      final monthlyGoals = GoalService.getGoalsByType(GoalType.monthly);
      final monthlyGoalId = monthlyGoals.last.id;

      // 주간 목표들 생성
      for (final weeklyGoal in _weeklyGoals) {
        await GoalService.addGoal(
          weeklyGoal.title,
          weeklyGoal.description,
          GoalType.weekly,
          targetMinutes: weeklyGoal.targetMinutes,
          parentGoalId: monthlyGoalId,
          targetYear: _selectedYear,
          targetMonth: _selectedMonth,
          targetWeek: _selectedWeek,
          privacy: _monthlyPrivacy, // 월간 목표와 동일한 공개 설정
        );
      }

      // 오늘의 목표들 생성 (가장 최근에 생성된 주간 목표에 연결)
      final weeklyGoals = GoalService.getGoalsByType(GoalType.weekly);
      if (weeklyGoals.isNotEmpty) {
        final latestWeeklyGoal = weeklyGoals.last; // 가장 최근에 생성된 주간 목표
        for (final dailyGoal in _dailyGoals) {
          await GoalService.addGoal(
            dailyGoal.title,
            dailyGoal.description,
            GoalType.daily,
            targetMinutes: dailyGoal.targetMinutes,
            parentGoalId: latestWeeklyGoal.id,
            targetYear: _selectedYear,
            targetMonth: _selectedMonth,
            targetWeek: _selectedWeek,
            privacy: _monthlyPrivacy, // 월간 목표와 동일한 공개 설정
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // 성공적으로 생성됨을 알림
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('목표가 성공적으로 생성되었습니다! 🎉')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('목표 생성 중 오류가 발생했습니다: $e')));
      }
    }
  }
}

class WeeklyGoalData {
  final String title;
  final String description;
  final int targetMinutes;

  WeeklyGoalData({
    required this.title,
    required this.description,
    required this.targetMinutes,
  });
}

class DailyGoalData {
  final String title;
  final String description;
  final int targetMinutes;

  DailyGoalData({
    required this.title,
    required this.description,
    required this.targetMinutes,
  });
}

// Helper method for privacy color
Color _getPrivacyColor(GoalPrivacy privacy) {
  switch (privacy) {
    case GoalPrivacy.private:
      return Colors.grey;
    case GoalPrivacy.friends:
      return Colors.blue;
    case GoalPrivacy.public:
      return Colors.green;
  }
}
