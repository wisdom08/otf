import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/goal_service.dart';
import '../pages/goal/monthly_goal_detail_page.dart';
import 'reflection_dialog.dart';

class HierarchicalGoalCard extends StatefulWidget {
  final Goal goal;
  final List<Goal> subGoals;
  final Function(String) onGoalCompleted;
  final Function(String) onTimeTrackingToggled;
  final VoidCallback? onDataChanged; // 데이터 변경 시 UI 새로고침용
  final int level; // 계층 레벨 (들여쓰기용)

  const HierarchicalGoalCard({
    super.key,
    required this.goal,
    required this.subGoals,
    required this.onGoalCompleted,
    required this.onTimeTrackingToggled,
    this.onDataChanged,
    this.level = 0,
  });

  @override
  State<HierarchicalGoalCard> createState() => _HierarchicalGoalCardState();
}

class _HierarchicalGoalCardState extends State<HierarchicalGoalCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // 월간 목표는 기본적으로 펼쳐진 상태로 시작
    if (widget.goal.type == GoalType.monthly) {
      _isExpanded = true;
    }
  }

  @override
  void didUpdateWidget(HierarchicalGoalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 목표 상태가 변경되면 UI 업데이트
    if (oldWidget.goal.isCompleted != widget.goal.isCompleted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final double indent = widget.level * 20.w; // 레벨에 따른 들여쓰기

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메인 목표 카드
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: _buildMainGoalCard(),
        ),

        // 하위 목표들 (접기/펼치기 가능)
        if (widget.subGoals.isNotEmpty) ...[
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: widget.subGoals.map((subGoal) {
                return HierarchicalGoalCard(
                  goal: subGoal,
                  subGoals: GoalService.getSubGoals(subGoal.id),
                  onGoalCompleted: widget.onGoalCompleted,
                  onTimeTrackingToggled: widget.onTimeTrackingToggled,
                  onDataChanged: widget.onDataChanged,
                  level: widget.level + 1,
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMainGoalCard() {
    final isTracking = GoalService.isTimeTrackingActive(widget.goal.id);
    final currentTrackingSeconds = GoalService.getCurrentTrackingSeconds(
      widget.goal.id,
    );
    final totalWithCurrent = GoalService.getTotalTimeWithCurrent(
      widget.goal.id,
    );
    final totalWithCurrentFormatted = GoalService.formatDuration(
      totalWithCurrent,
    );

    return GestureDetector(
      onTap: _handleGoalTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              _getTypeColor(widget.goal.type).withOpacity(0.05),
            ],
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
            color: _getTypeColor(widget.goal.type).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 계층선 (하위 목표에만)
                  if (widget.level > 0)
                    Container(
                      width: 2.w,
                      height: 24.h,
                      color: _getTypeColor(widget.goal.type).withOpacity(0.5),
                      margin: EdgeInsets.only(right: 8.w),
                    ),

                  // 접기/펼치기 버튼 (하위 목표가 있는 경우)
                  if (widget.subGoals.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: _getTypeColor(
                            widget.goal.type,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 16.sp,
                          color: _getTypeColor(widget.goal.type),
                        ),
                      ),
                    ),

                  if (widget.subGoals.isNotEmpty) SizedBox(width: 8.w),

                  // 목표 타입 아이콘
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: _getTypeColor(widget.goal.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: _getTypeColor(widget.goal.type).withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      _getTypeIcon(widget.goal.type),
                      color: _getTypeColor(widget.goal.type),
                      size: 18.sp,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // 목표 제목과 설명
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.goal.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (widget.goal.description.isNotEmpty)
                          Text(
                            widget.goal.description,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // 액션 버튼들
                  GestureDetector(
                    onTap: () {}, // Empty onTap to consume tap events
                    child: Column(
                      children: [
                        // 시간 추적 버튼 (오늘의 목표만)
                        if (widget.goal.type == GoalType.daily)
                          Container(
                            decoration: BoxDecoration(
                              color: isTracking
                                  ? Colors.red[50]
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isTracking
                                    ? Colors.red[200]!
                                    : Colors.green[200]!,
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                isTracking
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: isTracking
                                    ? Colors.red[600]
                                    : Colors.green[600],
                                size: 24.sp,
                              ),
                              onPressed: () {
                                widget.onTimeTrackingToggled(widget.goal.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isTracking
                                          ? '시간 기록을 중지했습니다'
                                          : '시간 기록을 시작했습니다',
                                    ),
                                    backgroundColor: isTracking
                                        ? Colors.red[600]
                                        : Colors.green[600],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        SizedBox(height: 8.h),
                        // 완료 버튼
                        Container(
                          decoration: BoxDecoration(
                            color: widget.goal.isCompleted
                                ? Colors.green[50]
                                : Colors.indigo[50],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: widget.goal.isCompleted
                                  ? Colors.green[200]!
                                  : Colors.indigo[200]!,
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              widget.goal.isCompleted
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color: widget.goal.isCompleted
                                  ? Colors.green[600]
                                  : Colors.red[600],
                              size: 24.sp,
                            ),
                            onPressed: () {
                              if (widget.goal.isCompleted) {
                                // 완료된 목표는 바로 미완료 처리 (회고 팝업 없음)
                                widget.onGoalCompleted(widget.goal.id);
                              } else {
                                // 계층적 완료 조건 확인
                                if (GoalService.canCompleteGoal(
                                  widget.goal.id,
                                )) {
                                  _showReflectionDialog();
                                } else {
                                  _showCannotCompleteDialog();
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 시간 정보 표시 (오늘의 목표만)
              if (widget.goal.type == GoalType.daily) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 6.w),
                      if (widget.goal.targetMinutes > 0) ...[
                        Text(
                          '목표: ${GoalService.formatDuration(widget.goal.targetMinutes)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        '진행: $totalWithCurrentFormatted',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isTracking
                              ? Colors.green[600]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isTracking && currentTrackingSeconds > 0) ...[
                        SizedBox(width: 4.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '+${GoalService.formatDurationWithSeconds(currentTrackingSeconds)}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.red[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              SizedBox(height: 12.h),

              // 진행률 바
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor:
                      widget.goal.type == GoalType.daily &&
                          widget.goal.targetMinutes > 0
                      ? widget.goal.timeProgress
                      : widget.goal.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getTypeColor(widget.goal.type),
                          _getTypeColor(widget.goal.type).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ),

              // 시간 기록 중 표시 (오늘의 목표만)
              if (isTracking && widget.goal.type == GoalType.daily) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[50]!, Colors.red[100]!],
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red[200]!, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, size: 14.sp, color: Colors.red[600]),
                      SizedBox(width: 6.w),
                      Text(
                        '시간 기록 중... ${GoalService.formatDurationWithSeconds(currentTrackingSeconds)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleGoalTap() {
    if (widget.goal.type == GoalType.monthly) {
      // 월간 목표는 상세페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MonthlyGoalDetailPage(monthlyGoal: widget.goal),
        ),
      );
    } else if (widget.goal.type == GoalType.weekly) {
      // 주간 목표는 접기/펼치기 토글
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
    // 일간 목표는 아무것도 하지 않음 (시간 추적 버튼으로 처리)
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

  IconData _getTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.monthly:
        return Icons.calendar_month;
      case GoalType.weekly:
        return Icons.date_range;
      case GoalType.daily:
        return Icons.today;
    }
  }

  // 완료할 수 없다는 다이얼로그 표시
  void _showCannotCompleteDialog() {
    String title = '완료할 수 없습니다';
    String message = '';
    List<Widget> contentWidgets = [];

    switch (widget.goal.type) {
      case GoalType.weekly:
        final incompleteDailyGoals = widget.subGoals
            .where((goal) => goal.type == GoalType.daily && !goal.isCompleted)
            .toList();

        message = '모든 일간 목표를 완료해야 주간 목표를 완료할 수 있습니다.';
        contentWidgets = [
          Text(message),
          const SizedBox(height: 16),
          const Text(
            '미완료된 일간 목표:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...incompleteDailyGoals.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text('• ${goal.title}'),
            ),
          ),
        ];
        break;

      case GoalType.monthly:
        final incompleteWeeklyGoals = widget.subGoals
            .where((goal) => goal.type == GoalType.weekly && !goal.isCompleted)
            .toList();

        message = '모든 주간 목표와 그 하위 일간 목표를 완료해야 월간 목표를 완료할 수 있습니다.';
        contentWidgets = [
          Text(message),
          const SizedBox(height: 16),
          const Text(
            '미완료된 주간 목표:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...incompleteWeeklyGoals.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text('• ${goal.title}'),
            ),
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

  // 회고 다이얼로그 표시
  void _showReflectionDialog() {
    showDialog(
      context: context,
      builder: (context) => ReflectionDialog(
        goal: widget.goal,
        onReflectionAdded: () {
          // ReflectionDialog에서 이미 목표 완료 처리를 했으므로
          // UI 업데이트만 위해 콜백 호출
          if (widget.onDataChanged != null) {
            widget.onDataChanged!();
          }
        },
      ),
    );
  }
}
