import 'package:flutter/material.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:travelee/models/schedule.dart';

/// 일정 목록의 개별 일정 아이템 위젯
class ScheduleItem extends StatefulWidget {
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
  State<ScheduleItem> createState() => _ScheduleItemState();
}

class _ScheduleItemState extends State<ScheduleItem> {
  final GlobalKey _timeWidgetKey = GlobalKey();
  double _timeWidgetWidth = 80; // 기본값으로 시작

  @override
  void initState() {
    super.initState();
    // 첫 렌더링 후 시간 위젯의 너비 측정
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _measureTimeWidgetWidth());
  }

  // 시간 위젯의 실제 너비를 측정
  void _measureTimeWidgetWidth() {
    final RenderBox? box =
        _timeWidgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      setState(() {
        _timeWidgetWidth = box.size.width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeSection(context),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 일정 내용 영역
                    B2bText.bold(
                      type: B2bTextType.body1,
                      text: widget.schedule.location,
                      color: $b2bToken.color.labelNomal.resolve(context),
                    ),
                    B2bText.regular(
                      type: B2bTextType.body3,
                      text: widget.schedule.memo,
                      color: $b2bToken.color.gray300.resolve(context),
                    )
                  ],
                ),
              ),
            ),
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  /// 시간 표시 섹션
  Widget _buildTimeSection(BuildContext context) {
    final formattedTime =
        '${widget.schedule.time.hour.toString().padLeft(2, '0')}:${widget.schedule.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        key: _timeWidgetKey, // GlobalKey 추가하여 너비 측정
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: $b2bToken.color.primary.resolve(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: B2bText.medium(
          type: B2bTextType.body3,
          text: formattedTime,
          color: $b2bToken.color.primary.resolve(context),
        ),
      ),
    );
  }

  /// 액션 버튼 섹션
  Widget _buildActionButtons(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: $b2bToken.color.gray600.resolve(context),
        size: 20,
      ),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        if (value == 'edit') {
          widget.onEdit();
        } else if (value == 'delete') {
          // 삭제 확인 다이얼로그 없이 바로 삭제
          widget.onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: $b2bToken.color.primary.resolve(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              B2bText.medium(
                type: B2bTextType.body2,
                text: '수정',
                color: $b2bToken.color.labelNomal.resolve(context),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              B2bText.medium(
                type: B2bTextType.body2,
                text: '삭제',
                color: $b2bToken.color.labelNomal.resolve(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
