import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/goal_service.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<String> _friends = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _friends = GoalService.getFriends();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '친구 관리',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddFriendDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 바
          Container(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '친구 ID로 검색...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // 친구 목록
          Expanded(
            child: _friends.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _friends.length,
                    itemBuilder: (context, index) {
                      final friendId = _friends[index];
                      return _buildFriendCard(friendId);
                    },
                  ),
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
          Icon(Icons.people_outline, size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            '아직 친구가 없습니다',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '친구를 추가해서 목표를 공유해보세요!',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _showAddFriendDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('친구 추가하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(String friendId) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        leading: _buildFriendAvatar(friendId),
        title: Text(
          '친구 $friendId',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'ID: ${friendId.length > 8 ? friendId.substring(0, 8) + '...' : friendId}',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'remove') {
              _removeFriend(friendId);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, color: Colors.red),
                  SizedBox(width: 8),
                  Text('친구 삭제'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // 친구 프로필 보기 (추후 구현)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('친구 프로필 기능은 곧 추가될 예정입니다!')),
          );
        },
      ),
    );
  }

  Widget _buildFriendAvatar(String friendId) {
    // 친구 ID를 기반으로 고유한 색상 생성
    final colorIndex = friendId.hashCode % _avatarColors.length;
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
          friendId.isNotEmpty ? friendId.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAddFriendDialog() {
    final friendIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('친구 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '친구의 사용자 ID를 입력하세요',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: friendIdController,
              decoration: InputDecoration(
                labelText: '친구 ID',
                hintText: '예: friend123',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
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
            onPressed: () async {
              final friendId = friendIdController.text.trim();
              if (friendId.isNotEmpty) {
                await _addFriend(friendId);
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFriend(String friendId) async {
    if (_friends.contains(friendId)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미 친구로 등록된 사용자입니다.')));
      return;
    }

    if (friendId == 'current_user') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('자기 자신은 친구로 추가할 수 없습니다.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await GoalService.addFriend(friendId);
      await _loadFriends();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$friendId님을 친구로 추가했습니다!'),
          action: SnackBarAction(label: '확인', onPressed: () {}),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('친구 추가 중 오류가 발생했습니다: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFriend(String friendId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('친구 삭제'),
        content: Text('$friendId님을 친구 목록에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
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
      await GoalService.removeFriend(friendId);
      await _loadFriends();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$friendId님을 친구 목록에서 삭제했습니다.')));
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
