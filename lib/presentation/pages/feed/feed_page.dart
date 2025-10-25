import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/goal_service.dart';
import '../friends/friends_page.dart';
import '../comments/comments_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Goal> _feedGoals = [];
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

    try {
      // 실제 데이터 로딩 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _feedGoals = GoalService.getFeedGoals();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('피드를 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 피드용 데이터 가져오기 (목표 + 회고)
  List<dynamic> get _feedItems {
    final List<dynamic> items = [];

    // 완료된 목표와 회고를 함께 표시
    for (final goal in _feedGoals) {
      if (goal.isCompleted) {
        // 목표 추가
        items.add(goal);

        // 해당 목표의 회고 추가
        final reflections = GoalService.getReflections(goal.id);
        for (final reflection in reflections) {
          items.add(reflection);
        }
      }
    }

    // 생성일 기준으로 정렬 (최신순)
    items.sort((a, b) {
      DateTime dateA, dateB;
      if (a is Goal) {
        dateA = a.createdAt;
      } else if (a is Reflection) {
        dateA = a.createdAt;
      } else {
        dateA = DateTime.now();
      }

      if (b is Goal) {
        dateB = b.createdAt;
      } else if (b is Reflection) {
        dateB = b.createdAt;
      } else {
        dateB = DateTime.now();
      }

      return dateB.compareTo(dateA);
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
              // 필터링 기능은 현재 사용하지 않음
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
          ? _buildLoadingState()
          : _feedItems.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadFeedGoals,
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _feedItems.length,
                itemBuilder: (context, index) {
                  final item = _feedItems[index];
                  if (item is Goal) {
                    return _buildFeedCard(item);
                  } else if (item is Reflection) {
                    return _buildReflectionCard(item);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.indigo, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            '피드를 불러오는 중...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '친구들의 목표를 확인해보세요',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FriendsPage()),
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
                _buildUserAvatar(goal),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '사용자 ${goal.userId.length > 8 ? goal.userId.substring(0, 8) + '...' : goal.userId}', // 임시 사용자명
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
            _buildActionButtons(goal),
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

  Widget _buildUserAvatar(Goal goal) {
    // 사용자 ID를 기반으로 고유한 색상 생성
    final userId = goal.userId;
    final colorIndex = userId.hashCode % _avatarColors.length;
    final avatarColor = _avatarColors[colorIndex];

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [avatarColor, avatarColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: avatarColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 20.r,
        backgroundColor: Colors.transparent,
        child: Text(
          userId.isNotEmpty ? userId.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 아바타용 색상 팔레트
  static const List<Color> _avatarColors = [
    Colors.indigo,
    Colors.purple,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
  ];

  Widget _buildActionButtons(Goal goal) {
    final likeCount = GoalService.getLikeCount(goal.id);
    final commentCount = GoalService.getCommentCount(goal.id);
    final shareCount = GoalService.getShareCount(goal.id);
    final isLiked = GoalService.hasUserLiked(goal.id);

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: '좋아요',
            count: likeCount,
            color: isLiked ? Colors.red : Colors.grey[600]!,
            onPressed: () => _toggleLike(goal.id),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildActionButton(
            icon: Icons.comment_outlined,
            label: '댓글',
            count: commentCount,
            color: Colors.grey[600]!,
            onPressed: () => _showCommentsPage(goal),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_outlined,
            label: '공유',
            count: shareCount,
            color: Colors.grey[600]!,
            onPressed: () => _shareGoal(goal),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12.sp),
          ),
          if (count > 0) ...[
            SizedBox(width: 4.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: color,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.3)),
        padding: EdgeInsets.symmetric(vertical: 8.h),
      ),
    );
  }

  Future<void> _toggleLike(String goalId) async {
    await GoalService.toggleLike(goalId);
    setState(() {}); // UI 업데이트
  }

  void _showCommentsPage(Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommentsPage(goal: goal)),
    ).then((_) {
      // 댓글 페이지에서 돌아왔을 때 UI 업데이트
      setState(() {});
    });
  }

  Future<void> _shareGoal(Goal goal) async {
    await GoalService.addSocialAction(goal.id, SocialActionType.share);
    setState(() {}); // UI 업데이트

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${goal.title}을(를) 공유했습니다!'),
        action: SnackBarAction(label: '확인', onPressed: () {}),
      ),
    );
  }

  // 회고 카드 빌드
  Widget _buildReflectionCard(Reflection reflection) {
    // 회고에 해당하는 목표 찾기
    final goal = _feedGoals.firstWhere(
      (g) => g.id == reflection.goalId,
      orElse: () => Goal(
        id: '',
        title: '알 수 없는 목표',
        description: '',
        type: GoalType.daily,
        createdAt: DateTime.now(),
      ),
    );

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보 및 회고 배지
            Row(
              children: [
                _buildUserAvatar(goal),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '사용자 ${reflection.userId.length > 8 ? reflection.userId.substring(0, 8) + '...' : reflection.userId}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        _getTimeAgo(reflection.createdAt),
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
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.psychology, size: 12.sp, color: Colors.orange),
                      SizedBox(width: 4.w),
                      Text(
                        '회고',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 목표 정보
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '완료된 목표',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.green,
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
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // 만족도 평가
            Row(
              children: [
                Text(
                  '만족도: ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                ...List.generate(5, (index) {
                  return Icon(
                    index < reflection.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16.sp,
                  );
                }),
                SizedBox(width: 8.w),
                Text(
                  '${reflection.rating}/5',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 회고 내용 (타입별 표시)
            _buildReflectionContent(reflection),

            // 태그
            if (reflection.tags.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: reflection.tags.map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // 액션 버튼들
            SizedBox(height: 12.h),
            _buildReflectionActionButtons(reflection),
          ],
        ),
      ),
    );
  }

  // 회고 타입별 내용 표시
  Widget _buildReflectionContent(Reflection reflection) {
    switch (reflection.type) {
      case ReflectionType.oneLine:
        return _buildOneLineReflection(reflection);
      case ReflectionType.kpt:
        return _buildKPTReflection(reflection);
      case ReflectionType.emoji:
        return _buildEmojiReflection(reflection);
    }
  }

  Widget _buildOneLineReflection(Reflection reflection) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: Colors.orange, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                '한 줄 회고',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            reflection.content,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPTReflection(Reflection reflection) {
    final typeData = reflection.typeData ?? {};
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                'KPT 회고',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (typeData['keep'] != null &&
              typeData['keep'].toString().isNotEmpty) ...[
            _buildKPTItem(
              'Keep (잘한 점)',
              typeData['keep'].toString(),
              Colors.green,
            ),
            SizedBox(height: 8.h),
          ],
          if (typeData['problem'] != null &&
              typeData['problem'].toString().isNotEmpty) ...[
            _buildKPTItem(
              'Problem (문제점)',
              typeData['problem'].toString(),
              Colors.red,
            ),
            SizedBox(height: 8.h),
          ],
          if (typeData['try'] != null &&
              typeData['try'].toString().isNotEmpty) ...[
            _buildKPTItem(
              'Try (다음에 시도할 점)',
              typeData['try'].toString(),
              Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKPTItem(String label, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[800],
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiReflection(Reflection reflection) {
    final typeData = reflection.typeData ?? {};
    final emoji = typeData['emoji'] ?? '😐';
    final emojiRating = typeData['rating'] ?? 3;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sentiment_satisfied,
                color: Colors.purple,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '이모지 회고',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 32.sp)),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getEmojiDescription(emojiRating),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '만족도: ${emojiRating}/5',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEmojiDescription(int rating) {
    switch (rating) {
      case 1:
        return '매우 힘들었어요';
      case 2:
        return '조금 힘들었어요';
      case 3:
        return '보통이었어요';
      case 4:
        return '좋았어요';
      case 5:
        return '완벽했어요';
      default:
        return '';
    }
  }

  // 회고 액션 버튼들
  Widget _buildReflectionActionButtons(Reflection reflection) {
    final likeCount = GoalService.getReflectionLikeCount(reflection.id);
    final commentCount = GoalService.getReflectionCommentCount(reflection.id);
    final shareCount = GoalService.getReflectionShareCount(reflection.id);
    final isLiked = GoalService.hasUserLikedReflection(reflection.id);

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: '좋아요',
            count: likeCount,
            color: isLiked ? Colors.red : Colors.grey[600]!,
            onPressed: () => _toggleReflectionLike(reflection.id),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildActionButton(
            icon: Icons.comment_outlined,
            label: '댓글',
            count: commentCount,
            color: Colors.grey[600]!,
            onPressed: () => _showReflectionCommentsPage(reflection),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_outlined,
            label: '공유',
            count: shareCount,
            color: Colors.grey[600]!,
            onPressed: () => _shareReflection(reflection),
          ),
        ),
      ],
    );
  }

  // 회고 좋아요 토글
  Future<void> _toggleReflectionLike(String reflectionId) async {
    await GoalService.toggleReflectionLike(reflectionId);
    setState(() {
      // UI 업데이트를 위해 상태 갱신
    });
  }

  // 회고 공유하기
  Future<void> _shareReflection(Reflection reflection) async {
    await GoalService.shareReflection(reflection.id);

    // 공유 완료 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reflection.content} 회고를 공유했습니다!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 회고 댓글 페이지 표시
  void _showReflectionCommentsPage(Reflection reflection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(reflection: reflection),
      ),
    );
  }
}
