import 'package:flutter/material.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:travelee/models/schedule.dart';
import 'dart:developer' as dev;

/// 일정 목록의 개별 일정 아이템 위젯
class ScheduleItem extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const ScheduleItem({
    Key? key,
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 시간 표시 영역
            _buildTimeSection(context),
            const SizedBox(width: 16),
            
            // 일정 내용 영역
            Expanded(
              child: _buildContentSection(context),
            ),
            
            // 액션 버튼 영역
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }
  
  /// 시간 표시 섹션
  Widget _buildTimeSection(BuildContext context) {
    final formattedTime = '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: $b2bToken.color.primary.resolve(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: B2bText.bold(
        type: B2bTextType.body2,
        text: formattedTime,
        color: $b2bToken.color.primary.resolve(context),
      ),
    );
  }
  
  /// 일정 내용 섹션
  Widget _buildContentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 장소
        B2bText.bold(
          type: B2bTextType.body1,
          text: schedule.location,
          color: $b2bToken.color.labelNomal.resolve(context),
        ),
        const SizedBox(height: 4),
        
        // 메모 (있는 경우만)
        if (schedule.memo.isNotEmpty)
          B2bText.regular(
            type: B2bTextType.body3,
            text: schedule.memo,
            color: $b2bToken.color.gray600.resolve(context),
          ),
      ],
    );
  }
  
  /// 액션 버튼 섹션
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 편집 버튼
        IconButton(
          icon: Icon(
            Icons.edit_outlined,
            color: $b2bToken.color.primary.resolve(context),
            size: 20,
          ),
          onPressed: onEdit,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        
        // 삭제 버튼
        IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Colors.red,
            size: 20,
          ),
          onPressed: onDelete,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
} 