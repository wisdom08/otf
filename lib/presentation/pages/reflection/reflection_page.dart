import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/goal_service.dart';

class ReflectionPage extends StatefulWidget {
  final VoidCallback? onReflectionAdded; // 회고 추가 시 콜백

  const ReflectionPage({super.key, this.onReflectionAdded});

  @override
  State<ReflectionPage> createState() => _ReflectionPageState();
}

class _ReflectionPageState extends State<ReflectionPage> {
  List<Reflection> _reflections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReflections();
  }

  Future<void> _loadReflections() async {
    setState(() {
      _isLoading = true;
    });

    // 잠시 대기 후 데이터 로드 (로딩 효과를 위해)
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _reflections = GoalService.getAllReflections();
      _isLoading = false;
    });

    // 회고 추가 시 콜백 호출
    if (widget.onReflectionAdded != null) {
      widget.onReflectionAdded!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '내 회고',
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
        actions: [
          IconButton(
            onPressed: _loadReflections,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _reflections.isEmpty
          ? _buildEmptyState()
          : _buildReflectionsList(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.indigo[600]),
          SizedBox(height: 16.h),
          Text(
            '회고를 불러오는 중...',
            style: GoogleFonts.notoSans(
              fontSize: 16.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_note_outlined,
                size: 60.sp,
                color: Colors.indigo[300],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              '아직 작성한 회고가 없습니다',
              style: GoogleFonts.notoSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              '목표를 완료하고 회고를 작성해보세요!\n회고를 통해 성장의 발자취를 남겨보세요.',
              style: GoogleFonts.notoSans(
                fontSize: 14.sp,
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                // 홈 탭으로 이동하여 목표 완료 유도
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('홈으로 가기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionsList() {
    // 날짜별로 그룹화
    final groupedReflections = _groupReflectionsByDate(_reflections);

    return RefreshIndicator(
      onRefresh: _loadReflections,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: groupedReflections.length,
        itemBuilder: (context, index) {
          final entry = groupedReflections.entries.elementAt(index);
          final date = entry.key;
          final reflections = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 헤더
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: Colors.indigo[600],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      date,
                      style: GoogleFonts.notoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo[600],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${reflections.length}개',
                        style: GoogleFonts.notoSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 회고 아이템들
              ...reflections.map(
                (reflection) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildReflectionCard(reflection),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReflectionCard(Reflection reflection) {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _getReflectionTypeColor(reflection.type).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (타입 배지 + 목표 제목)
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
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  goal.title,
                  style: GoogleFonts.notoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                _formatTime(reflection.createdAt),
                style: GoogleFonts.notoSans(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 회고 내용
          _buildReflectionContent(reflection),

          SizedBox(height: 12.h),

          // 목표 정보
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  _getGoalTypeIcon(goal.type),
                  size: 16.sp,
                  color: _getGoalTypeColor(goal.type),
                ),
                SizedBox(width: 8.w),
                Text(
                  _getGoalTypeLabel(goal.type),
                  style: GoogleFonts.notoSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _getGoalTypeColor(goal.type),
                  ),
                ),
                const Spacer(),
                if (goal.isCompleted)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      '완료',
                      style: GoogleFonts.notoSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionContent(Reflection reflection) {
    switch (reflection.type) {
      case ReflectionType.oneLine:
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            reflection.content,
            style: GoogleFonts.notoSans(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        );

      case ReflectionType.kpt:
        final data = reflection.typeData;
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Column(
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
          ),
        );

      case ReflectionType.emoji:
        final data = reflection.typeData;
        final rating = data?['rating'] as int? ?? 0;
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Text(
                _getEmojiByRating(rating),
                style: TextStyle(fontSize: 32.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '감정 평가',
                      style: GoogleFonts.notoSans(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _getEmojiDescription(rating),
                      style: GoogleFonts.notoSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildKPTItem(String label, String content, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            content,
            style: GoogleFonts.notoSans(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Reflection>> _groupReflectionsByDate(
    List<Reflection> reflections,
  ) {
    final Map<String, List<Reflection>> grouped = {};

    for (final reflection in reflections) {
      final dateKey = _formatDate(reflection.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(reflection);
    }

    // 각 날짜 그룹 내에서도 최신순으로 정렬
    grouped.forEach((dateKey, reflections) {
      reflections.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });

    // 날짜 순으로 정렬 (최신순)
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Map.fromEntries(sortedEntries);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return '오늘';
    } else if (targetDate == yesterday) {
      return '어제';
    } else {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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

  IconData _getGoalTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.monthly:
        return Icons.calendar_month;
      case GoalType.weekly:
        return Icons.calendar_view_week;
      case GoalType.daily:
        return Icons.check_circle_outline;
    }
  }

  Color _getGoalTypeColor(GoalType type) {
    switch (type) {
      case GoalType.monthly:
        return Colors.purple;
      case GoalType.weekly:
        return Colors.blue;
      case GoalType.daily:
        return Colors.green;
    }
  }

  String _getGoalTypeLabel(GoalType type) {
    switch (type) {
      case GoalType.monthly:
        return '월간 목표';
      case GoalType.weekly:
        return '주간 목표';
      case GoalType.daily:
        return '일간 목표';
    }
  }
}
