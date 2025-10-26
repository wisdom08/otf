import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/goal_service.dart';
import '../../../services/local_storage_service.dart';

class CommentsPage extends StatefulWidget {
  final Goal? goal;
  final Reflection? reflection;

  const CommentsPage({super.key, this.goal, this.reflection})
      : assert(goal != null || reflection != null, 'Either goal or reflection must be provided');

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  List<SocialAction> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    final targetId = widget.goal?.id ?? widget.reflection!.id;
    setState(() {
      _comments = GoalService.getSocialActions(targetId)
          .where((action) => action.type == SocialActionType.comment)
          .toList();
      _comments.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 최신순
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '댓글 (${_comments.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadComments),
        ],
      ),
      body: Column(
        children: [
          // 목표/회고 정보
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: widget.goal != null 
                        ? _getTypeColor(widget.goal!.type).withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    widget.goal != null 
                        ? _getTypeIcon(widget.goal!.type)
                        : Icons.psychology,
                    color: widget.goal != null 
                        ? _getTypeColor(widget.goal!.type)
                        : Colors.orange,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.goal?.title ?? '회고',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (widget.goal?.description.isNotEmpty == true)
                        Text(
                          widget.goal!.description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (widget.reflection != null)
                        Text(
                          widget.reflection!.content,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 댓글 목록
          Expanded(
            child: _comments.isEmpty
                ? _buildEmptyComments()
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return _buildCommentCard(comment);
                    },
                  ),
          ),

          // 댓글 입력
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(top: BorderSide(color: Colors.grey[800]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16.sp,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide(color: Colors.indigo),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(width: 8.w),
                FloatingActionButton.small(
                  onPressed: _addComment,
                  backgroundColor: Colors.indigo,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.comment_outlined, size: 60.sp, color: Colors.grey[400]),
          SizedBox(height: 12.h),
          Text(
            '아직 댓글이 없습니다',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            '첫 번째 댓글을 남겨보세요!',
            style: TextStyle(
              fontSize: 12.sp, 
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(SocialAction comment) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCommenterAvatar(comment.userId),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '사용자 ${comment.userId.length > 8 ? comment.userId.substring(0, 8) + '...' : comment.userId}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        _getTimeAgo(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (comment.userId == LocalStorageService.getCurrentUserId())
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteComment(comment);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            Text('삭제'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              comment.content ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommenterAvatar(String userId) {
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
      ),
      child: CircleAvatar(
        radius: 16.r,
        backgroundColor: Colors.transparent,
        child: Text(
          userId.isNotEmpty ? userId.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      await GoalService.addSocialAction(
        widget.goal?.id ?? widget.reflection!.id,
        SocialActionType.comment,
        content: content,
      );

      _commentController.clear();
      _loadComments();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('댓글이 추가되었습니다!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('댓글 추가 중 오류가 발생했습니다: $e')));
    }
  }

  Future<void> _deleteComment(SocialAction comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '댓글 삭제',
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          '이 댓글을 삭제하시겠습니까?',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await GoalService.deleteComment(comment.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('댓글이 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        _loadComments();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('댓글 삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
}
