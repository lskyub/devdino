import 'package:country_icons/country_icons.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:travelee/data/controllers/schedule_detail_controller.dart';
import 'package:travelee/models/schedule.dart';
import 'package:travelee/presentation/screens/input/schedule_input_modal.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/presentation/screens/input/country_select_modal.dart';
import 'package:travelee/presentation/widgets/schedule/schedule_item.dart';
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
  /// 컨트롤러 인스턴스
  late DateTime date;

  @override
  void initState() {
    super.initState();
    date = widget.date;

    // 백업 생성
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scheduleDetailControllerProvider).createBackup(date);
    });
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

  /// 일정 추가
  void _addSchedule() {
    final currentTravel = ref.watch(currentTravelProvider);
    if (currentTravel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('여행 정보를 찾을 수 없습니다. 다시 시도해주세요.')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ScheduleInputModal(
          initialTime: TimeOfDay.now(),
          initialLocation: '',
          initialMemo: '',
          date: date,
          dayNumber: widget.dayNumber,
        ),
      ),
    ).then((_) {
      if (mounted) {
        ref.read(scheduleDetailControllerProvider).hasChanges = true;
      }
    });
  }

  /// 일정 수정
  void _editSchedule(Schedule schedule) {
    final currentTravel = ref.watch(currentTravelProvider);
    if (currentTravel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('여행 정보를 찾을 수 없습니다. 다시 시도해주세요.')));
      return;
    }

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
      if (mounted) {
        ref.read(scheduleDetailControllerProvider).hasChanges = true;
      }
    });
  }

  /// 국가 선택
  void _selectCountry() async {
    final travel = ref.watch(currentTravelProvider);
    if (travel == null) {
      dev.log('국가 선택 실패: 현재 여행 정보 없음');
      return;
    }

    final dayData = ref.watch(dayDataProvider(date));
    final currentCountryName = dayData?.countryName ?? '';
    final currentFlag = dayData?.flagEmoji ?? '';

    dev.log('현재 선택된 국가: $currentCountryName, 플래그: $currentFlag');

    // 국가 선택 모달 표시
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

      if (countryName.isNotEmpty) {
        // 로딩 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('국가 정보 업데이트 중...'),
            duration: Duration(milliseconds: 500),
          ),
        );

        try {
          // 국가 정보 업데이트
          ref
              .read(scheduleDetailControllerProvider)
              .updateCountryInfo(date, countryName, flagEmoji, countryCode);

          // 즉시 변경사항 커밋 (저장)
          ref.read(travelsProvider.notifier).commitChanges();

          // 상태 갱신 - 더 효율적인 방식으로 개선
          if (mounted) {
            // 캐시 초기화
            ref.invalidate(dayDataProvider(date));

            // 변경사항 플래그 설정
            ref.read(scheduleDetailControllerProvider).hasChanges = true;

            // UI 갱신 트리거
            setState(() {
              dev.log('국가 정보 변경 후 UI 갱신: $countryName ($countryCode)');
            });

            // 성공 알림
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$countryName 국가로 설정되었습니다'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          dev.log('국가 정보 설정 중 오류 발생: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('국가 정보 변경 실패: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  /// 일정 삭제
  void _deleteSchedule(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              ref
                  .read(scheduleDetailControllerProvider)
                  .removeSchedule(schedule.id);

              // 변경사항 즉시 저장
              ref.read(travelsProvider.notifier).commitChanges();

              // 화면 갱신
              if (mounted) {
                ref.read(scheduleDetailControllerProvider).hasChanges = true;
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 현재 여행 정보 가져오기
    final currentTravel = ref.watch(currentTravelProvider);
    if (currentTravel == null) {
      return _buildErrorScreen(context);
    }

    // 현재 날짜의 DayData 가져오기 (Provider 상태 사용)
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
        if (ref.read(scheduleDetailControllerProvider).hasChanges) {
          final shouldSaveChanges = await _showExitConfirmDialog(context);

          if (shouldSaveChanges == null) {
            // 취소 - 화면에 계속 머무름
            return false;
          }

          if (!shouldSaveChanges) {
            // 저장 안 함 - 백업에서 복원
            ref.read(scheduleDetailControllerProvider).restoreFromBackup(date);

            // 변경사항 없음으로 표시하고 화면 닫기
            Navigator.pop(context, false);
            return true;
          }

          // 저장 - 변경사항 있음으로 표시하고 화면 닫기
          ref.read(travelsProvider.notifier).commitChanges();

          // 로그 추가
          dev.log('ScheduleDetailScreen - 변경사항 저장 후 화면 닫기');

          // 명시적으로 변경사항 있음(true) 전달
          Navigator.pop(context, true);
          return true;
        }

        // 변경사항이 없을 때는 false 반환 (변경 없음)
        dev.log('ScheduleDetailScreen - 변경사항 없이 뒤로가기');
        Navigator.pop(context, false);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(
            context, flagEmoji, selectedCountryName, selectedCountryCode),
        body: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: _buildScheduleList(context),
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
    dev.log('selectedCountryCode: $selectedCountryCode');
    return AppBar(
      surfaceTintColor: Colors.transparent, // 자동 색상 변
      title: Row(
        children: [
          B2bText.bold(
            type: B2bTextType.title3,
            text: 'Day ${widget.dayNumber}',
            color: $b2bToken.color.labelNomal.resolve(context),
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
          // Future.delayed(const Duration(milliseconds: 50), () {
          // 현재 여행 정보가 메인 화면에 반영되도록 ID 재설정
          if (travelId.isNotEmpty) {
            dev.log('ScheduleDetailScreen - 부모 화면 갱신을 위한 상태 업데이트');
            ref.read(currentTravelIdProvider.notifier).state = "";
            ref.read(currentTravelIdProvider.notifier).state = travelId;
          }
          // });
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
                    ? const Icon(Icons.flag,
                        color: Colors.grey) // 국가 코드가 없는 경우 기본 아이콘 표시
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
    // 현재 날짜의 일정 목록
    final schedules = ref.watch(dateSchedulesProvider(date));

    // 일정을 시간순으로 정렬
    final sortedSchedules = ref
        .read(scheduleDetailControllerProvider)
        .sortSchedulesByTime(schedules);

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
}

/// ScheduleDetailController를 제공하는 Provider
final scheduleDetailControllerProvider =
    Provider.autoDispose<ScheduleDetailController>((ref) {
  return ScheduleDetailController(ref);
});
