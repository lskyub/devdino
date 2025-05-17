import 'package:country_icons/country_icons.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelee/data/controllers/schedule_detail_controller.dart';
import 'package:travelee/data/controllers/travel_detail_controller.dart';
import 'package:travelee/data/controllers/travel_controller.dart';
import 'package:travelee/data/models/schedule/day_schedule_data.dart';
import 'package:travelee/data/models/schedule/schedule.dart';
import 'package:travelee/data/models/travel/travel_model.dart';
import 'package:travelee/data/services/database_helper.dart';
import 'package:travelee/presentation/modal/country_select_modal.dart';
import 'package:travelee/presentation/modal/schedule_input_modal.dart';
import 'package:travelee/providers/travel_state_provider.dart'
    as travel_providers;
import 'package:travelee/core/utils/result_types.dart';
import 'package:travelee/core/utils/travel_date_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/presentation/widgets/travel_detail/day_item.dart';
import 'dart:developer' as dev;

import 'package:travelee/core/utils/travel_dialog_manager.dart';
import 'package:travelee/presentation/widgets/ad_banner_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/dino/components/text/text.dino.dart';

class TravelDetailScreen extends ConsumerStatefulWidget {
  static const routeName = 'travel_detail';
  static const routePath = '/travel_detail/:id';

  const TravelDetailScreen({super.key});

