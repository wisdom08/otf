import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/goal_service.dart';
import 'confetti_widget.dart';

class ReflectionDialog extends StatefulWidget {
  final Goal goal;
  final Function()? onReflectionAdded;
  final Function()? onReflectionSaved; // 회고 저장 완료 시 콜백

  const ReflectionDialog({
    super.key,
    required this.goal,
    this.onReflectionAdded,
    this.onReflectionSaved,
  });

  @override
  State<ReflectionDialog> createState() => _ReflectionDialogState();
}

class _ReflectionDialogState extends State<ReflectionDialog>
    with TickerProviderStateMixin {
  ReflectionType _selectedType = ReflectionType.oneLine;
  final List<String> _selectedTags = [];
  bool _showConfetti = false; // 폭죽 애니메이션 상태
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 한 줄 회고
  final TextEditingController _oneLineController = TextEditingController();

  // KPT 방식
  final TextEditingController _keepController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _tryController = TextEditingController();

  // 이모지 회고
  int _emojiRating = 3; // 1-5 (😫 😕 😐 🙂 😄)

  final List<String> _tags = ['성취감', '도전', '성장', '만족', '보람', '피로', '기쁨'];

  final List<String> _emojis = ['😫', '😕', '😐', '🙂', '😄'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _oneLineController.dispose();
    _keepController.dispose();
    _problemController.dispose();
    _tryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoalCompletionOverlay(
      showConfetti: _showConfetti,
      onConfettiFinished: () {
        setState(() {
          _showConfetti = false;
        });
      },
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _fadeAnimation.value,
              child: AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.indigo, size: 24.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '목표 완료 회고',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 목표 정보
                      _buildGoalInfo(),
                      SizedBox(height: 16.h),

                      // 회고 방식 선택
                      _buildTypeSelection(),
                      SizedBox(height: 16.h),

                      // 선택된 방식에 따른 입력 폼
                      _buildTypeForm(),
                      SizedBox(height: 16.h),

                      // 태그 선택
                      _buildTagSelection(),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  ElevatedButton(
                    onPressed: _canSave() ? _saveReflection : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canSave() ? Colors.indigo : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('회고 저장'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalInfo() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            _getGoalTypeIcon(widget.goal.type),
            color: _getGoalTypeColor(widget.goal.type),
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              widget.goal.title,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '회고 방식',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                ReflectionType.oneLine,
                '한 줄',
                Icons.edit,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildTypeButton(ReflectionType.kpt, 'KPT', Icons.list),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildTypeButton(ReflectionType.emoji, '이모지', Icons.mood),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(ReflectionType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.indigo : Colors.grey[600],
              size: 16.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected ? Colors.indigo : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeForm() {
    switch (_selectedType) {
      case ReflectionType.oneLine:
        return _buildOneLineForm();
      case ReflectionType.kpt:
        return _buildKPTForm();
      case ReflectionType.emoji:
        return _buildEmojiForm();
    }
  }

  Widget _buildOneLineForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '한 줄 회고',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _oneLineController,
          decoration: InputDecoration(
            hintText: '목표를 완료한 소감을 한 줄로 적어보세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.all(12.w),
          ),
          maxLines: 3,
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildKPTForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KPT 회고',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        _buildKPTField('Keep', '잘한 점', _keepController),
        SizedBox(height: 12.h),
        _buildKPTField('Problem', '문제점', _problemController),
        SizedBox(height: 12.h),
        _buildKPTField('Try', '다음에 시도할 것', _tryController),
      ],
    );
  }

  Widget _buildKPTField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: _getKPTColor(label),
          ),
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.all(12.w),
          ),
          maxLines: 2,
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildEmojiForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이모지 회고',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final isSelected = _emojiRating == index + 1;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _emojiRating = index + 1;
                });
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.amber.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected ? Colors.amber : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(_emojis[index], style: TextStyle(fontSize: 24.sp)),
              ),
            );
          }),
        ),
        SizedBox(height: 8.h),
        Text(
          '${_emojis[_emojiRating - 1]} ${_getEmojiDescription(_emojiRating)}',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTagSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '태그 선택 (선택사항)',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _tags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.indigo.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected ? Colors.indigo : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isSelected ? Colors.indigo : Colors.grey[600],
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _canSave() {
    switch (_selectedType) {
      case ReflectionType.oneLine:
        return _oneLineController.text.trim().isNotEmpty;
      case ReflectionType.kpt:
        return _keepController.text.trim().isNotEmpty ||
            _problemController.text.trim().isNotEmpty ||
            _tryController.text.trim().isNotEmpty;
      case ReflectionType.emoji:
        return true; // 이모지는 항상 선택되어 있음
    }
  }

  Future<void> _saveReflection() async {
    String content = '';
    Map<String, dynamic>? typeData;

    switch (_selectedType) {
      case ReflectionType.oneLine:
        content = _oneLineController.text.trim();
        break;
      case ReflectionType.kpt:
        content = 'KPT 회고';
        typeData = {
          'keep': _keepController.text.trim(),
          'problem': _problemController.text.trim(),
          'try': _tryController.text.trim(),
        };
        break;
      case ReflectionType.emoji:
        content = '이모지 회고: ${_emojis[_emojiRating - 1]}';
        typeData = {'emoji': _emojis[_emojiRating - 1], 'rating': _emojiRating};
        break;
    }

    try {
      // 목표 완료 처리와 회고 저장을 함께 수행
      await GoalService.completeGoalWithReflection(
        widget.goal.id,
        content,
        5, // 기본 만족도 (별 5개)
        tags: _selectedTags,
        type: _selectedType,
        typeData: typeData,
      );

      print('회고 저장 완료: ${widget.goal.title} - $content');

      // 폭죽 애니메이션 시작
      setState(() {
        _showConfetti = true;
      });

      if (widget.onReflectionAdded != null) {
        widget.onReflectionAdded!();
      }

      // 회고 저장 완료 콜백 호출
      if (widget.onReflectionSaved != null) {
        widget.onReflectionSaved!();
      }

      // 페이드 아웃 애니메이션 시작
      _fadeController.forward();

      // 애니메이션 완료 후 다이얼로그 닫기
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('회고가 저장되었습니다! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('회고 저장 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회고 저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData _getGoalTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.monthly:
        return Icons.calendar_month;
      case GoalType.weekly:
        return Icons.date_range;
      case GoalType.daily:
        return Icons.today;
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

  Color _getKPTColor(String label) {
    switch (label) {
      case 'Keep':
        return Colors.green;
      case 'Problem':
        return Colors.red;
      case 'Try':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getEmojiDescription(int rating) {
    switch (rating) {
      case 1:
        return '매우 나쁨';
      case 2:
        return '나쁨';
      case 3:
        return '보통';
      case 4:
        return '좋음';
      case 5:
        return '매우 좋음';
      default:
        return '';
    }
  }
}
