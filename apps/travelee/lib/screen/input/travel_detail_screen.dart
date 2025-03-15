import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/screen/saved_travels_screen.dart';
import 'package:travelee/components/travel_day_card.dart';
import 'package:travelee/components/travel_info_summary.dart';
import 'package:travelee/utils/travel_date_formatter.dart';
import 'package:travelee/utils/travel_dialog_manager.dart';
import 'package:travelee/utils/travel_drag_drop_manager.dart';
import 'package:travelee/models/schedule.dart';
import 'package:travelee/models/day_schedule_data.dart';
import 'package:travelee/models/travel_model.dart';
import 'dart:math' as Math;
import 'dart:developer' as dev;

/**
 * TravelDetailScreen
 * 
 * 여행 세부 일정 화면
 * - 여행 기본 정보 표시
 * - 날짜별 일정 카드 목록 표시
 * - 드래그 앤 드롭으로 일정 날짜 이동 기능
 * - 여행 정보 편집 및 저장 기능
 */
class TravelDetailScreen extends ConsumerStatefulWidget {
  static const routeName = 'travel_detail';
  static const routePath = '/travel_detail';

  const TravelDetailScreen({super.key});

  @override
  ConsumerState<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends ConsumerState<TravelDetailScreen>
    with WidgetsBindingObserver {
  // 백업 저장을 위한 변수들
  List<Schedule> _originalScheduleBackup = [];
  List<DayScheduleData> _originalDayScheduleBackup = [];
  dynamic _originalTravelInfoBackup;
  bool _hasChanges = false;
  bool _backupCreated = false;
  late PageController _pageController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);

    // 페이지 로드 완료 후 백업 생성
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createBackup();

