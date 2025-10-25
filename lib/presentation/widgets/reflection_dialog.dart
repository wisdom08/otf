import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/goal_service.dart';

class ReflectionDialog extends StatefulWidget {
  final Goal goal;
  final Function()? onReflectionAdded;

  const ReflectionDialog({
    super.key,
    required this.goal,
    this.onReflectionAdded,
  });

  @override
  State<ReflectionDialog> createState() => _ReflectionDialogState();
}

class _ReflectionDialogState extends State<ReflectionDialog> {
  ReflectionType _selectedType = ReflectionType.oneLine;
  int _rating = 5;
  final List<String> _selectedTags = [];

  // 한 줄 회고
  final TextEditingController _oneLineController = TextEditingController();

  // KPT 방식
  final TextEditingController _keepController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _tryController = TextEditingController();

  // 이모지 회고
  int _emojiRating = 3; // 1-5 (😫 😕 😐 🙂 😄)

  final List<String> _availableTags = [
    '성취감',
    '어려움',
    '다음계획',
    '만족',
    '아쉬움',
    '도전',
    '성장',
    '보람',
    '피로',
    '기쁨',
  ];

  final List<String> _emojis = ['😫', '😕', '😐', '🙂', '😄'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.psychology, color: Colors.indigo, size: 24.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '목표 완료 회고',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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

            // 만족도 평가
            _buildRatingSection(),
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
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('회고 저장'),
        ),
      ],
    );
  }

  Widget _buildGoalInfo() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.goal.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.indigo[800],
            ),
          ),
          if (widget.goal.description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              widget.goal.description,
              style: TextStyle(fontSize: 14.sp, color: Colors.indigo[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '회고 방식 선택',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                ReflectionType.oneLine,
                '📝',
                '한 줄',
                '간단한 한 문장',
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildTypeOption(
                ReflectionType.kpt,
                '🔍',
                'KPT',
                'Keep/Problem/Try',
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildTypeOption(
                ReflectionType.emoji,
                '😄',
                '이모지',
                '감정 표현',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeOption(
    ReflectionType type,
    String emoji,
    String title,
    String subtitle,
  ) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo : Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 20.sp)),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.sp,
                color: isSelected ? Colors.white70 : Colors.grey[500],
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
            hintText: '예: "꾸준함의 힘을 느낀 하루였다."',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.all(12.w),
          ),
          maxLines: 1,
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
        _buildKPTField('Keep (잘한 점)', _keepController, '예: 퇴근 후 1시간 공부'),
        SizedBox(height: 12.h),
        _buildKPTField('Problem (문제점)', _problemController, '예: 집중력 저하'),
        SizedBox(height: 12.h),
        _buildKPTField('Try (다음에 시도할 점)', _tryController, '예: 환경 개선'),
      ],
    );
  }

  Widget _buildKPTField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.all(8.w),
            isDense: true,
          ),
          maxLines: 2,
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

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '목표 달성 만족도',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = index + 1;
                });
              },
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32.sp,
                ),
              ),
            );
          }),
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
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _availableTags.map((tag) {
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
                  color: isSelected ? Colors.indigo : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected ? Colors.indigo : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w500,
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
        return true; // 이모지는 항상 선택됨
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

    // 목표 완료 처리와 회고 저장을 함께 수행
    await GoalService.completeGoalWithReflection(
      widget.goal.id,
      content,
      _rating,
      tags: _selectedTags,
      type: _selectedType,
      typeData: typeData,
    );

    if (widget.onReflectionAdded != null) {
      widget.onReflectionAdded!();
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('회고가 저장되었습니다! 🎉'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
