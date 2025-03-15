import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/textfield/textfield.dart';
import 'package:design_systems/b2b/components/textfield/textfield.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:travelee/models/schedule.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/screen/input/time_picker_modal.dart';
import 'package:travelee/screen/input/location_search_screen.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as dev;

class ScheduleInputModal extends ConsumerStatefulWidget {
  final TimeOfDay initialTime;
  final String initialLocation;
  final String initialMemo;
  final DateTime date;
  final int dayNumber;
  final String? scheduleId;

  const ScheduleInputModal({
    super.key,
    required this.initialTime,
    required this.initialLocation,
    required this.initialMemo,
    required this.date,
    required this.dayNumber,
    this.scheduleId,
  });

  @override
  ConsumerState<ScheduleInputModal> createState() => _ScheduleInputModalState();
}

class _ScheduleInputModalState extends ConsumerState<ScheduleInputModal> {
  final _locationController = TextEditingController();
  final _memoController = TextEditingController();
  late TimeOfDay _selectedTime;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.initialLocation;
    _memoController.text = widget.initialMemo;
    _selectedTime = widget.initialTime;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      builder: (context) => TimePickerModal(
        initialTime: _selectedTime,
      ),
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _selectLocation(BuildContext context) async {
    final String? selectedLocation = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => LocationSearchScreen(
          initialLocation: _locationController.text,
        ),
      ),
    );

    if (selectedLocation != null && selectedLocation.isNotEmpty) {
      setState(() {
        _locationController.text = selectedLocation;
      });
    }
  }

  void _saveSchedule() {
    if (!_formKey.currentState!.validate()) return;

    // 현재 여행 정보 가져오기
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) {
      dev.log('일정 저장 실패: 현재 여행 정보 없음');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('여행 정보를 찾을 수 없습니다. 다시 시도해주세요.')));
      return;
    }

    if (widget.scheduleId != null) {
      // 기존 일정 수정
      final updatedSchedule = Schedule(
        id: widget.scheduleId!,
        travelId: currentTravel.id,
        date: widget.date,
        time: _selectedTime,
        location: _locationController.text,
        memo: _memoController.text,
        dayNumber: widget.dayNumber,
      );

      ref
          .read(travelsProvider.notifier)
          .updateSchedule(currentTravel.id, updatedSchedule);

      dev.log('일정 수정 완료: ${widget.scheduleId}');
    } else {
      // 새 일정 추가
      final newSchedule = Schedule(
        id: const Uuid().v4(),
        travelId: currentTravel.id,
        date: widget.date,
        time: _selectedTime,
        location: _locationController.text,
        memo: _memoController.text,
        dayNumber: widget.dayNumber,
      );

      ref
          .read(travelsProvider.notifier)
          .addSchedule(currentTravel.id, newSchedule);

      dev.log('새 일정 추가 완료: ${newSchedule.id}');
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                B2bText.bold(
                  type: B2bTextType.title3,
                  text: widget.scheduleId != null ? '일정 수정' : '일정 추가',
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: $b2bToken.color.gray400.resolve(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            B2bText.medium(
              type: B2bTextType.body2,
              text: '시간',
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: $b2bToken.color.gray300.resolve(context),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    B2bText.regular(
                      type: B2bTextType.body2,
                      text:
                          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      color: $b2bToken.color.gray400.resolve(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            B2bText.medium(
              type: B2bTextType.body2,
              text: '장소',
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectLocation(context),
              child: B2bTextField(
                status: B2bTextFieldStatus.before,
                size: B2bTextFieldSize.medium,
                boder: B2bTextFieldBoder.box,
                isError: false,
              ),
            ),
            // TextFormField(
            //   controller: _locationController,
            //   readOnly: true,
            //   decoration: InputDecoration(
            //     hintText: '장소를 선택하세요',
            //     contentPadding: const EdgeInsets.symmetric(
            //       horizontal: 16,
            //       vertical: 12,
            //     ),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     enabledBorder: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(8),
            //       borderSide: BorderSide(
            //         color: $b2bToken.color.gray300.resolve(context),
            //       ),
            //     ),
            //     suffixIcon: Icon(
            //       Icons.search,
            //       color: $b2bToken.color.gray400.resolve(context),
            //     ),
            //   ),
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return '장소를 선택해주세요';
            //     }
            //     return null;
            //   },
            // ),
            // ),
            const SizedBox(height: 16),
            B2bText.medium(
              type: B2bTextType.body2,
              text: '메모',
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _memoController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '메모를 입력하세요',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: $b2bToken.color.gray300.resolve(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: B2bButton.medium(
                title: widget.scheduleId != null ? '수정 완료' : '추가 완료',
                type: B2bButtonType.primary,
                onTap: _saveSchedule,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