  @override
  ConsumerState<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends ConsumerState<TravelDetailScreen>
    with WidgetsBindingObserver {
  late FocusNode _focusNode;
  bool isEdit = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addObserver(this);

    // 페이지 로드 완료 후 백업 생성 및 ID 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // GoRouter에서 URL 매개변수 추출
      final router = GoRouter.of(context);
      final params = router.routeInformationProvider.value.uri.pathSegments;

      if (params.length > 1) {
        final travelId = params[1]; // travel_detail/:id에서 id 추출
        dev.log('TravelDetailScreen - 경로에서 여행 ID 추출: $travelId');
        ref.read(travel_providers.currentTravelIdProvider.notifier).state =
            travelId;
      }

      // 통합 컨트롤러를 사용하여 백업 생성
      final controller = ref.read(unifiedControllerProvider);
      controller.createBackup();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (state == AppLifecycleState.resumed) {
    //   // 앱이 포그라운드로 돌아왔을 때 데이터 새로고침
    //   final travel = ref.read(travel_providers.currentTravelProvider);
    //   if (travel != null && travel.startDate != null) {
    //     _refreshAllData();
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    // 통합 컨트롤러 가져오기
    final controller = ref.watch(unifiedControllerProvider);

    // Provider를 통해 여행 정보 가져오기
    final travelInfo = ref.watch(travel_providers.currentTravelProvider);

    // 변경 사항 감지
    ref.listen(travel_providers.travelChangesProvider, (previous, hasChanges) {
      dev.log('TravelDetailScreen - 변경 감지: $previous -> $hasChanges');
      if (hasChanges) {
        controller.hasChanges = true;
      }
    });

    // 여행 정보가 null이면 로딩 표시
    if (travelInfo == null) {
      return _buildLoadingScreen();
    }

    // 날짜가 null인 경우 임시 날짜 설정 (현재 날짜로)
    if (travelInfo.startDate == null || travelInfo.endDate == null) {
      // return _buildScreenWithTemporaryDates(context, travelInfo);
      Navigator.pop(context);
    }

    final dates = TravelDateFormatter.getDateRange(
        travelInfo.startDate!, travelInfo.endDate!);
    final daySchedules = _buildDaySchedulesFromDates(travelInfo, dates);

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && result != null) {
          _handleBackNavigation(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // 위쪽 정렬
                children: [
                  GestureDetector(
                    onTap: () => _handleBackNavigation(context),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 24, top: 8),
                      child: SvgPicture.asset(
                        'assets/icons/home.svg',
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CountryIcons.getSvgFlag(
                              travelInfo.countryInfos.first.countryCode),
                          const SizedBox(width: 8),
                          DinoText.custom(
                            fontSize: 17,
                            text: travelInfo.destination.join(', '),
                            color: $dinoToken.color.blingGray900,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      DinoText.custom(
                        fontSize: 11.24,
                        text:
                            '여행기간: ${TravelDateFormatter.formatDate(travelInfo.startDate)} ~ ${TravelDateFormatter.formatDate(travelInfo.endDate)}',
                        color: $dinoToken.color.blingGray400,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _refreshAllData,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, top: 2),
                      child: SvgPicture.asset(
                        'assets/icons/setting.svg',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Row(
            //   children: [
            //     SizedBox(
            //       width: 70,
            //       child: Align(
            //         alignment: Alignment.center,
            //         child: B2bText(
            //           text: 'DATE',
            //           type: DinoTextType.bodyS,
            //           color: $dinoToken.color.black.resolve(context),
            //         ),
            //       ),
            //     ),
            //     B2bText(
            //       text: 'EVENTS',
            //       type: DinoTextType.bodyS,
            //       color: $dinoToken.color.black.resolve(context),
            //     ),
            //     const Spacer(),
            //     IconButton(
            //       icon: isEdit
            //           ? Icon(
            //               Icons.visibility,
            //               color: $dinoToken.color.blingGray600.resolve(context),
            //             )
            //           : Icon(
            //               Icons.edit,
            //               color: $dinoToken.color.blingGray600.resolve(context),
            //             ),
            //       onPressed: () {
            //         setState(() {
            //           isEdit = !isEdit;
            //         });
            //       },
            //     ),
            //   ],
            // ),
            Divider(
              color: $dinoToken.color.blingGray75.resolve(context),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    itemCount: daySchedules.length,
                    itemBuilder: (context, index) {
                      var colorIndex = 0;
                      for (var i = 0; i < index; i++) {
                        colorIndex += daySchedules[i].schedules.length;
                      }
                      return DayItem(
                        index: index,
                        isEdit: isEdit,
                        dayData: daySchedules[index],
                        onScheduleTap: _editSchedule,
                        onScheduleDrop: _onScheduleDrop,
                        onSelectCountry: _selectCountry,
                        addSchedule: _addSchedule,
                        deleteSchedule: _deleteSchedule,
                        colorStartIndex: colorIndex,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SafeArea(
              child: Column(
                children: [
                  AdBannerWidget(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DayScheduleData> _buildDaySchedulesFromDates(
      TravelModel travelInfo, List<DateTime> dates) {
    final daySchedules = <DayScheduleData>[];

    for (final date in dates) {
      final dateKey = _formatDateKey(date);
      final schedulesForDay = travelInfo.schedules
          .where((s) =>
              s.date.year == date.year &&
              s.date.month == date.month &&
              s.date.day == date.day)
          .toList();

      String countryName =
          travelInfo.destination.isNotEmpty ? travelInfo.destination.first : '';
      String flagEmoji = travelInfo.countryInfos.isNotEmpty
          ? travelInfo.countryInfos.first.flagEmoji
          : '';
      String countryCode = travelInfo.countryInfos.isNotEmpty
          ? travelInfo.countryInfos.first.countryCode
          : '';

      if (travelInfo.dayDataMap.containsKey(dateKey)) {
        final savedDayData = travelInfo.dayDataMap[dateKey];
        if (savedDayData != null && savedDayData.countryName.isNotEmpty) {
          countryName = savedDayData.countryName;
          flagEmoji = savedDayData.flagEmoji;
          countryCode = savedDayData.countryCode;
        }
      }

      final dayNumber = dates.indexOf(date) + 1;

      daySchedules.add(DayScheduleData(
        date: date,
        countryName: countryName,
        flagEmoji: flagEmoji,
        countryCode: countryCode,
        dayNumber: dayNumber,
        schedules: schedulesForDay,
      ));
    }

    return daySchedules;
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _handleBackNavigation(BuildContext context) async {
    final controller = ref.read(unifiedControllerProvider);
    final travelInfo = controller.currentTravel;

    if (travelInfo == null) {
      Navigator.of(context).pop();
      return;
    }

    // 변경 관리자를 통해 변경사항 감지
    final isControllerHasChanges = controller.hasChanges;
    final isChangeManagerHasChanges = controller.detectChanges();
    final hasChanges = isControllerHasChanges || isChangeManagerHasChanges;

    dev.log(
        'TravelDetailScreen - 뒤로가기 감지: controller.hasChanges=$isControllerHasChanges, changeManager.hasChanges=$isChangeManagerHasChanges');

    if (hasChanges) {
      // 실제 변경사항 있는지 마지막 확인
      final backupTravel = ref.read(travel_providers.travelBackupProvider);

      // 백업이 없으면 변경사항 있는 것으로 간주
      if (backupTravel == null) {
        dev.log('TravelDetailScreen - 백업이 없어 변경사항 있는 것으로 간주');
        // 변경 사항이 있으면 확인 다이얼로그 표시
        final saveResult = await _showExitConfirmDialog(context);
        await _handleSaveResult(saveResult);
        return;
      }

      // 실제 변경 여부 확인 (백업과 현재 데이터 비교)
      final hasActualChanges =
          _hasActualTravelChanges(backupTravel, travelInfo);
      dev.log('TravelDetailScreen - 실제 변경사항 확인: $hasActualChanges');

      if (!hasActualChanges) {
        dev.log('TravelDetailScreen - 실제 변경사항 없음: 확인 다이얼로그 없이 나가기');
        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }

      // 변경 사항이 있으면 확인 다이얼로그 표시
      final saveResult = await _showExitConfirmDialog(context);
      await _handleSaveResult(saveResult);
    } else {
      // 변경 사항이 없으면 바로 이전 화면으로 이동
      dev.log('TravelDetailScreen - 변경사항 없음, 바로 나가기');
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  // 저장 결과 처리 helper 메서드
  Future<void> _handleSaveResult(SaveResult? saveResult) async {
    final controller = ref.read(unifiedControllerProvider);

    if (saveResult == SaveResult.save) {
      // 변경 사항 저장
      dev.log('TravelDetailScreen - 변경사항 저장 후 나가기');
      ref.read(travel_providers.travelsProvider.notifier).commitChanges();

      // 저장 후 변경사항 플래그 초기화
      controller.hasChanges = false;
      ref.read(travel_providers.travelChangesProvider.notifier).state = false;

      final currentTravel = ref.read(travel_providers.currentTravelProvider);
      if (currentTravel != null) {
        ref.read(databaseHelperProvider).saveTravel(currentTravel);
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // 화면 나가기
    } else if (saveResult == SaveResult.discard) {
      // 변경 사항 취소 - 백업 데이터로 복원
      dev.log('TravelDetailScreen - 변경사항 취소 후 나가기');

      // 백업 복원
      await controller.restoreFromBackup();

      if (!mounted) return;
      Navigator.of(context).pop(); // 화면 나가기
    }
    // SaveResult.cancel이면 (다이얼로그에서 취소 선택) 아무것도 하지 않음
  }

  /// 나가기 전 변경 사항 저장 여부 확인 다이얼로그
  Future<SaveResult> _showExitConfirmDialog(BuildContext context) async {
    dev.log('TravelDetailScreen - 변경 사항 저장 다이얼로그 표시');
    final result = await showDialog<SaveResult>(
      context: context,
      barrierDismissible: false, // 바깥 영역 터치로 닫기 방지
      builder: (context) => AlertDialog(
        title: const Text('변경 사항 저장'),
        content: const Text('변경된 내용이 있습니다.\n저장하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              dev.log('다이얼로그 - [저장 안 함] 선택');
              Navigator.pop(context, SaveResult.discard);
            },
            child: const Text('저장 안 함', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              dev.log('다이얼로그 - [취소] 선택');
              Navigator.pop(context, SaveResult.cancel);
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              dev.log('다이얼로그 - [저장] 선택');
              Navigator.pop(context, SaveResult.save);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
    // 결과가 null인 경우 기본값으로 취소 반환
    return result ?? SaveResult.cancel;
  }

  // 실제 여행 데이터 변경 확인 메서드
  bool _hasActualTravelChanges(TravelModel backup, TravelModel current) {
    // 기본 정보 변경 확인
    if (backup.title != current.title ||
        !_areDatesEqual(backup.startDate, current.startDate) ||
        !_areDatesEqual(backup.endDate, current.endDate)) {
      return true;
    }

    // 목적지 변경 확인
    if (backup.destination.length != current.destination.length) {
      return true;
    }

    for (int i = 0; i < backup.destination.length; i++) {
      if (i >= current.destination.length ||
          backup.destination[i] != current.destination[i]) {
        return true;
      }
    }

    // 일정 수 변경 확인
    if (backup.schedules.length != current.schedules.length) {
      return true;
    }

    // 일정 내용 비교
    for (int i = 0; i < backup.schedules.length; i++) {
      final backupSchedule = backup.schedules[i];
      final currentSchedule = current.schedules[i];

      if (backupSchedule.id != currentSchedule.id ||
          backupSchedule.dayNumber != currentSchedule.dayNumber ||
          backupSchedule.date != currentSchedule.date ||
          backupSchedule.time != currentSchedule.time ||
          backupSchedule.location != currentSchedule.location ||
          backupSchedule.memo != currentSchedule.memo ||
          backupSchedule.latitude != currentSchedule.latitude ||
          backupSchedule.longitude != currentSchedule.longitude) {
        return true;
      }
    }

    // dayDataMap 비교 (국가 정보만)
    if (backup.dayDataMap.length != current.dayDataMap.length) {
      return true;
    }

    for (final entry in backup.dayDataMap.entries) {
      final dateKey = entry.key;
      final backupDayData = entry.value;

      if (!current.dayDataMap.containsKey(dateKey)) {
        return true;
      }

      final currentDayData = current.dayDataMap[dateKey];
      if (currentDayData == null) {
        return true;
      }

      // 국가 정보만 비교
      if (backupDayData.countryName != currentDayData.countryName ||
          backupDayData.flagEmoji != currentDayData.flagEmoji ||
          backupDayData.countryCode != currentDayData.countryCode) {
        return true;
      }
    }

    return false;
  }

  // 날짜 동등 비교 헬퍼
  bool _areDatesEqual(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return true;
    if (date1 == null || date2 == null) return false;

    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _refreshAllData() async {
    final controller = ref.watch(travelDetailControllerProvider);
    await TravelDialogManager.showEditTravelDialog(context, ref);
    controller.setModified(); // 여행 정보 편집 후 수정 플래그 설정
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    super.dispose();
  }

  void _selectCountry(DateTime date) async {
    final travel = ref.watch(travel_providers.currentTravelProvider);
    if (travel == null) {
      dev.log('국가 선택 실패: 현재 여행 정보 없음');
      return;
    }

    final dayData = ref.watch(travel_providers.dayDataProvider(date));
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
          ref.read(travel_providers.travelsProvider.notifier).commitChanges();

          // 상태 갱신 - 더 효율적인 방식으로 개선
          if (mounted) {
            // 캐시 초기화
            ref.invalidate(travel_providers.dayDataProvider(date));

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

  /// 일정 추가
  void _addSchedule(DayScheduleData dayData) {
    final currentTravel = ref.watch(travel_providers.currentTravelProvider);
    if (currentTravel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('여행 정보를 찾을 수 없습니다. 다시 시도해주세요.')));
      return;
    }
    // 해당 날짜가 며칠째인지 계산
    final dayNumber = ref
        .read(unifiedControllerProvider)
        .getDayNumber(currentTravel.startDate!, dayData.date);

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
          initialLatitude: 0,
          initialLongitude: 0,
          date: dayData.date,
          dayNumber: dayNumber,
        ),
      ),
    ).then((_) {
      if (mounted) {
        ref.read(scheduleDetailControllerProvider).hasChanges = true;
      }
    });
  }

  /// 일정 수정
  void _editSchedule(DayScheduleData dayData, Schedule schedule) {
    final currentTravel = ref.watch(travel_providers.currentTravelProvider);
    if (currentTravel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('여행 정보를 찾을 수 없습니다. 다시 시도해주세요.')));
      return;
    }
    // 해당 날짜가 며칠째인지 계산
    final dayNumber = ref
        .read(unifiedControllerProvider)
        .getDayNumber(currentTravel.startDate!, dayData.date);

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
          initialLatitude: schedule.latitude ?? 0,
          initialLongitude: schedule.longitude ?? 0,
          date: dayData.date,
          dayNumber: dayNumber,
          scheduleId: schedule.id,
        ),
      ),
    ).then((_) {
      if (mounted) {
        ref.read(scheduleDetailControllerProvider).hasChanges = true;
      }
    });
  }

  /// 일정 삭제
  _deleteSchedule(Schedule schedule) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);

              ref
                  .read(scheduleDetailControllerProvider)
                  .removeSchedule(schedule.id);

              // 변경사항 즉시 저장
              ref
                  .read(travel_providers.travelsProvider.notifier)
                  .commitChanges();

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

  void _onScheduleDrop(Schedule schedule, DateTime newDate) {
    final controller = ref.read(unifiedControllerProvider);
    // 날짜가 변경된 새로운 일정 생성
    final updatedSchedule = schedule.copyWith(
      date: newDate,
      dayNumber: controller.getDayNumber(
        ref.read(travel_providers.currentTravelProvider)!.startDate!,
        newDate,
      ),
    );

    // 기존 일정 삭제 및 새 일정 추가
    ref.read(travel_providers.travelsProvider.notifier).updateSchedule(
          controller.currentTravelId,
          updatedSchedule,
        );

    // 변경사항 저장
    ref.read(travel_providers.travelsProvider.notifier).commitChanges();

    // UI 갱신
    setState(() {});

    // 사용자에게 피드백 제공
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('일정이 ${newDate.month}월 ${newDate.day}일로 이동되었습니다'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
