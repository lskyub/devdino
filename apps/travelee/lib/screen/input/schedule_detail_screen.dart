import 'package:country_icons/country_icons.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:design_systems/b2b/components/textfield/textfield.dart';
import 'package:design_systems/b2b/components/textfield/textfield.variant.dart';
import 'package:travelee/data/controllers/schedule_detail_controller.dart';
import 'package:travelee/models/schedule.dart';
import 'package:travelee/presentation/screens/input/schedule_input_modal.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/screen/input/time_picker_modal.dart';
import 'package:travelee/screen/input/location_search_screen.dart';
import 'package:travelee/screen/input/country_select_modal.dart';
import 'package:travelee/presentation/widgets/schedule/schedule_item.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as dev;

/// 일정 상세 화면
/// 특정 날짜의 일정 목록을 보여주고 관리하는 화면
class ScheduleDetailScreen extends ConsumerStatefulWidget {
  static const routeName = 'schedule_detail';
  static const routePath = '/schedule/detail';

  final DateTime date;
  final int dayNumber;

  const ScheduleDetailScreen({
    super.key,
    required this.date,
    required this.dayNumber,
  });

  @override
  ConsumerState<ScheduleDetailScreen> createState() =>
      _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends ConsumerState<ScheduleDetailScreen> {
  late DateTime date;

  // 일정 입력 관련 변수
  final _locationController = TextEditingController();
  final _memoController = TextEditingController();
  late TimeOfDay _selectedTime;
  final _formKey = GlobalKey<FormState>();
  String? _editingScheduleId;
  bool _isEditingSchedule = false;

  @override
  void initState() {
    super.initState();
    date = widget.date;
    _selectedTime = TimeOfDay.now();

    // 백업 생성
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scheduleDetailControllerProvider).createBackup(date);
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  // 나가기 전 변경 사항 저장 여부 확인 다이얼로그
  Future<bool?> _showExitConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: B2bText.bold(
          type: B2bTextType.title3,
          text: '변경 사항 저장',
        ),
        content: B2bText.regular(
          type: B2bTextType.body2,
          text: '변경된 내용이 있습니다.\n저장하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              dev.log('다이얼로그 - [저장 안 함] 선택');
              Navigator.pop(context, false);
            },
            child: B2bText.medium(
              type: B2bTextType.body2,
              text: '저장 안 함',
              color: Colors.red,
            ),
          ),
          TextButton(
            onPressed: () {
              dev.log('다이얼로그 - [취소] 선택');
              Navigator.pop(context, null);
            },
            child: B2bText.medium(
              type: B2bTextType.body2,
              text: '취소',
              color: $b2bToken.color.gray400.resolve(context),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              dev.log('다이얼로그 - [저장] 선택');
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: $b2bToken.color.primary.resolve(context),
            ),
            child: B2bText.medium(
              type: B2bTextType.body2,
              text: '저장',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 일정 추가 시작
  void _addSchedule() {
    final controller = ref.read(scheduleDetailControllerProvider);
    final currentTravel = controller.currentTravel;
    if (currentTravel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('여행 정보를 찾을 수 없습니다. 다시 시도해주세요.')));
      return;
    }

    // 입력 필드 초기화
    _locationController.text = '';
    _memoController.text = '';
    _selectedTime = TimeOfDay.now();
    _editingScheduleId = null;

    setState(() {
      _isEditingSchedule = true;
    });
  }

