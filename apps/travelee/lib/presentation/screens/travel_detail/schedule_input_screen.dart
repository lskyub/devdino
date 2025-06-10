import 'dart:async';

import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mix/mix.dart';
import 'package:travelee/domain/entities/schedule.dart';
import 'package:travelee/domain/entities/location_data.dart';
import 'package:travelee/presentation/providers/travel_state_provider.dart';
import 'package:travelee/presentation/modal/time_picker_modal.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as dev;
import 'package:travelee/gen/app_localizations.dart';

class ScheduleInputScreen extends ConsumerStatefulWidget {
  static const routeName = 'scheduleInput';
  static const routePath = '/scheduleInput';

  final TimeOfDay initialTime;
  final String initialLocation;
  final String initialMemo;
  final DateTime date;
  final int dayNumber;
  final String? scheduleId; // null이면 신규 일정, 값이 있으면 기존 일정 수정
  final double initialLatitude;
  final double initialLongitude;

  const ScheduleInputScreen({
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
  ConsumerState<ScheduleInputScreen> createState() =>
      _ScheduleInputScreenState();
}

class _ScheduleInputScreenState extends ConsumerState<ScheduleInputScreen> {
  final _locationController = TextEditingController();
  final _memoController = TextEditingController();
  late TimeOfDay _selectedTime;
  LocationData? _locationData;
  ColorToken _locationBorderColor = $dinoToken.color.blingGray200;
  ColorToken _memoBorderColor = $dinoToken.color.blingGray200;

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
    _locationController.addListener(() {
      setState(() {
        _locationBorderColor = _locationController.text.isEmpty
            ? $dinoToken.color.blingGray200
            : $dinoToken.color.blingGray400;
      });
    });
    _memoController.addListener(() {
      setState(() {
        _memoBorderColor = _memoController.text.isEmpty
            ? $dinoToken.color.blingGray200
            : $dinoToken.color.blingGray400;
      });
    });
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

  // Future<void> _selectLocation(BuildContext context) async {
  //   final dayData = ref.watch(dayDataProvider(widget.date));
  //   final countryCode = dayData?.countryCode ?? '';
  //   final result = await ref.read(routerProvider).push<LocationData>(
  //     LocationSearchScreen.routePath,
  //     extra: {
  //       'location': _locationController.text,
  //       'latitude': _locationData?.latitude ?? 0,
  //       'longitude': _locationData?.longitude ?? 0,
  //       'countryCode': countryCode,
  //     },
  //   );

  //   setState(() {
  //     _locationData = result;
  //   });
  // }

  String getTimeFormat(TimeOfDay time) {
    // 오전 오후 추가
    final amPm = time.hour < 12 ? '오전' : '오후';
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return '$amPm ${hour.toString()}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _saveSchedule() {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent, // 자동 색상 변
        title: Align(
          alignment: Alignment.centerLeft,
          child: DinoText.custom(
            fontSize: 17,
            text: isEditMode ? '일정 수정' : '일정 추가',
            color: $dinoToken.color.blingGray900,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: SvgPicture.asset(
            'assets/icons/appbar_close.svg',
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: DinoText.custom(
                      fontSize: 14.22,
                      text: AppLocalizations.of(context)!.schedulePlace,
                      color: $dinoToken.color.blingGray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DinoTextField(
                    controller: _locationController,
                    borderColor: _locationBorderColor,
                    hint: AppLocalizations.of(context)!.enterPlace,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: DinoText.custom(
                      fontSize: 14.22,
                      text: AppLocalizations.of(context)!.scheduleTime,
                      color: $dinoToken.color.blingGray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: $dinoToken.color.blingGray400.resolve(context),
                          width: 0.7,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/clock_medium.svg',
                          ),
                          const SizedBox(width: 6),
                          DinoText.custom(
                            fontSize: 16,
                            text: getTimeFormat(_selectedTime),
                            color: $dinoToken.color.blingGray900,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // TODO 위치 추가 기능 이후 작업 필요
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 4),
                  //   child: DinoText.custom(
                  //     fontSize: 14.22,
                  //     text: '위치',
                  //     color: $dinoToken.color.blingGray600,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                  // GestureDetector(
                  //   onTap: () => _selectLocation(context),
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 16,
                  //       vertical: 12,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       border: Border.all(
                  //         color: $dinoToken.color.blingGray300.resolve(context),
                  //         width: 0.7,
                  //       ),
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         SvgPicture.asset(
                  //           'assets/icons/pin_small.svg',
                  //         ),
                  //         const SizedBox(width: 6),
                  //         DinoText.custom(
                  //           fontSize: 16,
                  //           text: _locationController.text,
                  //           color: $dinoToken.color.blingGray900,
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: DinoText.custom(
                      fontSize: 14.22,
                      text: AppLocalizations.of(context)!.scheduleMemo,
                      color: $dinoToken.color.blingGray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DinoTextField(
                    controller: _memoController,
                    maxLines: 4,
                    minLines: 4,
                    maxLength: 300,
                    borderColor: _memoBorderColor,
                    hint: AppLocalizations.of(context)!.enterMemo,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Divider(
            color: $dinoToken.color.blingGray75.resolve(context),
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: DinoButton.custom(
                type: DinoButtonType.solid,
                size: DinoButtonSize.full,
                state: _locationController.text.isEmpty
                    ? DinoButtonState.disabled
                    : DinoButtonState.base,
                verticalPadding: 18,
                textSize: 16,
                fontWeight: FontWeight.w700,
                textColor: $dinoToken.color.white,
                disabledTextColor: $dinoToken.color.white,
                disabledBackgroundColor: $dinoToken.color.blingGray300,
                backgroundColor: $dinoToken.color.brandBlingPurple600,
                title: isEditMode
                    ? AppLocalizations.of(context)!.editScheduleButton
                    : AppLocalizations.of(context)!.addScheduleButton,
                onTap: _saveSchedule,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
