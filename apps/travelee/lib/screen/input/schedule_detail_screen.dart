import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/screen/input/schedule_input_modal.dart';

class ScheduleDetailScreen extends ConsumerStatefulWidget {
  static const routeName = 'schedule_detail';
  static const routePath = '/schedule_detail';

  final DateTime date;
  final int dayNumber;

  const ScheduleDetailScreen({
    super.key,
    required this.date,
    required this.dayNumber,
  });

  @override
  ConsumerState<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends ConsumerState<ScheduleDetailScreen> {
  final List<ScheduleItem> _schedules = [];

  void _addSchedule() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ScheduleInputModal(
          initialTime: TimeOfDay.now(),
          initialLocation: '',
          initialMemo: '',
          onSave: (time, location, memo) {
            setState(() {
              _schedules.add(ScheduleItem(
                time: time,
                location: location,
                memo: memo,
              ));
              _sortSchedules();
            });
          },
        ),
      ),
    );
  }

  void _editSchedule(int index, ScheduleItem schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ScheduleInputModal(
          initialTime: schedule.time,
          initialLocation: schedule.location,
          initialMemo: schedule.memo,
          onSave: (time, location, memo) {
            setState(() {
              _schedules[index] = ScheduleItem(
                time: time,
                location: location,
                memo: memo,
              );
              _sortSchedules();
            });
          },
        ),
      ),
    );
  }

  void _removeSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  void _sortSchedules() {
    _schedules.sort((a, b) {
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/icons/logo.svg',
          width: 120,
          colorFilter: ColorFilter.mode(
            $b2bToken.color.primary.resolve(context),
            BlendMode.srcIn,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 27,
            height: 27,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: $b2bToken.color.primary.resolve(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: B2bText.medium(
                        type: B2bTextType.body2,
                        text: 'Day ${widget.dayNumber}',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    B2bText.medium(
                      type: B2bTextType.body2,
                      text: _formatDate(widget.date),
                      color: $b2bToken.color.labelNomal.resolve(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _schedules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 48,
                          color: $b2bToken.color.gray400.resolve(context),
                        ),
                        const SizedBox(height: 16),
                        B2bText.medium(
                          type: B2bTextType.body2,
                          text: '아직 등록된 일정이 없습니다',
                          color: $b2bToken.color.gray400.resolve(context),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _schedules.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: $b2bToken.color.gray200.resolve(context),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _editSchedule(index, schedule),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: $b2bToken.color.gray100.resolve(context),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: B2bText.medium(
                                            type: B2bTextType.body2,
                                            text: '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}',
                                            color: $b2bToken.color.labelNomal.resolve(context),
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () => _removeSchedule(index),
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: $b2bToken.color.pink700.resolve(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (schedule.location.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      B2bText.medium(
                                        type: B2bTextType.body2,
                                        text: schedule.location,
                                        color: $b2bToken.color.labelNomal.resolve(context),
                                      ),
                                    ],
                                    if (schedule.memo.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      B2bText.regular(
                                        type: B2bTextType.body2,
                                        text: schedule.memo,
                                        color: $b2bToken.color.gray500.resolve(context),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: B2bButton.medium(
                title: '일정 추가',
                type: B2bButtonType.primary,
                onTap: _addSchedule,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleItem {
  final TimeOfDay time;
  final String location;
  final String memo;

  ScheduleItem({
    required this.time,
    required this.location,
    required this.memo,
  });

  ScheduleItem copyWith({
    TimeOfDay? time,
    String? location,
    String? memo,
  }) {
    return ScheduleItem(
      time: time ?? this.time,
      location: location ?? this.location,
      memo: memo ?? this.memo,
    );
  }
} 