  /// 일정 수정 시작
  void _editSchedule(Schedule schedule) {
    final controller = ref.read(scheduleDetailControllerProvider);
    final currentTravel = controller.currentTravel;
    if (currentTravel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('여행 정보를 찾을 수 없습니다. 다시 시도해주세요.')));
      return;
    }

    // schedule_input_modal.dart 사용
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ScheduleInputModal(
          initialTime: schedule.time,
          initialLocation: schedule.location,
          initialMemo: schedule.memo,
          date: date,
          dayNumber: widget.dayNumber,
          scheduleId: schedule.id,
        ),
      ),
    ).then((_) {
      // 변경사항 즉시 저장
      ref.read(travelsProvider.notifier).commitChanges();
      
      // 화면 갱신
      if (mounted) {
        setState(() {
          controller.hasChanges = true;
        });
      }
    });
  }

  /// 일정 삭제
  void _deleteSchedule(Schedule schedule) {
    // 확인 다이얼로그 없이 바로 삭제
    final controller = ref.read(scheduleDetailControllerProvider);
    controller.removeSchedule(schedule.id);

    // 변경사항 즉시 저장
    ref.read(travelsProvider.notifier).commitChanges();

    // 화면 갱신
    if (mounted) {
      setState(() {
        controller.hasChanges = true;
      });
    }
  }

  // 시간 선택
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

  // 위치 선택
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

  // 일정 저장
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

    if (_editingScheduleId != null) {
      // 기존 일정 수정
      final updatedSchedule = Schedule(
        id: _editingScheduleId!,
        travelId: currentTravel.id,
        date: date,
        time: _selectedTime,
        location: _locationController.text,
        memo: _memoController.text,
        dayNumber: widget.dayNumber,
      );

      ref
          .read(travelsProvider.notifier)
          .updateSchedule(currentTravel.id, updatedSchedule);

      dev.log('일정 수정 완료: $_editingScheduleId');
    } else {
      // 새 일정 추가
      final newSchedule = Schedule(
        id: const Uuid().v4(),
        travelId: currentTravel.id,
        date: date,
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

    final controller = ref.read(scheduleDetailControllerProvider);
    setState(() {
      _isEditingSchedule = false;
      controller.hasChanges = true;
    });

    // 변경사항 즉시 저장
    ref.read(travelsProvider.notifier).commitChanges();
  }

  // 일정 편집 취소
  void _cancelEditing() {
    setState(() {
      _isEditingSchedule = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 가져오기
    final controller = ref.watch(scheduleDetailControllerProvider);

    // 현재 여행 정보 가져오기
    final currentTravel = ref.watch(currentTravelProvider);
    if (currentTravel == null) {
      return _buildErrorScreen(context);
    }

    // 현재 날짜의 DayData 가져오기 (새로고침 보장을 위해 watch 사용)
    ref.invalidate(dayDataProvider(date));
    final dayData = ref.watch(dayDataProvider(date));

    // 국가 및 국기 정보
    String selectedCountryName = currentTravel.destination.isNotEmpty
        ? currentTravel.destination.first
        : '';
    String flagEmoji = currentTravel.countryInfos.isNotEmpty
        ? currentTravel.countryInfos.first.flagEmoji
        : "🏳️";
    String selectedCountryCode = currentTravel.countryInfos.isNotEmpty
        ? currentTravel.countryInfos.first.countryCode
        : "";
    // DayData가 있으면 해당 정보 사용
    if (dayData != null && dayData.countryName.isNotEmpty) {
      selectedCountryName = dayData.countryName;
      flagEmoji = dayData.flagEmoji.isNotEmpty ? dayData.flagEmoji : flagEmoji;
      selectedCountryCode = dayData.countryCode.isNotEmpty
          ? dayData.countryCode
          : selectedCountryCode;
    }

    return WillPopScope(
      onWillPop: () async {
        // 변경 사항이 있으면 확인 대화상자 표시
        if (controller.hasChanges) {
          final shouldSaveChanges = await _showExitConfirmDialog(context);

          if (shouldSaveChanges == null) {
            // 취소 - 화면에 계속 머무름
            return false;
          }

          if (!shouldSaveChanges) {
            // 저장 안 함 - 백업에서 복원
            controller.restoreFromBackup(date);
            return true;
          }

          // 저장 - 그냥 나감
          ref.read(travelsProvider.notifier).commitChanges();
          return true;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(
            context, flagEmoji, selectedCountryName, selectedCountryCode),
        body: Column(
          children: [
            const SizedBox(height: 8),
            // 일정 입력 폼 (상단에 고정)
            _buildCompactInputForm(context),
            const SizedBox(height: 8),
            // 일정 리스트 (확장 가능)
            Expanded(
              child: _buildScheduleList(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 에러 화면 빌드
  Widget _buildErrorScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: $b2bToken.color.gray400.resolve(context),
            ),
            const SizedBox(height: 16),
            B2bText.medium(
              type: B2bTextType.body2,
              text: '여행 정보를 찾을 수 없습니다',
              color: $b2bToken.color.gray400.resolve(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }

  /// 앱바 빌드
  PreferredSizeWidget _buildAppBar(BuildContext context, String flagEmoji,
      String selectedCountryName, String selectedCountryCode) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              B2bText.bold(
                type: B2bTextType.title3,
                text: 'Day ${widget.dayNumber}',
                color: $b2bToken.color.labelNomal.resolve(context),
              ),
            ],
          ),
          B2bText.regular(
            type: B2bTextType.caption2,
            text: '${date.year}년 ${date.month}월 ${date.day}일',
            color: $b2bToken.color.gray400.resolve(context),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          dev.log('ScheduleDetailScreen - 뒤로가기 버튼 클릭');

          // 변경사항 저장
          ref.read(travelsProvider.notifier).commitChanges();

          // 현재 여행 ID 가져오기
          final travelId = ref.read(currentTravelIdProvider);

          // 뒤로 가기
          Navigator.pop(context, true);

          // 변경된 정보가 즉시 반영되도록 프로바이더 갱신
          // 작업이 비동기적으로 처리되도록 조금 딜레이를 줌
          Future.delayed(const Duration(milliseconds: 50), () {
            // 현재 여행 정보가 메인 화면에 반영되도록 ID 재설정
            if (travelId.isNotEmpty) {
              dev.log('ScheduleDetailScreen - 부모 화면 갱신을 위한 상태 업데이트');
              ref.read(currentTravelIdProvider.notifier).state = "";
              ref.read(currentTravelIdProvider.notifier).state = travelId;
            }
          });
        },
        icon: SvgPicture.asset(
          'assets/icons/back.svg',
          width: 27,
          height: 27,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => _selectCountry(),
          child: Container(
            width: 30,
            height: 30,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: $b2bToken.color.gray100.resolve(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: $b2bToken.color.gray100.resolve(context),
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.zero,
              child: FittedBox(
                fit: BoxFit.cover,
                child: selectedCountryCode.isEmpty
                  ? const Icon(Icons.flag, color: Colors.grey) // 국가 코드가 없는 경우 기본 아이콘 표시
                  : CountryIcons.getSvgFlag(selectedCountryCode),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16)
      ],
    );
  }

  /// 일정 목록 빌드
  Widget _buildScheduleList(BuildContext context) {
    final controller = ref.read(scheduleDetailControllerProvider);

    // 현재 날짜의 일정 목록
    final schedules = ref.watch(dateSchedulesProvider(date));

    // 일정을 시간순으로 정렬
    final sortedSchedules = controller.sortSchedulesByTime(schedules);

    if (sortedSchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
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
      );
    } else {
      return ListView.builder(
        itemCount: sortedSchedules.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final schedule = sortedSchedules[index];
          return ScheduleItem(
            schedule: schedule,
            onEdit: () => _editSchedule(schedule),
            onDelete: () => _deleteSchedule(schedule),
          );
        },
      );
    }
  }

  /// 컴팩트한 일정 입력 폼 빌드 (하단에 고정)
  Widget _buildCompactInputForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: $b2bToken.color.gray200.resolve(context),
            width: 1,
          ),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                // 장소/할일 입력
                Expanded(
                  child: B2bTextField(
                    status: B2bTextFieldStatus.before,
                    size: B2bTextFieldSize.medium,
                    hint: '장소 또는 할일 입력',
                    isError: false,
                    onChanged: (value) {
                      _locationController.text = value;
                      return value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // 시간 선택
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: $b2bToken.color.gray400.resolve(context),
                        ),
                        const SizedBox(width: 4),
                        B2bText.regular(
                          type: B2bTextType.body2,
                          text:
                              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: $b2bToken.color.gray400.resolve(context),
                        ),
                        const SizedBox(width: 4),
                        B2bText.regular(
                          type: B2bTextType.body2,
                          text: '위치',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: B2bTextField(
                    status: B2bTextFieldStatus.before,
                    size: B2bTextFieldSize.medium,
                    isError: false,
                    hint: '메모',
                    onChanged: (value) {
                      _memoController.text = value;
                      return value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // 저장 버튼
                GestureDetector(
                  onTap: _saveSchedule,
                  child: Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: $b2bToken.color.primary.resolve(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// 국가 선택
  void _selectCountry() async {
    final controller = ref.read(scheduleDetailControllerProvider);
    final travel = controller.currentTravel;
    if (travel == null) {
      dev.log('국가 선택 실패: 현재 여행 정보 없음');
      return;
    }

    final dayData = controller.getDayData(date);
    final currentCountryName = dayData?.countryName ?? '';
    final currentFlag = dayData?.flagEmoji ?? '';
    final currentCode = dayData?.countryCode ?? '';

    dev.log(
        '현재 선택된 국가: $currentCountryName, 플래그: $currentFlag, 코드: $currentCode');

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => CountrySelectModal(
        countryInfos: travel.countryInfos,
        currentCountryName: currentCountryName,
      ),
    );

    if (result != null && mounted) {
      final countryName = result['name'] ?? '';
      final flagEmoji = result['flag'] ?? '';
      final countryCode = result['code'] ?? '';
      
      dev.log('선택된 국가 정보: $countryName, 플래그: $flagEmoji, 코드: $countryCode');
      
      if (countryName.isNotEmpty) {
        try {
          // 국가 정보 업데이트
          controller.updateCountryInfo(
              date, countryName, flagEmoji, countryCode);

          // 즉시 변경사항 커밋 (저장)
          ref.read(travelsProvider.notifier).commitChanges();

          // Provider 캐시 초기화 및 상태 갱신
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final currentId = travel.id;
              ref.invalidate(dayDataProvider(date));
              ref.read(currentTravelIdProvider.notifier).state = "";
              ref.read(currentTravelIdProvider.notifier).state = currentId;

              setState(() {
                controller.hasChanges = true;
              });

              // 성공 알림
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$countryName 국가로 설정되었습니다'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          });
        } catch (e) {
          dev.log('국가 정보 설정 중 오류 발생: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('국가 정보 변경 중 오류가 발생했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
