import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/textfield/textfield.dart';
import 'package:design_systems/b2b/components/textfield/textfield.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/screen/input/location_search_screen.dart';
import 'package:travelee/screen/input/time_picker_modal.dart';

class ScheduleInputModal extends ConsumerStatefulWidget {
  final TimeOfDay initialTime;
  final String initialLocation;
  final String initialMemo;
  final Function(TimeOfDay time, String location, String memo) onSave;

  const ScheduleInputModal({
    super.key,
    required this.initialTime,
    required this.initialLocation,
    required this.initialMemo,
    required this.onSave,
  });

  @override
  ConsumerState<ScheduleInputModal> createState() => _ScheduleInputModalState();
}

class _ScheduleInputModalState extends ConsumerState<ScheduleInputModal> {
  late TimeOfDay _time;
  late TextEditingController _locationController;
  late TextEditingController _memoController;
  bool _isLocationEnabled = true;

  @override
  void initState() {
    super.initState();
    _time = widget.initialTime;
    _locationController = TextEditingController(text: widget.initialLocation);
    _memoController = TextEditingController(text: widget.initialMemo);
  }

  @override
  void dispose() {
    _locationController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation() async {
    final location = await context.push<String>(
      LocationSearchScreen.routePath,
      extra: _locationController.text,
    );
    if (location != null) {
      setState(() {
        _locationController.text = location;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimePickerModal(
        initialTime: _time,
      ),
    );
    if (time != null) {
      setState(() {
        _time = time;
      });
    }
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
              B2bText.medium(
                type: B2bTextType.body1,
                text: '일정 입력',
                color: $b2bToken.color.labelNomal.resolve(context),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: $b2bToken.color.gray400.resolve(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    B2bText.medium(
                      type: B2bTextType.body3,
                      text: '장소',
                      color: $b2bToken.color.labelNomal.resolve(context),
                    ),
                    GestureDetector(
                      onTap: _isLocationEnabled ? _searchLocation : null,
                      child: AbsorbPointer(
                        absorbing: !_isLocationEnabled,
                        child: B2bTextField(
                          hint: '장소를 입력하세요',
                          status: B2bTextFieldStatus.before,
                          size: B2bTextFieldSize.medium,
                          isError: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  B2bText.medium(
                    type: B2bTextType.body3,
                    text: '시간',
                    color: $b2bToken.color.labelNomal.resolve(context),
                  ),
                  GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 0.7,
                          ),
                        ),
                      ),
                      child: B2bText.medium(
                        type: B2bTextType.body2,
                        text:
                            '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                        color: $b2bToken.color.labelNomal.resolve(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  B2bText.medium(
                    type: B2bTextType.body3,
                    text: '위치',
                    color: $b2bToken.color.labelNomal.resolve(context),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_isLocationEnabled) {
                        context
                            .push(
                          LocationSearchScreen.routePath,
                          extra: _locationController.text,
                        )
                            .then((location) {
                          if (location != null) {
                            setState(() {
                              _locationController.text = location as String;
                            });
                          }
                        });
                      } else {
                        setState(() {
                          _isLocationEnabled = true;
                        });
                      }
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black,
                            width: 0.7,
                          ),
                        ),
                      ),
                      child: B2bText.medium(
                        type: B2bTextType.body2,
                        text: _isLocationEnabled ? '수정' : '입력',
                        color: _isLocationEnabled
                            ? $b2bToken.color.primary.resolve(context)
                            : $b2bToken.color.labelNomal.resolve(context),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          B2bTextField(
            hint: '메모를 입력하세요',
            status: B2bTextFieldStatus.before,
            size: B2bTextFieldSize.large,
            isError: false,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: B2bButton.medium(
              title: '저장',
              type: B2bButtonType.primary,
              onTap: () {
                widget.onSave(
                  _time,
                  _locationController.text,
                  _memoController.text,
                );
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