      // 목적지 변경 감지 리스너 설정 - 제거 (build 메서드에서만 사용 가능)
      // _setupDestinationChangeListener();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱 생명주기 변경 시 처리 (필요한 경우 구현)
  }

  // 목적지 변경 감지 리스너 설정 - 제거 (build 메서드에서만 사용해야 함)
  // void _setupDestinationChangeListener() {
  //   ref.listen(
  //     currentTravelProvider.select((travel) => travel?.destination),
  //     (previous, next) {
  //       if (previous != next && mounted) {
  //         dev.log('TravelDetailScreen - 목적지 변경 감지: 강제 UI 갱신');
  //         setState(() {
  //           // UI 강제 갱신
  //         });
  //       }
  //     }
  //   );
  // }

  // 화면 시작 시 데이터 백업 생성
  void _createBackup() {
    print('TravelDetailScreen - 데이터 백업 생성 시작');

    try {
      // 스케줄 데이터 백업 전에 명시적 임시 편집 모드 종료 (초기화 전)
      ref.read(travelsProvider.notifier).commitChanges();

      // 1. 여행 정보 백업
      final travelInfo = ref.read(currentTravelProvider);
      if (travelInfo == null) return;

      print(
          'TravelDetailScreen - 백업할 여행 정보: ID=${travelInfo.id}, 일정=${travelInfo.schedules.length}개');
      _originalTravelInfoBackup = travelInfo; // 객체 참조 저장

      // 2. 스케줄 데이터 백업 (깊은 복사)
      final schedules = travelInfo.schedules;
      _originalScheduleBackup = schedules.map((schedule) {
        return Schedule(
          id: schedule.id,
          travelId: schedule.travelId,
          date: DateTime(
              schedule.date.year, schedule.date.month, schedule.date.day),
          time:
              TimeOfDay(hour: schedule.time.hour, minute: schedule.time.minute),
          location: schedule.location,
          memo: schedule.memo,
          dayNumber: schedule.dayNumber,
        );
      }).toList();

      // 3. 날짜별 데이터 백업 (깊은 복사)
      // 통합 Provider에서는 날짜별 DayData를 TravelModel에서 직접 가져옴
      final dayDataMap = travelInfo.dayDataMap;
      _originalDayScheduleBackup = dayDataMap.values.map((dayData) {
        return DayScheduleData(
          date:
              DateTime(dayData.date.year, dayData.date.month, dayData.date.day),
          countryName: dayData.countryName,
          flagEmoji: dayData.flagEmoji,
          dayNumber: dayData.dayNumber,
          countryCode: dayData.countryCode,
          schedules: dayData.schedules.map((schedule) {
            return Schedule(
              id: schedule.id,
              travelId: schedule.travelId,
              date: DateTime(
                  schedule.date.year, schedule.date.month, schedule.date.day),
              time: TimeOfDay(
                  hour: schedule.time.hour, minute: schedule.time.minute),
              location: schedule.location,
              memo: schedule.memo,
              dayNumber: schedule.dayNumber,
            );
          }).toList(),
        );
      }).toList();

      // 일부 백업 데이터 로깅
      for (int i = 0; i < Math.min(3, dayDataMap.length); i++) {
        final key = dayDataMap.keys.elementAt(i);
        final dayData = dayDataMap[key];
        print(
            'TravelDetailScreen - 백업 데이터[${i}]: 날짜=${key}, 국가=${dayData?.countryName}, 플래그=${dayData?.flagEmoji}');
      }

      // 백업 후에 임시 편집 모드 다시 시작
      ref.read(travelsProvider.notifier).startTempEditing();

      setState(() {
        _backupCreated = true;
        _hasChanges = false;
      });

      print('TravelDetailScreen - 데이터 백업 완료');
      print('  - 일정 데이터: ${_originalScheduleBackup.length}개');
      print('  - 날짜별 데이터: ${_originalDayScheduleBackup.length}개');
    } catch (e) {
      print('TravelDetailScreen - 데이터 백업 중 오류 발생: $e');
      print('TravelDetailScreen - 오류 스택: ${e is Error ? e.stackTrace : ""}');
    }
  }

  // 변경 사항 감지
  bool _detectChanges() {
    if (!_backupCreated) {
      print('TravelDetailScreen - 백업이 아직 생성되지 않았습니다.');
      return false;
    }

    // 강제 설정된 변경 사항 확인
    if (_hasChanges) {
      print('TravelDetailScreen - 변경 플래그가 설정되어 있습니다.');
      return true;
    }

    // Provider의 변경 사항 확인
    final providerHasChanges = ref.read(travelsProvider.notifier).hasChanges();
    print(
        'TravelDetailScreen - travelsProvider.hasChanges(): $providerHasChanges');

    // 현재 상태 확인
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) return false;

    final currentSchedules = currentTravel.schedules;

    // 일정 개수 비교
    if (_originalScheduleBackup.length != currentSchedules.length) {
      print(
          'TravelDetailScreen - 일정 개수가 변경되었습니다 (${_originalScheduleBackup.length} -> ${currentSchedules.length})');
      return true;
    }

    return providerHasChanges || _hasChanges;
  }

  // 수정 플래그 설정
  void _setModified() {
    print('TravelDetailScreen - 수정 플래그 설정');
    setState(() {
      _hasChanges = true;
    });
  }

  // 백업 데이터로 원래 상태 복원
  Future<void> _restoreFromBackup() async {
    print('TravelDetailScreen - 백업 데이터로 복원 시작');

    // 여행 정보 확인
    final travelInfo = ref.read(currentTravelProvider);
    if (travelInfo == null) return;

    // 임시 여행(신규 생성)인 경우 복원 무시
    if (travelInfo.id.isEmpty || travelInfo.id.startsWith('temp_')) {
      print('TravelDetailScreen - 신규 여행 생성 모드: 복원 로직 무시');
      return;
    }

    if (!_backupCreated) {
      print('TravelDetailScreen - 백업 데이터가 없습니다.');
      return;
    }

    // 백업 데이터 유효성 검사
    if (_originalScheduleBackup.isEmpty) {
      print('TravelDetailScreen - 경고: 백업 일정 데이터가 비어 있습니다. 안전한 복원이 불가능합니다.');
      print(
          'TravelDetailScreen - 현재 백업 데이터 크기: ${_originalScheduleBackup.length}');

      final currentTravel = ref.read(currentTravelProvider);
      if (currentTravel != null) {
        print(
            'TravelDetailScreen - 현재 스케줄 수: ${currentTravel.schedules.length}');
      }
    } else {
      print(
          'TravelDetailScreen - 백업 데이터 유효성 확인됨: ${_originalScheduleBackup.length}개 일정');

      // 백업 데이터 내용 확인을 위한 기본 정보 로깅
      for (int i = 0; i < Math.min(3, _originalScheduleBackup.length); i++) {
        final schedule = _originalScheduleBackup[i];
        print('  백업[${i}]: ID=${schedule.id}, 위치=${schedule.location}');
      }
    }

    try {
      // 1. 화면 상태 초기화
      setState(() {
        _hasChanges = false;
      });

      // 2. scheduleProvider를 직접 정확히 백업 상태로 복원 (Provider 내부 롤백 함수 대신 직접 상태 설정)
      final schedulesCopy = _originalScheduleBackup
          .map((schedule) => Schedule(
                id: schedule.id,
                travelId: schedule.travelId,
                date: DateTime(
                    schedule.date.year, schedule.date.month, schedule.date.day),
                time: TimeOfDay(
                    hour: schedule.time.hour, minute: schedule.time.minute),
                location: schedule.location,
                memo: schedule.memo,
                dayNumber: schedule.dayNumber,
              ))
          .toList();

      // 3. 날짜별 데이터 dayDataMap 복원 준비
      final dayDataMapCopy = <String, DayData>{};
      for (final dayScheduleData in _originalDayScheduleBackup) {
        final dateKey = TravelDateFormatter.formatDate(dayScheduleData.date);
        dayDataMapCopy[dateKey] = DayData(
          date: dayScheduleData.date,
          countryName: dayScheduleData.countryName,
          flagEmoji: dayScheduleData.flagEmoji,
          dayNumber: dayScheduleData.dayNumber,
          schedules: dayScheduleData.schedules
              .map((s) => Schedule(
                    id: s.id,
                    travelId: s.travelId,
                    date: DateTime(s.date.year, s.date.month, s.date.day),
                    time: TimeOfDay(hour: s.time.hour, minute: s.time.minute),
                    location: s.location,
                    memo: s.memo,
                    dayNumber: s.dayNumber,
                  ))
              .toList(),
        );
      }

      print(
          'TravelDetailScreen - dayDataMap 복원 준비 완료: ${dayDataMapCopy.length}개 날짜 데이터');

      // 기존 여행 정보 가져오기
      final currentTravel = ref.read(currentTravelProvider);
      if (currentTravel != null) {
        // 업데이트된 여행 정보로 변경 (스케줄과 dayDataMap 모두 복원)
        final updatedTravel = currentTravel.copyWith(
          schedules: schedulesCopy,
          dayDataMap: dayDataMapCopy,
        );

        print(
            'TravelDetailScreen - 복원된 여행 정보: ID=${updatedTravel.id}, 일정=${updatedTravel.schedules.length}개, 날짜 데이터=${updatedTravel.dayDataMap.length}개');

        ref.read(travelsProvider.notifier).updateTravel(updatedTravel);
        print('TravelDetailScreen - 원본 데이터 직접 강제 복원 성공');
      } else {
        print('TravelDetailScreen - 일정 복원 실패: 현재 여행 정보 없음');
      }

      // 3. 강제 리렌더링을 위해 모든 상태 갱신
      await Future.delayed(Duration(milliseconds: 200));

      if (!mounted) return;

      // 4. 강제로 현재 여행 ID 재설정하여 화면 갱신
      final currentId = ref.read(currentTravelIdProvider);
      ref.read(currentTravelIdProvider.notifier).state = '';
      await Future.delayed(Duration(milliseconds: 50));
      ref.read(currentTravelIdProvider.notifier).state = currentId;

      print('TravelDetailScreen - 복원 작업 완료');
      print(
          'TravelDetailScreen - 복원 후 일정 수: ${ref.read(currentTravelProvider)?.schedules.length ?? 0}개 (백업 원본: ${_originalScheduleBackup.length}개)');

      // 7. 강제로 화면 다시 그리기
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('TravelDetailScreen - 백업 복원 중 오류 발생: $e');
      print('TravelDetailScreen - 오류 스택: ${e is Error ? e.stackTrace : ""}');

      // 오류 복구 시도
      try {
        // 기본 롤백 시도
        ref.read(travelsProvider.notifier).rollbackChanges();
        print('TravelDetailScreen - 기본 롤백 메서드로 복구 시도');
      } catch (recoverError) {
        print('TravelDetailScreen - 복구 시도 중 추가 오류: $recoverError');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 여행 정보 가져오기
    final travelInfo = ref.watch(currentTravelProvider);

    // Provider 상태 변경 감지 및 수정 플래그 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_backupCreated && mounted) {
        final hasActualChanges = _detectChanges();
        if (hasActualChanges != _hasChanges) {
          print('TravelDetailScreen - 변경 사항 감지 상태 업데이트: $hasActualChanges');
          setState(() {
            _hasChanges = hasActualChanges;
          });
        }

        // 적극적으로 변경 여부 확인 및 저장
        if (travelInfo != null && _originalTravelInfoBackup != null) {
          // ID가 비어있지 않고 temp_로 시작하지 않는지 확인 (기존 여행)
          final isExistingTravel =
              travelInfo.id.isNotEmpty && !travelInfo.id.startsWith('temp_');

          // travelsProvider의 hasChanges가 true인데 _hasChanges가 false인 경우 강제로 true로 설정
          if (isExistingTravel &&
              ref.read(travelsProvider.notifier).hasChanges() &&
              !_hasChanges) {
            print('TravelDetailScreen - Provider에 변경 사항이 있어 강제로 변경 플래그 설정');
            setState(() {
              _hasChanges = true;
            });
          }
        }
      }
    });

    // 여행 정보가 null이면 로딩 표시
    if (travelInfo == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: $b2bToken.color.primary.resolve(context),
              ),
              const SizedBox(height: 16),
              B2bText.regular(
                type: B2bTextType.body2,
                text: '여행 정보 로딩 중...',
              ),
            ],
          ),
        ),
      );
    }

    // 날짜가 null인 경우 오류 방지
    if (travelInfo.startDate == null || travelInfo.endDate == null) {
      // 임시 날짜 설정 (현재 날짜로)
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      // 여행 정보 업데이트
      final updatedTravel = travelInfo.copyWith(
        startDate: today,
        endDate: tomorrow,
      );

      // 업데이트된 여행 정보 저장
      ref.read(travelsProvider.notifier).updateTravel(updatedTravel);

      // 빈 daySchedules 리스트 반환
      final daySchedules = <DayScheduleData>[];

      // 드래그 앤 드롭 관리자 인스턴스
      final dragDropManager = TravelDragDropManager(ref);

      final isNewTravel =
          travelInfo.id.isEmpty || travelInfo.id.startsWith('temp_');
      // 로딩 화면 표시
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            _buildTravelInfoSection(context, updatedTravel),
            Expanded(
              child: _buildLoadingIndicator(context),
            ),
            if (isNewTravel) _buildBottomActionButton(context, updatedTravel),
          ],
        ),
      );
    }

    final dates = TravelDateFormatter.getDateRange(
        travelInfo.startDate!, travelInfo.endDate!);

    // 날짜별 데이터는 travelInfo에서 직접 계산
    final daySchedules = <DayScheduleData>[];
    for (final date in dates) {
      // 해당 날짜의 일정만 필터링
      final schedulesForDay = travelInfo.schedules
          .where((s) =>
              s.date.year == date.year &&
              s.date.month == date.month &&
              s.date.day == date.day)
          .toList();

      // 해당 날짜가 며칠째인지 계산
      final dayNumber = _getDayNumber(travelInfo.startDate!, date);

      // DayScheduleData 객체 생성 후 추가
      final dayData = DayScheduleData(
        date: date,
        countryName: travelInfo.destination.isNotEmpty
            ? travelInfo.destination.first
            : '',
        flagEmoji: travelInfo.countryInfos.isNotEmpty
            ? travelInfo.countryInfos.first.flagEmoji
            : '',
        countryCode: travelInfo.countryInfos.isNotEmpty
            ? travelInfo.countryInfos.first.countryCode
            : '',
        dayNumber: dayNumber,
        schedules: schedulesForDay,
      );

      daySchedules.add(dayData);
    }

    // 드래그 앤 드롭 관리자 인스턴스
    final dragDropManager = TravelDragDropManager(ref);

    final isNewTravel =
        travelInfo.id.isEmpty || travelInfo.id.startsWith('temp_');

    return PopScope(
      canPop: false, // 기본적으로 자동 pop을 방지
      onPopInvoked: (didPop) async {
        if (didPop) return; // 이미 pop 되었다면 아무것도 하지 않음

        // 여행 정보 확인
        final travelInfo = ref.read(currentTravelProvider);
        if (travelInfo == null) return;

        final isNewTravel =
            travelInfo.id.isEmpty || travelInfo.id.startsWith('temp_');

        // 변경 사항이 있는지 확인
        final hasChanges = _detectChanges();
        print(
            'TravelDetailScreen - 뒤로가기 감지: hasChanges=$hasChanges, isNewTravel=$isNewTravel');

        if (hasChanges) {
          // 신규 생성 모드인 경우, 바로 나가기 (백업 복원 없이)
          if (isNewTravel) {
            print('TravelDetailScreen - 신규 여행 생성 취소: 저장 안함');
            if (!mounted) return;
            Navigator.of(context).pop();
            return;
          }

          // 변경 사항이 있으면 확인 다이얼로그 표시
          final shouldSave = await _showExitConfirmDialog(context);

          if (shouldSave == true) {
            // 변경 사항 저장
            print('TravelDetailScreen - 변경사항 저장 후 나가기');
            ref.read(travelsProvider.notifier).commitChanges();
            if (!mounted) return;
            Navigator.of(context).pop(); // 화면 나가기
          } else if (shouldSave == false) {
            // 변경 사항 취소 - 백업 데이터로 복원
            print('TravelDetailScreen - 변경사항 취소 후 나가기');
            await _restoreFromBackup();
            ref.read(travelsProvider.notifier).rollbackChanges();
            if (!mounted) return;
            Navigator.of(context).pop(); // 화면 나가기
          }
          // shouldSave가 null이면 (다이얼로그에서 취소 선택) 아무것도 하지 않음
        } else {
          // 변경 사항이 없으면 바로 이전 화면으로 이동
          print('TravelDetailScreen - 변경사항 없음, 바로 나가기');
          if (!mounted) return;
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            _buildTravelInfoSection(context, travelInfo),
            Expanded(
              child: daySchedules.isEmpty
                  ? _buildLoadingIndicator(context)
                  : _buildDaySchedulesList(
                      context, travelInfo, daySchedules, dragDropManager),
            ),
            if (isNewTravel) _buildBottomActionButton(context, travelInfo),
          ],
        ),
      ),
    );
  }

  void _initializeDaySchedules(dynamic travelInfo, List<DateTime> dates) {
    print('TravelDetailScreen - 날짜별 데이터 초기화 필요');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // dayDataMap 업데이트
      final updatedDayDataMap =
          Map<String, DayScheduleData>.from(travelInfo.dayDataMap);

      for (final date in dates) {
        final dateKey = TravelDateFormatter.formatDate(date);
        if (!updatedDayDataMap.containsKey(dateKey)) {
          updatedDayDataMap[dateKey] = DayScheduleData(
            date: date,
            countryName: travelInfo.destination.isNotEmpty
                ? travelInfo.destination.first
                : '',
            flagEmoji: travelInfo.countryInfos.isNotEmpty
                ? travelInfo.countryInfos.first.flagEmoji
                : '',
            countryCode: travelInfo.countryInfos.isNotEmpty
                ? travelInfo.countryInfos.first.countryCode
                : '',
            dayNumber: _getDayNumber(travelInfo.startDate!, date),
            schedules: [],
          );
        }
      }

      // 업데이트된 여행 정보로 변경
      final updatedTravel = travelInfo.copyWith(dayDataMap: updatedDayDataMap);
      ref.read(travelsProvider.notifier).updateTravel(updatedTravel);

      _setModified(); // 데이터 초기화 시 수정 플래그 설정
    });
  }

  void _verifyTravelIdMatch(
      dynamic travelInfo, List<DateTime> dates, List<dynamic> daySchedules) {
    final hasCorrectTravelId = daySchedules.any((ds) {
      final schedules = ds['schedules'] as List<dynamic>;
      return schedules.isEmpty ||
          (schedules.isNotEmpty && schedules.first.travelId == travelInfo.id);
    });

    if (!hasCorrectTravelId) {
      print('TravelDetailScreen - 날짜별 데이터 여행 ID 불일치, 초기화 필요');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // 현재 상태 갱신
        final currentId = ref.read(currentTravelIdProvider);
        ref.read(currentTravelIdProvider.notifier).state = '';
        ref.read(currentTravelIdProvider.notifier).state = currentId;

        _setModified(); // 데이터 초기화 시 수정 플래그 설정
      });
    } else {
      print('TravelDetailScreen - 날짜별 데이터 정상: ${daySchedules.length}개');
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
        title: B2bText.bold(
          type: B2bTextType.title3,
          text: '세부 일정',
          color: $b2bToken.color.labelNomal.resolve(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
        onPressed: () async {
          // 여행 정보 확인
          final travelInfo = ref.read(currentTravelProvider);
          if (travelInfo == null) {
            print('TravelDetailScreen - 여행 정보가 없습니다.');
            Navigator.of(context).pop();
            return;
          }

          final isNewTravel =
              travelInfo.id.isEmpty || travelInfo.id.startsWith('temp_');

          // 변경 사항이 있는지 확인
          final hasChanges = _detectChanges();
          print(
              'TravelDetailScreen - 앱바 뒤로가기 버튼 클릭: hasChanges=$hasChanges, isNewTravel=$isNewTravel');

          if (hasChanges) {
            // 신규 생성 모드인 경우, 바로 나가기 (백업 복원 없이)
            if (isNewTravel) {
              print('TravelDetailScreen - 신규 여행 생성 취소: 저장 안함 (앱바)');
              Navigator.pop(context);
              return;
            }

            // 변경 사항이 있으면 확인 다이얼로그 표시
            final shouldSave = await _showExitConfirmDialog(context);
            print('TravelDetailScreen - 다이얼로그 응답: shouldSave=$shouldSave');

            if (shouldSave == true) {
              // 변경 사항 저장
              print('TravelDetailScreen - 변경사항 저장 후 나가기 (앱바)');
              ref.read(travelsProvider.notifier).commitChanges();
              Navigator.pop(context);
            } else if (shouldSave == false) {
              // 변경 사항 취소 - 백업 데이터로 복원
              print('TravelDetailScreen - 변경사항 취소 후 나가기 (앱바)');
              await _restoreFromBackup();
              ref.read(currentTravelIdProvider.notifier).state = '';
              ref.read(currentTravelIdProvider.notifier).state =
                  ref.read(currentTravelIdProvider);
              Navigator.pop(context);
            }
            // shouldSave가 null이면 (다이얼로그에서 취소 선택) 아무것도 하지 않음
          } else {
            // 변경 사항이 없으면 바로 이전 화면으로 이동
            print('TravelDetailScreen - 변경사항 없음, 바로 나가기 (앱바)');
            Navigator.pop(context);
          }
          },
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 27,
            height: 27,
          ),
        ),
      actions: [
        IconButton(
          onPressed: () async {
            await TravelDialogManager.showEditTravelDialog(context, ref);
            _setModified(); // 여행 정보 편집 후 수정 플래그 설정
          },
          icon: Icon(
            Icons.edit,
            color: $b2bToken.color.primary.resolve(context),
          ),
        ),
      ],
    );
  }

  // 나가기 전 변경 사항 저장 여부 확인 다이얼로그
  Future<bool?> _showExitConfirmDialog(BuildContext context) {
    // 여행 정보 확인
    final travelInfo = ref.read(currentTravelProvider);
    if (travelInfo == null) return Future.value(null);

    final isNewTravel =
        travelInfo.id.isEmpty || travelInfo.id.startsWith('temp_');

    // 다이얼로그 제목과 내용 설정
    final title = isNewTravel ? '여행 저장' : '변경 사항 저장';
    final content = isNewTravel
        ? '작성 중인 여행 계획이 있습니다.\n저장하시겠습니까?'
        : '변경된 내용이 있습니다.\n저장하시겠습니까?';

    print('TravelDetailScreen - 변경 사항 저장 다이얼로그 표시: isNewTravel=$isNewTravel');
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // 바깥 영역 터치로 닫기 방지
      builder: (context) => AlertDialog(
        title: B2bText.bold(
          type: B2bTextType.title3,
          text: title,
        ),
        content: B2bText.regular(
          type: B2bTextType.body2,
          text: content,
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('다이얼로그 - [저장 안 함] 선택');
              Navigator.pop(context, false);
            },
            child: B2bText.medium(
              type: B2bTextType.body2,
              text: '저장 안 함',
              color: Colors.red, // 경고 색상으로 변경
            ),
          ),
          TextButton(
            onPressed: () {
              print('다이얼로그 - [취소] 선택');
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
              print('다이얼로그 - [저장] 선택');
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

  Widget _buildTravelInfoSection(BuildContext context, dynamic travelInfo) {
    return Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          TravelInfoSummary(
            destination: travelInfo.destination.join(', '),
            startDate: travelInfo.startDate,
            endDate: travelInfo.endDate,
            formatDate: TravelDateFormatter.formatDate,
                          ),
                        ],
                      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
                            color: $b2bToken.color.primary.resolve(context),
                          ),
    );
  }

  Widget _buildDaySchedulesList(
      BuildContext context,
      dynamic travelInfo,
      List<DayScheduleData> daySchedules,
      TravelDragDropManager dragDropManager) {
    return ListView.builder(
      itemCount: daySchedules.length,
              itemBuilder: (context, index) {
        final daySchedule = daySchedules[index];

        // 날짜 키 생성
        final dateKey = TravelDateFormatter.formatDate(daySchedule.date);

        // 새로운 방식: dayDataMap에서 직접 최신 데이터 가져오기
        DayData? latestDayData;
        if (travelInfo.dayDataMap.containsKey(dateKey)) {
          latestDayData = travelInfo.dayDataMap[dateKey];
          print(
              'TravelDetailScreen - _buildDaySchedulesList: 날짜 $dateKey의 최신 데이터 국가=${latestDayData?.countryName ?? "없음"}, 국기=${latestDayData?.flagEmoji ?? "없음"}');
        } else {
          print(
              'TravelDetailScreen - _buildDaySchedulesList: 날짜 $dateKey의 데이터 없음, 기본값 사용');
        }

        // 최신 국가 정보 업데이트
        final updatedDaySchedule = daySchedule.copyWith(
          countryName: latestDayData?.countryName ?? daySchedule.countryName,
          flagEmoji: latestDayData?.flagEmoji ?? daySchedule.flagEmoji,
        );

                return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TravelDayCard(
            daySchedule: updatedDaySchedule,
            formatDate: TravelDateFormatter.formatDate,
            onDeletePressed: () async {
              final shouldDelete =
                  await TravelDialogManager.showDeleteDateConfirmDialog(
                      context);
              if (shouldDelete == true) {
                try {
                  // 국가 정보 백업
                  String? deletedCountryName;
                  String? deletedFlagEmoji;

                  // 삭제할 날짜의 국가 정보 백업
                  if (travelInfo.dayDataMap.containsKey(dateKey)) {
                    final dayData = travelInfo.dayDataMap[dateKey];
                    if (dayData != null) {
                      deletedCountryName = dayData.countryName;
                      deletedFlagEmoji = dayData.flagEmoji;
                      print(
                          'TravelDetailScreen - 삭제 전 국가 정보 백업: $deletedCountryName $deletedFlagEmoji');
                    }
                  }

                  // 해당 날짜의 일정들 삭제
                  final currentTravel = ref.read(currentTravelProvider);
                  if (currentTravel != null) {
                    // 해당 날짜의 일정을 제외한 모든 일정 가져오기
                    final date = daySchedule.date;
                    final updatedSchedules = currentTravel.schedules
                        .where((schedule) =>
                            schedule.date.year != date.year ||
                            schedule.date.month != date.month ||
                            schedule.date.day != date.day)
                        .toList();

                    // 기존 dayDataMap 깊은 복사
                    final updatedDayDataMap =
                        Map<String, DayData>.from(currentTravel.dayDataMap);

                    // 해당 날짜의 DayData를 삭제하지 않고 빈 일정으로 유지 (국가 정보 보존)
                    if (deletedCountryName != null &&
                        deletedFlagEmoji != null) {
                      updatedDayDataMap[dateKey] = DayData(
                        date: date,
                        countryName: deletedCountryName,
                        flagEmoji: deletedFlagEmoji,
                        dayNumber: daySchedule.dayNumber,
                        schedules: [], // 빈 일정
                      );
                      print(
                          'TravelDetailScreen - 국가 정보 보존 완료: $dateKey - $deletedCountryName $deletedFlagEmoji');
                    }

                    // 업데이트된 여행 정보로 변경
                    final updatedTravel = currentTravel.copyWith(
                      schedules: updatedSchedules,
                      dayDataMap: updatedDayDataMap,
                    );

                    print(
                        'TravelDetailScreen - 업데이트된 여행 정보: 일정=${updatedSchedules.length}개, 날짜 데이터=${updatedDayDataMap.length}개');
                    ref
                        .read(travelsProvider.notifier)
                        .updateTravel(updatedTravel);
                  }

                  _setModified(); // 날짜 삭제 시 수정 플래그 설정
                } catch (e) {
                  print('TravelDetailScreen - 날짜 삭제 중 오류 발생: $e');
                }
              }
            },
            onAccept: (data) {
              final scheduleIds = data['scheduleIds'] as List<dynamic>;
              final sourceDate = data['date'] as DateTime;
              final sourceDayNumber = data['dayNumber'] as int;
              final sourceCountry = data['country'] as String;
              
              // 항상 countryCode 키를 우선 확인
              final String sourceCountryCode = data.containsKey('countryCode') 
                  ? (data['countryCode'] as String? ?? '') // null이면 빈 문자열로
                  : ''; // 키가 없으면 빈 문자열로
              
              // 로그 추가
              dev.log('드래그 데이터 수신: 국가=$sourceCountry, 코드=$sourceCountryCode');

              dragDropManager.handleDragAccept(
                travelId: travelInfo.id,
                sourceDate: sourceDate,
                targetDate: updatedDaySchedule.date,
                scheduleIds: scheduleIds.cast<String>(),
                sourceDayNumber: sourceDayNumber,
                sourceCountry: sourceCountry,
                sourceCountryFlag: sourceCountryCode, // countryCode 값 전달
              );

              _setModified(); // 드래그 앤 드롭 시 수정 플래그 설정
            },
                  ),
                );
              },
    );
  }

  Widget _buildBottomActionButton(BuildContext context, dynamic travelInfo) {
    // 신규 여행인지 확인 (id가 비어있거나 temp_ 로 시작하는 경우)
    // 실제 isNewTravel 판단 로직을 수정하여 ID가 존재하고 temp_로 시작하지 않는 경우에만 기존 여행으로 취급
    final isNewTravel =
        travelInfo.id.isEmpty || travelInfo.id.startsWith('temp_');

    // 디버깅용 더 상세한 로그
    print(
        'TravelDetailScreen - 버튼 로직: ID=${travelInfo.id}, isNewTravel=$isNewTravel');

    // 버튼 텍스트 설정
    final buttonText = isNewTravel ? '새 여행 저장하기' : '수정 완료';

    print(
        'TravelDetailScreen - 버튼 생성: isNewTravel=$isNewTravel, 버튼 텍스트=$buttonText');

    return SafeArea(
            minimum: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: B2bButton.medium(
          title: buttonText,
                type: B2bButtonType.primary,
                onTap: () {
            print('TravelDetailScreen - 수정/저장 버튼 클릭: isNewTravel=$isNewTravel');

            if (isNewTravel) {
              print(
                  'TravelDetailScreen - 새 여행 저장 시작: 목적지=${travelInfo.destination.join(", ")}, 기간=${travelInfo.startDate} ~ ${travelInfo.endDate}');

              // 임시 ID로 된 여행을 영구 저장하기
              final currentId = ref.read(currentTravelIdProvider);

              if (currentId.isNotEmpty && currentId.startsWith('temp_')) {
                // temp_ 접두사 제거하고 영구 저장
                final newId = ref
                    .read(travelsProvider.notifier)
                    .saveTempTravel(currentId);

                if (newId != null) {
                  print(
                      'TravelDetailScreen - 임시 여행 ID 변경됨: $currentId -> $newId');

                  // 현재 ID 업데이트
                  ref.read(currentTravelIdProvider.notifier).state = newId;

                  // 백업 다시 생성
                  _createBackup();

                  // 변경 플래그 초기화
                  setState(() {
                    _hasChanges = false;
                  });

                  // 저장된 여행 화면으로 이동
                  context.go(SavedTravelsScreen.routePath);
                  return;
                }
              }

              // 기존 방식으로도 처리 (ID가 비어있는 경우 등)
              ref.read(travelsProvider.notifier).commitChanges();
              context.go(SavedTravelsScreen.routePath);
            } else {
              print('TravelDetailScreen - 기존 여행 수정 완료: ID=${travelInfo.id}');

              // 변경 사항 저장
              ref.read(travelsProvider.notifier).commitChanges();

              // 새 백업 생성
              _createBackup();

              // 변경 사항 플래그 초기화
              setState(() {
                _hasChanges = false;
              });

              context.pop();
            }
          },
        ),
      ),
    );
  }

  // 날짜가 여행의 몇 번째 날인지 계산
  int _getDayNumber(DateTime startDate, DateTime date) {
    // 두 날짜간 차이 계산 (일 단위)
    final difference = DateTime(date.year, date.month, date.day)
        .difference(DateTime(startDate.year, startDate.month, startDate.day))
        .inDays;

    // Day 1부터 시작
    return difference + 1;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
