import 'package:design_systems/dino/dino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelee/data/controllers/schedule_detail_controller.dart';
import 'package:travelee/data/controllers/travel_controller.dart';
import 'package:travelee/data/models/schedule/day_schedule_data.dart';
import 'package:travelee/data/models/schedule/schedule.dart';
import 'package:travelee/data/models/travel/travel_model.dart';
import 'package:travelee/presentation/modal/country_select_modal.dart';
import 'package:travelee/presentation/screens/travel_detail/schedule_input_screen.dart';
import 'package:travelee/presentation/widgets/country_and_date_row.dart';
import 'package:travelee/providers/travel_state_provider.dart'
    as travel_providers;
import 'package:travelee/core/utils/travel_date_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/presentation/widgets/travel_detail/day_item.dart';
import 'dart:developer' as dev;
import 'package:travelee/gen/app_localizations.dart';

import 'package:travelee/core/utils/travel_dialog_manager.dart';
import 'package:travelee/presentation/widgets/ad_banner_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:travelee/router.dart';
import 'package:travelee/presentation/screens/travel_detail/date_screen.dart';
import 'package:travelee/data/services/pdf_export_service.dart';
import 'package:travelee/data/models/db/travel_db_model.dart';
import 'package:travelee/gen/app_localizations.dart';

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
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _handleBackNavigation(context),
                    child: SvgPicture.asset(
                      'assets/icons/bottomnav_home_sel.svg',
                    ),
                  ),
                  DinoText.custom(
                    fontSize: 17,
                    text: AppLocalizations.of(context)!.travelScheduleTitle,
                    color: $dinoToken.color.blingGray900,
                    fontWeight: FontWeight.w500,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _settingTravel,
                    child: SvgPicture.asset(
                      'assets/icons/bottomnav_setting_sel.svg',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Divider(
              color: $dinoToken.color.blingGray75.resolve(context),
              height: 1,
            ),
            Container(
              height: 34,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16, right: 16),
              color: $dinoToken.color.blingGray50.resolve(context),
              child: CountryAndDateRow(
                countryInfos: travelInfo.countryInfos,
                dateText: TravelDateFormatter.formatDateRange(
                  travelInfo.startDate!,
                  travelInfo.endDate!,
                ),
              ),
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
            const SafeArea(child: AdBannerWidget()),
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

  Future<bool> _handleBackNavigation(BuildContext context) async {
    final travelNotifier = ref.read(travel_providers.travelsProvider.notifier);
    final hasChanges = ref.read(travel_providers.travelChangesProvider);

    if (hasChanges) {
      // 변경사항이 있으면 자동으로 저장
      travelNotifier.commitChanges();
      ref.read(travel_providers.travelChangesProvider.notifier).state = false;
      ref.read(travel_providers.changeManagerProvider).clearChanges();
    }

    Navigator.pop(context);
    // 화면 종료
    return true;
  }

  /// 업데이트 일정 함수
  void _settingTravel() {
    TravelDialogManager.showSettingTravelDialog(context, ref).then(
      (index) async {
        if (index == 0) {
          dev.log('여행 일정 편집');
          ref.read(routerProvider).push(
                DateScreen.routePath,
              );
        } else if (index == 1) {
          dev.log('여행 일정 공유');
          final travelInfo = ref.watch(travel_providers.currentTravelProvider);
          if (travelInfo == null) return;

          try {
            final travelDbModel = TravelDBModel.fromTravelModel(travelInfo);
            final schedules = travelDbModel.schedules;
            await _exportPdf();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF로 내보내기 완료')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PDF 내보내기 실패: $e')),
              );
            }
          }
        } else if (index == 2) {
          dev.log('여행 삭제');
          final travel = ref.watch(travel_providers.currentTravelProvider);
          if (travel != null) {
            if (!mounted) return;
            ref
                .read(travel_providers.travelsProvider.notifier)
                .removeTravel(travel.id);
            Navigator.of(context).pop();
          }
        }
      },
    );
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

    ref.read(routerProvider).push(
      ScheduleInputScreen.routePath,
      extra: {
        'initialTime': TimeOfDay.now(),
        'initialLocation': '',
        'initialMemo': '',
        'initialLatitude': 0.0,
        'initialLongitude': 0.0,
        'date': dayData.date,
        'dayNumber': dayNumber,
      },
    );
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

    ref.read(routerProvider).push(
      ScheduleInputScreen.routePath,
      extra: {
        'initialTime': schedule.time,
        'initialLocation': schedule.location,
        'initialMemo': schedule.memo,
        'initialLatitude': schedule.latitude ?? 0.0,
        'initialLongitude': schedule.longitude ?? 0.0,
        'date': dayData.date,
        'dayNumber': dayNumber,
        'scheduleId': schedule.id,
      },
    );
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

  void _exportToPdf() async {
    try {
      await _exportPdf();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.pdfExportSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.pdfExportFailed(e.toString()))),
        );
      }
    }
  }

  void _updateCountryInfo(String countryCode) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.countryInfoUpdating)),
      );
    }

    try {
      final countryName = await _updateCountry(countryCode);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .countryInfoUpdated(countryName))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .countryInfoUpdateFailed(e.toString()))),
        );
      }
    }
  }

  void _showDeleteScheduleDialog(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteScheduleTitle),
        content: Text(AppLocalizations.of(context)!.deleteScheduleConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              _deleteSchedule(schedule);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _onScheduleMoved(DateTime newDate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context)!
              .scheduleMoved(newDate.month, newDate.day))),
    );
  }

  Future<void> _exportPdf() async {
    final travelInfo = ref.watch(travel_providers.currentTravelProvider);
    if (travelInfo == null) return;

    final travelDbModel = TravelDBModel.fromTravelModel(travelInfo);
    final schedules = travelDbModel.schedules;
    final pdfFile = await PdfExportService.exportTravelDetailToPdf(
      travel: travelDbModel,
      schedules: schedules,
    );
    await PdfExportService.sharePdf(pdfFile);
  }

  Future<String> _updateCountry(String countryCode) async {
    final travel = ref.watch(travel_providers.currentTravelProvider);
    if (travel == null) throw Exception('Travel not found');

    final countryInfo = travel.countryInfos.firstWhere(
      (info) => info.countryCode == countryCode,
      orElse: () => throw Exception('Country not found'),
    );

    return countryInfo.name;
  }
}
