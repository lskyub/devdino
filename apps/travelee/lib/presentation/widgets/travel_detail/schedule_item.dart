import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelee/data/models/schedule/schedule.dart';

class ScheduleItem extends ConsumerWidget {
  final Schedule schedule;
  final VoidCallback onTap;
  final Color color;
  final bool isEdit;
  final Function(Schedule) deleteSchedule;

  const ScheduleItem({
    super.key,
    required this.schedule,
    required this.onTap,
    required this.color,
    required this.isEdit,
    required this.deleteSchedule,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LongPressDraggable<Schedule>(
      data: schedule,
      maxSimultaneousDrags: isEdit ? 1 : 0,
      feedback: Material(
        elevation: 4.0,
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width - 80,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  schedule.location,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                schedule.time.format(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildScheduleContent(context),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: _buildScheduleContent(context),
      ),
    );
  }

  Widget _buildScheduleContent(BuildContext context) {
    return Dismissible(
      key: Key(schedule.id),
      direction: isEdit ? DismissDirection.horizontal : DismissDirection.none,
      confirmDismiss: (action) async {
        return deleteSchedule(schedule);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                schedule.location,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              schedule.time.format(context),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
