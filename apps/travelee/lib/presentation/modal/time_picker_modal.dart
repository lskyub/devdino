import 'package:design_systems/dino/dino.dart';
import 'package:flutter/material.dart';
import 'package:design_systems/dino/components/text/text.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:design_systems/dino/components/buttons/button.variant.dart';

class TimePickerModal extends StatefulWidget {
  final TimeOfDay initialTime;

  const TimePickerModal({
    super.key,
    required this.initialTime,
  });

  @override
  State<TimePickerModal> createState() => _TimePickerModalState();
}

class _TimePickerModalState extends State<TimePickerModal> {
  late int _selectedHour;
  late int _selectedMinute;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
    
    _hourController.addListener(_onHourChanged);
    _minuteController.addListener(_onMinuteChanged);
  }

  @override
  void dispose() {
    _hourController.removeListener(_onHourChanged);
    _minuteController.removeListener(_onMinuteChanged);
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _onHourChanged() {
    setState(() {
      _selectedHour = _hourController.selectedItem;
    });
  }

  void _onMinuteChanged() {
    setState(() {
      _selectedMinute = _minuteController.selectedItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              B2bText(
                type: DinoTextType.bodyM,
                text: '시간 설정',
                color: $dinoToken.color.black.resolve(context),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: $dinoToken.color.blingGray400.resolve(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNumberPicker(
                controller: _hourController,
                value: _selectedHour,
                min: 0,
                max: 23,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: B2bText(
                  type: DinoTextType.bodyM,
                  text: ':',
                  color: $dinoToken.color.black.resolve(context),
                ),
              ),
              _buildNumberPicker(
                controller: _minuteController,
                value: _selectedMinute,
                min: 0,
                max: 59,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: B2bButton.medium(
              title: '확인',
              type: B2bButtonType.primary,
              onTap: () {
                Navigator.pop(
                  context,
                  TimeOfDay(
                    hour: _selectedHour,
                    minute: _selectedMinute,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPicker({
    required FixedExtentScrollController controller,
    required int value,
    required int min,
    required int max,
  }) {
    return Container(
      width: 100,
      height: 200,
      decoration: BoxDecoration(
        color: $dinoToken.color.blingGray100.resolve(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: max - min + 1,
          builder: (context, index) {
            final number = min + index;
            final isSelected = number == value;
            return Center(
              child: B2bText(
                type: DinoTextType.bodyM,
                text: number.toString().padLeft(2, '0'),
                color: isSelected
                    ? $dinoToken.color.primary.resolve(context)
                    : $dinoToken.color.black.resolve(context),
              ),
            );
          },
        ),
      ),
    );
  }
} 