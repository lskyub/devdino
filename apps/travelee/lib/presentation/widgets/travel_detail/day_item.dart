import 'package:collection/collection.dart';
import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travelee/data/models/schedule/day_schedule_data.dart';
import 'package:travelee/data/models/schedule/schedule.dart';
import 'package:travelee/presentation/widgets/travel_detail/schedule_item.dart';

class DayItem extends ConsumerStatefulWidget {
  final DayScheduleData dayData;
  final Function(DayScheduleData, Schedule) onScheduleTap;
  final Function(Schedule, DateTime) onScheduleDrop;
  final Function(DayScheduleData) addSchedule;
  final Function(DateTime) onSelectCountry;
  final Function(Schedule) deleteSchedule;
  final int index;
  final bool isEdit;
  final int colorStartIndex;

  const DayItem({
    super.key,
    required this.index,
    required this.isEdit,
    required this.dayData,
    required this.onScheduleTap,
    required this.onScheduleDrop,
    required this.onSelectCountry,
    required this.addSchedule,
    required this.deleteSchedule,
    this.colorStartIndex = 0,
  });

  @override
  ConsumerState<DayItem> createState() => _DayItemState();
}

class _DayItemState extends ConsumerState<DayItem> {
  Color _getScheduleColor(int index) {
    // 간단한 해시 기반 색상 선택
    final colors = [
      $dinoToken.color.brandBlingTeal600.resolve(context),
      $dinoToken.color.brandBlingCyan600.resolve(context),
      $dinoToken.color.brandBlingBlue600.resolve(context),
      $dinoToken.color.brandBlingIndigo600.resolve(context),
      $dinoToken.color.brandBlingViolet600.resolve(context),
      $dinoToken.color.brandBlingPurple600.resolve(context),
      $dinoToken.color.brandBlingPlum600.resolve(context),
      $dinoToken.color.brandBlingPink600.resolve(context),
      $dinoToken.color.brandBlingCrimson600.resolve(context),
    ];

    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    var color = widget.dayData.schedules.isEmpty
        ? $dinoToken.color.blingGray300
        : $dinoToken.color.brandBlingPurple600;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
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
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.resolve(context),
                            width: 0.5,
                          ),
                          color: color.resolve(context),
                        ),
                        child: ClipOval(
                          child: Center(
                            child: DinoText.custom(
                              text: widget.dayData.date.day
                                  .toString()
                                  .padLeft(2, '0'),
                              color: $dinoToken.color.white,
                              fontSize: 14.22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      DinoText.custom(
                        text: 'day ${widget.index + 1}',
                        color: color,
                        fontSize: 9.99,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 30,
                  ),
                  padding: const EdgeInsets.only(top: 8, bottom: 10),
                  child: VerticalDivider(
                    color: color.resolve(context),
                    thickness: 0.5,
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: DragTarget<Schedule>(
              onAcceptWithDetails: (details) {
                widget.onScheduleDrop(details.data, widget.dayData.date);
              },
              builder: (context, candidateData, rejectedData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.dayData.schedules
                        .sorted((a, b) => a.time.compareTo(b.time))
                        .mapIndexed((index, schedule) {
                      var color =
                          _getScheduleColor(widget.colorStartIndex + index);
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: index == widget.dayData.schedules.length - 1
                                ? 15
                                : 5,
                            right: 16),
                        child: ScheduleItem(
                          schedule: schedule,
                          onTap: () {
                            if (widget.isEdit) {
                              widget.onScheduleTap(widget.dayData, schedule);
                            }
                          },
                          color: color,
                          isEdit: widget.isEdit,
                          deleteSchedule: widget.deleteSchedule,
                        ),
                      );
                    }),
                    if (widget.isEdit) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 30),
                        child: GestureDetector(
                          onTap: () => widget.addSchedule(widget.dayData),
                          child: DottedBorder(
                            color: $dinoToken.color.blingGray300
                                .resolve(context), // 점선 색상
                            strokeWidth: 0.5, // 점선 두께
                            dashPattern: const [3, 3], // 점선 간격 (6px 선, 3px 간격)
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10), // 둥근 사각형
                            child: SizedBox(
                              height: 44,
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
                                      child: SvgPicture.asset(
                                        'assets/icons/add_plan.svg',
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    DinoText.custom(
                                      text: '일정 추가 하기',
                                      color: $dinoToken.color.blingGray400,
                                      fontSize: 14.22,
                                      fontWeight: FontWeight.w600,
                                    )
                                  ],
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
