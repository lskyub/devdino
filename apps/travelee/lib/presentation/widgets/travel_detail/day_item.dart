import 'package:collection/collection.dart';
import 'package:country_icons/country_icons.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelee/data/models/schedule/day_schedule_data.dart';
import 'package:travelee/data/models/schedule/schedule.dart';
import 'package:travelee/presentation/widgets/travel_detail/schedule_item.dart';
import 'dart:developer' as dev;

class DayItem extends ConsumerStatefulWidget {
  final DayScheduleData dayData;
  final Function(DayScheduleData, Schedule) onScheduleTap;
  final Function(Schedule, DateTime) onScheduleDrop;
  final Function(DayScheduleData) addSchedule;
  final Function(DateTime) onSelectCountry;
  final Function(Schedule) deleteSchedule;
  final Color Function(String) getScheduleColor;
  final int index;
  final bool isEdit;

  const DayItem({
    super.key,
    required this.index,
    required this.isEdit,
    required this.dayData,
    required this.onScheduleTap,
    required this.onScheduleDrop,
    required this.getScheduleColor,
    required this.onSelectCountry,
    required this.addSchedule,
    required this.deleteSchedule,
  });

  @override
  ConsumerState<DayItem> createState() => _DayItemState();
}

class _DayItemState extends ConsumerState<DayItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (widget.isEdit) {
                widget.onSelectCountry(widget.dayData.date);
              }
            },
            child: SizedBox(
              width: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  B2bText(
                    type: DinoTextType.bodyM,
                    text: widget.dayData.date.day.toString().padLeft(2, '0'),
                    color: $dinoToken.color.black.resolve(context),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: $dinoToken.color.blingGray300.resolve(context),
                        width: 0.5,
                      ),
                    ),
                    child: ClipOval(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child:
                            CountryIcons.getSvgFlag(widget.dayData.countryCode),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: DragTarget<Schedule>(
              onAcceptWithDetails: (details) {
                dev.log('${details.data}');
                widget.onScheduleDrop(details.data, widget.dayData.date);
              },
              builder: (context, candidateData, rejectedData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.index != 0) ...[
                      Divider(
                        height: 0.5,
                        color: $dinoToken.color.blingGray400
                            .resolve(context)
                            .withAlpha((0.3 * 255).toInt()),
                      ),
                    ],
                    const SizedBox(
                      height: 8,
                    ),
                    ...widget.dayData.schedules
                        .sorted((a, b) => a.time.compareTo(b.time))
                        .mapIndexed((index, schedule) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: index == widget.dayData.schedules.length - 1
                                ? 0
                                : 8,
                            right: 16),
                        child: ScheduleItem(
                          schedule: schedule,
                          onTap: () {
                            if (widget.isEdit) {
                              widget.onScheduleTap(widget.dayData, schedule);
                            }
                          },
                          color: widget.getScheduleColor(schedule.location),
                          isEdit: widget.isEdit,
                          deleteSchedule: widget.deleteSchedule,
                        ),
                      );
                    }),
                    if (widget.isEdit) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () => widget.addSchedule(widget.dayData),
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            child: DottedBorder(
                              color: $dinoToken.color.blingGray400
                                  .resolve(context), // 점선 색상
                              strokeWidth: 0.5, // 점선 두께
                              dashPattern: const [
                                6,
                                3
                              ], // 점선 간격 (6px 선, 3px 간격)
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10), // 둥근 사각형
                              child: SizedBox(
                                height: 40,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          $dinoToken.color.blingGray400
                                              .resolve(context), // 적용할 색상
                                          BlendMode.srcIn, // 아이콘 색상을 변경하는 모드
                                        ),
                                        child: const Icon(Icons.add),
                                      ),
                                      B2bText(
                                        text: '일정 추가 하기',
                                        type: DinoTextType.detailL,
                                        color: $dinoToken.color.blingGray400
                                            .resolve(context),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
