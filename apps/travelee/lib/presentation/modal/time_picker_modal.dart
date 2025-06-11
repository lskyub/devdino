import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    _minuteController =
        FixedExtentScrollController(initialItem: _selectedMinute);

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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
            child: Row(
              children: [
                DinoText.custom(
                  fontSize: 20,
                  text: '시간 선택',
                  color: $dinoToken.color.blingGray900,
                  fontWeight: FontWeight.w600,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    'assets/icons/popup_cancle.svg',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: $dinoToken.color.blingGray100.resolve(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                width: double.infinity,
                height: 36,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNumberPicker(
                    controller: _hourController,
                    value: _selectedHour,
                    min: 0,
                    max: 23,
                    unit: '시',
                  ),
                  _buildNumberPicker(
                    controller: _minuteController,
                    value: _selectedMinute,
                    min: 0,
                    max: 59,
                    unit: '분',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DinoButton(
                type: DinoButtonType.solid,
                size: DinoButtonSize.full,
                backgroundColor: $dinoToken.color.brandBlingPurple600,
                title: '일정 추가하기',
                onTap: () {
                  Navigator.pop(
                    context,
                    TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                  );
                },
              ),
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
    required String unit,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 8,
      height: 228,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40,
        perspective: 0.00001,
        diameterRatio: 100,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: max - min + 1,
          builder: (context, index) {
            final number = min + index;
            final isSelected = number == value;
            return Center(
              child: DinoText.custom(
                fontSize: 18,
                // text: '${number.toString().padLeft(2, '0')}$unit',
                text: '$number$unit',
                color: isSelected
                    ? $dinoToken.color.blingGray900
                    : $dinoToken.color.blingGray400,
              ),
            );
            // return Center(
            //   child: B2bText(
            //     type: DinoTextType.bodyM,
            //     text: number.toString().padLeft(2, '0'),
            //     color: isSelected
            //         ? $dinoToken.color.primary.resolve(context)
            //         : $dinoToken.color.black.resolve(context),
            //   ),
            // );
          },
        ),
      ),
    );
  }
}
