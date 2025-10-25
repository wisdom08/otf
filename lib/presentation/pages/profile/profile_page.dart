import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/goal_service.dart';
import '../../../services/local_storage_service.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onDataChanged; // 데이터 변경 시 콜백

  const ProfilePage({super.key, this.onDataChanged});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  void refreshData() {
    setState(() {
      // 데이터 새로고침을 위해 setState 호출
    });
  }

  @override
  Widget build(BuildContext context) {
    final goals = GoalService.getGoals();
    final completedGoals = goals.where((goal) => goal.isCompleted).length;
    final totalGoals = goals.length;
    final streakCount = LocalStorageService.getStreak();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '프로필',
          style: GoogleFonts.notoSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // 프로필 헤더
            _buildProfileHeader(),
            SizedBox(height: 24.h),

            // 통계 카드
            _buildStatsCard(completedGoals, totalGoals, streakCount),
            SizedBox(height: 24.h),

            // 목표 현황
            _buildGoalsOverview(goals),
            SizedBox(height: 24.h),

            // 회고 섹션
            _buildReflectionsSection(),
            SizedBox(height: 24.h),

            // 설정 메뉴
            _buildSettingsMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 아바타
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: 40.sp, color: Colors.blue[600]),
          ),
          SizedBox(height: 16.h),

          // 사용자 이름
          Text(
            '사용자',
            style: GoogleFonts.notoSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),

          // 이메일
          Text(
            'user@example.com',
            style: GoogleFonts.notoSans(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),

          // 편집 버튼
          ElevatedButton.icon(
            onPressed: () {
              // 프로필 편집 기능
              _showEditProfileDialog();
            },
            icon: Icon(Icons.edit, size: 16.sp),
            label: Text(
              '프로필 편집',
              style: GoogleFonts.notoSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[50],
              foregroundColor: Colors.blue[700],
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int completedGoals, int totalGoals, int streakCount) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '통계',
            style: GoogleFonts.notoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '완료한 목표',
                  '$completedGoals',
                  Colors.green[600]!,
                  Icons.check_circle,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  '전체 목표',
                  '$totalGoals',
                  Colors.blue[600]!,
                  Icons.flag,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '연속 달성',
                  '$streakCount일',
                  Colors.orange[600]!,
                  Icons.local_fire_department,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatItem(
                  '완료율',
                  totalGoals > 0
                      ? '${(completedGoals / totalGoals * 100).toInt()}%'
                      : '0%',
                  Colors.purple[600]!,
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsOverview(List goals) {
    final monthlyGoals = goals
        .where((goal) => goal.type == GoalType.monthly)
        .length;
    final weeklyGoals = goals
        .where((goal) => goal.type == GoalType.weekly)
        .length;
    final dailyGoals = goals
        .where((goal) => goal.type == GoalType.daily)
        .length;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '목표 현황',
            style: GoogleFonts.notoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),

          _buildGoalTypeItem('월간 목표', monthlyGoals, Colors.purple),
          SizedBox(height: 12.h),
          _buildGoalTypeItem('주간 목표', weeklyGoals, Colors.blue),
          SizedBox(height: 12.h),
          _buildGoalTypeItem('일간 목표', dailyGoals, Colors.green),
        ],
      ),
    );
  }

  Widget _buildGoalTypeItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.notoSans(fontSize: 14.sp, color: Colors.black87),
          ),
        ),
        Text(
          '$count개',
          style: GoogleFonts.notoSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsMenu() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem('알림 설정', Icons.notifications_outlined, () {}),
          _buildDivider(),
          _buildMenuItem('데이터 백업', Icons.backup_outlined, () {}),
          _buildDivider(),
          _buildMenuItem('테마 설정', Icons.palette_outlined, () {}),
          _buildDivider(),
          _buildMenuItem('도움말', Icons.help_outline, () {}),
          _buildDivider(),
          _buildMenuItem('정보', Icons.info_outline, () {}, isLast: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isLast ? Radius.circular(16.r) : Radius.zero,
        bottom: isLast ? Radius.circular(16.r) : Radius.zero,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: Colors.grey[600]),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 16.sp,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionsSection() {
    final reflections = GoalService.getAllReflections()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신순 정렬

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '내 회고',
                style: GoogleFonts.notoSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    '${reflections.length}개',
                    style: GoogleFonts.notoSans(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: refreshData,
                    icon: Icon(
                      Icons.refresh,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),

          if (reflections.isEmpty)
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.edit_note_outlined,
                    size: 48.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '아직 작성한 회고가 없습니다',
                    style: GoogleFonts.notoSans(
                      fontSize: 14.sp,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '목표를 완료하고 회고를 작성해보세요!',
                    style: GoogleFonts.notoSans(
                      fontSize: 12.sp,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                ...reflections.take(3).map((reflection) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _buildReflectionItem(reflection),
                  );
                }),
                if (reflections.length > 3)
                  TextButton(
                    onPressed: () => _showAllReflections(reflections),
                    child: Text(
                      '전체 회고 보기 (${reflections.length - 3}개 더)',
                      style: GoogleFonts.notoSans(
                        fontSize: 14.sp,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReflectionItem(Reflection reflection) {
    final goal = GoalService.getGoals().firstWhere(
      (g) => g.id == reflection.goalId,
      orElse: () => Goal(
        id: '',
        title: '삭제된 목표',
        description: '',
        type: GoalType.daily,
        createdAt: DateTime.now(),
      ),
    );

    return Container(
      padding: EdgeInsets.all(16.w),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getReflectionTypeColor(
                    reflection.type,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: _getReflectionTypeColor(
                      reflection.type,
                    ).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getReflectionTypeLabel(reflection.type),
                  style: GoogleFonts.notoSans(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: _getReflectionTypeColor(reflection.type),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  goal.title,
                  style: GoogleFonts.notoSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildReflectionContent(reflection),
          SizedBox(height: 8.h),
          Text(
            _formatDate(reflection.createdAt),
            style: GoogleFonts.notoSans(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionContent(Reflection reflection) {
    switch (reflection.type) {
      case ReflectionType.oneLine:
        return Text(
          reflection.content,
          style: GoogleFonts.notoSans(
            fontSize: 14.sp,
            color: Colors.black87,
            height: 1.4,
          ),
        );

      case ReflectionType.kpt:
        final data = reflection.typeData;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data?['keep'] != null && data!['keep'].toString().isNotEmpty)
              _buildKPTItem('Keep', data['keep'], Colors.green),
            if (data?['problem'] != null &&
                data!['problem'].toString().isNotEmpty)
              _buildKPTItem('Problem', data['problem'], Colors.red),
            if (data?['try'] != null && data!['try'].toString().isNotEmpty)
              _buildKPTItem('Try', data['try'], Colors.blue),
          ],
        );

      case ReflectionType.emoji:
        final data = reflection.typeData;
        final rating = data?['rating'] as int? ?? 0;
        return Row(
          children: [
            Text(
              '감정 평가: ',
              style: GoogleFonts.notoSans(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            Text(_getEmojiByRating(rating), style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 8.w),
            Text(
              _getEmojiDescription(rating),
              style: GoogleFonts.notoSans(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildKPTItem(String label, String content, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              content,
              style: GoogleFonts.notoSans(
                fontSize: 13.sp,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getReflectionTypeLabel(ReflectionType type) {
    switch (type) {
      case ReflectionType.oneLine:
        return '한 줄 회고';
      case ReflectionType.kpt:
        return 'KPT 회고';
      case ReflectionType.emoji:
        return '이모지 회고';
    }
  }

  Color _getReflectionTypeColor(ReflectionType type) {
    switch (type) {
      case ReflectionType.oneLine:
        return Colors.blue;
      case ReflectionType.kpt:
        return Colors.purple;
      case ReflectionType.emoji:
        return Colors.orange;
    }
  }

  String _getEmojiByRating(int rating) {
    switch (rating) {
      case 1:
        return '😫';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
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
        return '매우 좋았어요';
      default:
        return '보통이었어요';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showAllReflections(List<Reflection> reflections) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '전체 회고',
                    style: GoogleFonts.notoSans(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: reflections.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: _buildReflectionItem(reflections[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.only(left: 52.w),
      height: 1.h,
      color: Colors.grey[200],
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '프로필 편집',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('프로필이 업데이트되었습니다'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
