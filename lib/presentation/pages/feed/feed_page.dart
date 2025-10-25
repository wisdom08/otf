import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/goal_service.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Goal> _feedGoals = [];
  GoalPrivacy? _selectedFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedGoals();
  }

  Future<void> _loadFeedGoals() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션

    setState(() {
      _feedGoals = GoalService.getFeedGoals();
      _isLoading = false;
    });
  }

  List<Goal> get _filteredGoals {
    if (_selectedFilter == null) {
      return _feedGoals;
    }
    return _feedGoals.where((goal) => goal.privacy == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('피드', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFeedGoals,
          ),
          PopupMenuButton<GoalPrivacy?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (privacy) {
              setState(() {
                _selectedFilter = privacy;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('전체')),
              const PopupMenuItem(
                value: GoalPrivacy.friends,
                child: Text('친구공개'),
              ),
              const PopupMenuItem(
                value: GoalPrivacy.public,
                child: Text('전체공개'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredGoals.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadFeedGoals,
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _filteredGoals.length,
                itemBuilder: (context, index) {
                  final goal = _filteredGoals[index];
                  return _buildFeedCard(goal);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            '아직 피드할 목표가 없습니다',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '친구를 추가하거나 전체공개 목표를 만들어보세요!',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              // 친구 추가 페이지로 이동 (추후 구현)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('친구 추가 기능은 곧 추가될 예정입니다!')),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text('친구 추가하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(Goal goal) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보 및 공개 설정
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: _getTypeColor(goal.type).withOpacity(0.1),
                  child: Icon(
                    _getTypeIcon(goal.type),
                    color: _getTypeColor(goal.type),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '사용자 ${goal.userId.substring(0, 8)}...', // 임시 사용자명
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        _getTimeAgo(goal.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getPrivacyColor(goal.privacy).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _getPrivacyColor(goal.privacy).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        GoalService.getPrivacyIcon(goal.privacy),
                        size: 12.sp,
                        color: _getPrivacyColor(goal.privacy),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        GoalService.getPrivacyLabel(goal.privacy),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: _getPrivacyColor(goal.privacy),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 목표 내용
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _getTypeColor(goal.type).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _getTypeColor(goal.type).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getTypeIcon(goal.type),
                        color: _getTypeColor(goal.type),
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _getTypeLabel(goal.type),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _getTypeColor(goal.type),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (goal.description.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      goal.description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // 진행률 및 상태
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '진행률: ${(goal.progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2.r),
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
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12.sp,
                          color: Colors.green[600],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '완료',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // 액션 버튼들
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // 좋아요 기능 (추후 구현)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('좋아요 기능은 곧 추가될 예정입니다!')),
                      );
                    },
                    icon: const Icon(Icons.favorite_border, size: 16),
                    label: const Text('좋아요'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // 댓글 기능 (추후 구현)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('댓글 기능은 곧 추가될 예정입니다!')),
                      );
                    },
                    icon: const Icon(Icons.comment_outlined, size: 16),
                    label: const Text('댓글'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // 공유 기능 (추후 구현)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('공유 기능은 곧 추가될 예정입니다!')),
                      );
                    },
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('공유'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
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

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
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

  String _getTypeLabel(GoalType type) {
    switch (type) {
      case GoalType.monthly:
        return '월간 목표';
      case GoalType.weekly:
        return '주간 목표';
      case GoalType.daily:
        return '오늘의 목표';
    }
  }

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
}
