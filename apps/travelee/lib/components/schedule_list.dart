import 'package:flutter/material.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:design_systems/dino/components/text/text.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:travelee/models/schedule.dart';

/// ScheduleList
/// 
/// 일정 목록을 시간순으로 정렬하여 표시하는 컴포넌트
/// - 시간별로 정렬된 일정 표시
/// - 일정이 없는 경우 안내 메시지 표시
/// - 각 일정의 시간과 장소 정보 표시
class ScheduleList extends StatelessWidget {
  final List<Schedule> schedules;

  const ScheduleList({
    super.key,
    required this.schedules,
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: DinoText(
          type: DinoTextType.bodyS,
          text: '등록된 일정이 없습니다',
          color: $dinoToken.color.blingGray400.resolve(context),
        ),
      );
    }

    // 시간 순으로 정렬
    final sortedSchedules = [...schedules]..sort((a, b) {
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
    
    return Column(
      children: sortedSchedules.map((schedule) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: $dinoToken.color.blingGray100.resolve(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DinoText(
                  type: DinoTextType.bodyS,
                  text:
                      '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}',
                  color: $dinoToken.color.black.resolve(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DinoText(
                  type: DinoTextType.bodyS,
                  text: schedule.location,
                  color: $dinoToken.color.black.resolve(context),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
} 