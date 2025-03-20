import 'package:design_systems/dino/dino.dart';
import 'package:design_systems/dino/components/textfield/textfield.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:travelee/data/models/schedule/schedule.dart';
import 'package:travelee/data/models/location/location_data.dart';
import 'package:travelee/presentation/providers/travel_state_provider.dart';
import 'package:travelee/router.dart';
import 'package:travelee/presentation/modal/time_picker_modal.dart';
import 'package:travelee/presentation/screens/travel/edit/location_search_screen.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as dev;

class ScheduleInputModal extends ConsumerStatefulWidget {
  final TimeOfDay initialTime;
  final String initialLocation;
  final String initialMemo;
  final DateTime date;
  final int dayNumber;
  final String? scheduleId; // null이면 신규 일정, 값이 있으면 기존 일정 수정
  final double initialLatitude;
  final double initialLongitude;

  const ScheduleInputModal({
    super.key,
    required this.initialTime,
    required this.initialLocation,
    required this.initialMemo,
    required this.date,
    required this.dayNumber,
    this.scheduleId,
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  ConsumerState<ScheduleInputModal> createState() => _ScheduleInputModalState();
}

class _ScheduleInputModalState extends ConsumerState<ScheduleInputModal> {
  final _locationController = TextEditingController();
  final _memoController = TextEditingController();
  late TimeOfDay _selectedTime;
  final _formKey = GlobalKey<FormState>();
  LocationData? _locationData;

  // 신규 일정인지 수정 모드인지 확인
  bool get isEditMode => widget.scheduleId != null;

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.initialLocation;
    _memoController.text = widget.initialMemo;
    _selectedTime = widget.initialTime;
    _locationData = LocationData(
      latitude: widget.initialLatitude,
      longitude: widget.initialLongitude,
      location: widget.initialLocation,
    );
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
    final dayData = ref.watch(dayDataProvider(widget.date));
    final countryCode = dayData?.countryCode ?? '';
    final result = await ref.read(routerProvider).push<LocationData>(
      LocationSearchScreen.routePath,
      extra: {
        'location': _locationController.text,
        'latitude': _locationData?.latitude ?? 0,
        'longitude': _locationData?.longitude ?? 0,
        'countryCode': countryCode,
      },
    );

    setState(() {
      _locationData = result;
    });
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
    if (isEditMode) {
      // 기존 일정 수정
      final updatedSchedule = Schedule(
        id: widget.scheduleId!,
        travelId: currentTravel.id,
        date: widget.date,
        time: _selectedTime,
        location: _locationController.text,
        memo: _memoController.text,
        dayNumber: widget.dayNumber,
        latitude: _locationData?.latitude,
        longitude: _locationData?.longitude,
      );

      ref
          .read(travelsProvider.notifier)
          .updateSchedule(currentTravel.id, updatedSchedule);

      dev.log('일정 수정 완료: ${widget.scheduleId}');
    } else {
      // 신규 일정 추가
      final newSchedule = Schedule(
        id: const Uuid().v4(),
        travelId: currentTravel.id,
        date: widget.date,
        time: _selectedTime,
        location: _locationController.text,
        memo: _memoController.text,
        dayNumber: widget.dayNumber,
        latitude: _locationData?.latitude,
        longitude: _locationData?.longitude,
      );

      ref
          .read(travelsProvider.notifier)
          .addSchedule(currentTravel.id, newSchedule);

      dev.log('신규 일정 추가 완료');
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
                DinoText(
                  type: DinoTextType.bodyXL,
                  text: isEditMode ? '일정 수정' : '일정 추가',
                  color: $dinoToken.color.black.resolve(context),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: $dinoToken.color.blingGray400.resolve(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DinoText(
                        type: DinoTextType.bodyM,
                        text: '시간',
                        color: $dinoToken.color.black.resolve(context),
                      ),
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: $dinoToken.color.blingGray300
                                  .resolve(context),
                              width: 0.7,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              DinoText(
                                type: DinoTextType.bodyM,
                                text:
                                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                              ),
                              const Spacer(),
                              Icon(
                                Icons.access_time,
                                color: $dinoToken.color.blingGray400
                                    .resolve(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DinoText(
                        type: DinoTextType.bodyM,
                        text: '위치',
                        color: $dinoToken.color.black.resolve(context),
                      ),
                      GestureDetector(
                        onTap: () => _selectLocation(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: $dinoToken.color.blingGray300
                                  .resolve(context),
                              width: 0.7,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const DinoText(
                                type: DinoTextType.bodyM,
                                text: '지도',
                              ),
                              const Spacer(),
                              Icon(
                                Icons.location_on,
                                color: $dinoToken.color.blingGray400
                                    .resolve(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DinoText(
              type: DinoTextType.bodyM,
              text: '장소',
              color: $dinoToken.color.black.resolve(context),
            ),
            const SizedBox(height: 8),
            B2bTextField(
              status: B2bTextFieldStatus.before,
              size: B2bTextFieldSize.medium,
              boder: B2bTextFieldBoder.box,
              isError: false,
              hint: '장소, 할일을 입력하세요',
              initialValue: widget.initialLocation,
              onChanged: (value) {
                _locationController.text = value;
                return value;
              },
            ),
            const SizedBox(height: 16),
            DinoText(
              type: DinoTextType.bodyM,
              text: '메모',
              color: $dinoToken.color.black.resolve(context),
            ),
            const SizedBox(height: 8),
            B2bTextField(
              status: B2bTextFieldStatus.before,
              size: B2bTextFieldSize.large,
              boder: B2bTextFieldBoder.box,
              isError: false,
              hint: '메모를 입력하세요',
              initialValue: widget.initialMemo,
              onChanged: (value) {
                _memoController.text = value;
                return value;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: B2bButton.medium(
                title: isEditMode ? '수정 완료' : '추가 완료',
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
