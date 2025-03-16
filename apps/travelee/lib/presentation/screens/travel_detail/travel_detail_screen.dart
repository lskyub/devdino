import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/models/day_schedule_data.dart';
import 'package:travelee/models/travel_model.dart';
import 'package:travelee/providers/unified_travel_provider.dart' as travel_providers;
import 'package:travelee/utils/travel_date_formatter.dart';
import 'package:travelee/presentation/widgets/travel_detail/travel_detail_app_bar.dart';
import 'package:travelee/presentation/widgets/travel_detail/travel_info_section.dart';
import 'package:travelee/presentation/widgets/travel_detail/travel_action_button.dart';
import 'package:travelee/presentation/widgets/travel_detail/day_schedules_list.dart';
import 'package:travelee/data/managers/change_manager.dart';
import 'package:travelee/utils/result_types.dart';
import 'package:travelee/presentation/screens/schedule/schedule_detail_screen.dart';
import 'package:travelee/data/controllers/unified_controller.dart';
import 'dart:developer' as dev;

/// 여행 세부 일정 화면
/// 
/// 여행의 세부 일정을 관리하는 화면으로, 다음 기능을 제공합니다:
/// - 여행 기본 정보 표시
/// - 날짜별 일정 카드 목록 표시
/// - 드래그 앤 드롭으로 일정 날짜 이동 기능
/// - 여행 정보 편집 및 저장 기능
class TravelDetailScreen extends ConsumerStatefulWidget {
  static const routeName = 'travel_detail';
  static const routePath = '/travel_detail/:id';

  const TravelDetailScreen({super.key});

  @override
  ConsumerState<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends ConsumerState<TravelDetailScreen> with WidgetsBindingObserver {
  late FocusNode _focusNode;

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
        ref.read(travel_providers.currentTravelIdProvider.notifier).state = travelId;
      }
      
      // 통합 컨트롤러를 사용하여 백업 생성
      final controller = ref.read(unifiedControllerProvider);
      controller.createBackup();
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아왔을 때 데이터 새로고침
      final travel = ref.read(travel_providers.currentTravelProvider);
      if (travel != null && travel.startDate != null) {
        _refreshAllData();
      }
    }
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
      return _buildLoadingScreen(context);
    }
    
    // 날짜가 null인 경우 임시 날짜 설정 (현재 날짜로)
    if (travelInfo.startDate == null || travelInfo.endDate == null) {
      return _buildScreenWithTemporaryDates(context, travelInfo);
    }
    
    final dates = TravelDateFormatter.getDateRange(travelInfo.startDate!, travelInfo.endDate!);
    final daySchedules = _buildDaySchedulesFromDates(travelInfo, dates);

    return PopScope(
      canPop: false, // 기본적으로 자동 pop을 방지
      onPopInvoked: (didPop) async {
        if (didPop) return; // 이미 pop 되었다면 아무것도 하지 않음
        await _handleBackNavigation(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: TravelDetailAppBar(
          onBackPressed: () => _handleBackNavigation(context),
          onRefresh: () => _refreshAllData(),
        ),
        body: Column(
          children: [
            TravelInfoSection(travelInfo: travelInfo),
            Expanded(
              child: daySchedules.isEmpty
                  ? _buildLoadingIndicator(context)
                  : DaySchedulesList(
                      travelInfo: travelInfo,
                      daySchedules: daySchedules,
                      onScheduleTap: _navigateToSchedule,
                    ),
            ),
            const TravelActionButton(),
          ],
        ),
      ),
    );
  }
  
  /// 날짜 목록에서 DayScheduleData 목록 생성
  List<DayScheduleData> _buildDaySchedulesFromDates(TravelModel travelInfo, List<DateTime> dates) {
    final controller = ref.read(unifiedControllerProvider);
    final daySchedules = <DayScheduleData>[];
    
    for (final date in dates) {
      // 해당 날짜의 일정만 필터링
      final schedulesForDay = travelInfo.schedules.where((s) => 
        s.date.year == date.year && 
        s.date.month == date.month && 
        s.date.day == date.day
      ).toList();
      
      // 해당 날짜가 며칠째인지 계산
      final dayNumber = controller.getDayNumber(travelInfo.startDate!, date);
      
      // 날짜 키 생성 (yyyy-MM-dd 형식)
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // 국가 및 국기 정보 (기본값)
      String countryName = travelInfo.destination.isNotEmpty ? travelInfo.destination.first : '';
      String flagEmoji = travelInfo.countryInfos.isNotEmpty ? travelInfo.countryInfos.first.flagEmoji : '';
      String countryCode = travelInfo.countryInfos.isNotEmpty ? travelInfo.countryInfos.first.countryCode : '';
      
      // dayDataMap에서 해당 날짜의 국가 정보가 있으면 사용
      if (travelInfo.dayDataMap.containsKey(dateKey)) {
        final savedDayData = travelInfo.dayDataMap[dateKey];
        if (savedDayData != null && savedDayData.countryName.isNotEmpty) {
          countryName = savedDayData.countryName;
          flagEmoji = savedDayData.flagEmoji.isNotEmpty ? savedDayData.flagEmoji : flagEmoji;
          countryCode = savedDayData.countryCode.isNotEmpty ? savedDayData.countryCode : countryCode;
          
          dev.log('날짜($dateKey)에 저장된 국가 정보 사용: $countryName, $flagEmoji, $countryCode');
        }
      }
      
      // DayScheduleData 객체 생성 후 추가
      final dayData = DayScheduleData(
        date: date,
        countryName: countryName,
        flagEmoji: flagEmoji,
        countryCode: countryCode,
        dayNumber: dayNumber,
        schedules: schedulesForDay,
      );
      
      daySchedules.add(dayData);
    }
    
    return daySchedules;
  }
  
  /// 임시 날짜로 화면 구성
  Widget _buildScreenWithTemporaryDates(BuildContext context, TravelModel travelInfo) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    
    // 여행 정보 업데이트
    final updatedTravel = travelInfo.copyWith(
      startDate: today,
      endDate: tomorrow,
    );
    
    // 업데이트된 여행 정보 저장
    ref.read(travel_providers.travelsProvider.notifier).updateTravel(updatedTravel);
    
    // 로딩 화면 표시
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TravelDetailAppBar(
        onBackPressed: () => _handleBackNavigation(context),
        onRefresh: () => _refreshAllData(),
      ),
      body: Column(
        children: [
          TravelInfoSection(travelInfo: updatedTravel),
          Expanded(
            child: _buildLoadingIndicator(context),
          ),
          const TravelActionButton(),
        ],
      ),
    );
  }
  
  /// 로딩 화면 구성
  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _buildLoadingIndicator(context),
      ),
    );
  }
  
  /// 로딩 인디케이터 위젯
  Widget _buildLoadingIndicator(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  /// 뒤로가기 처리
  Future<void> _handleBackNavigation(BuildContext context) async {
    final controller = ref.read(unifiedControllerProvider);
    final travelInfo = controller.currentTravel;
    
    if (travelInfo == null) {
      Navigator.of(context).pop();
      return;
    }
    
    // 변경 관리자를 통해 변경사항 감지
    final hasChanges = controller.detectChanges();
    final isNewTravel = controller.isNewTravel();
    
    dev.log('TravelDetailScreen - 뒤로가기 감지: hasChanges=$hasChanges, isNewTravel=$isNewTravel');
    
    if (hasChanges) {
      // 신규 생성 모드인 경우, 바로 나가기 (백업 복원 없이)
      if (isNewTravel) {
        dev.log('TravelDetailScreen - 신규 여행 생성 취소: 저장 안함');
        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }
      
      // 변경 사항이 있으면 확인 다이얼로그 표시
      final saveResult = await _showExitConfirmDialog(context, isNewTravel);
      
      if (saveResult == SaveResult.save) {
        // 변경 사항 저장
        dev.log('TravelDetailScreen - 변경사항 저장 후 나가기');
        ref.read(travel_providers.travelsProvider.notifier).commitChanges();
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
    } else {
      // 변경 사항이 없으면 바로 이전 화면으로 이동
      dev.log('TravelDetailScreen - 변경사항 없음, 바로 나가기');
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }
  
  /// 새로 생성 중인 여행인지 확인
  bool _isNewTravel(TravelModel travel) {
    // 예: 여행 ID가 일시적으로 생성된 것인지, 제목이 기본값인지, 일정이 없는지 등으로 판단
    return travel.schedules.isEmpty && travel.title.contains('새 여행');
  }

  /// 나가기 전 변경 사항 저장 여부 확인 다이얼로그
  Future<SaveResult> _showExitConfirmDialog(BuildContext context, bool isNewTravel) async {
    // 다이얼로그 제목과 내용 설정
    final title = isNewTravel ? '여행 저장' : '변경 사항 저장';
    final content = isNewTravel 
        ? '작성 중인 여행 계획이 있습니다.\n저장하시겠습니까?'
        : '변경된 내용이 있습니다.\n저장하시겠습니까?';
    
    dev.log('TravelDetailScreen - 변경 사항 저장 다이얼로그 표시: isNewTravel=$isNewTravel');
    final result = await showDialog<SaveResult>(
      context: context,
      barrierDismissible: false, // 바깥 영역 터치로 닫기 방지
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
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
          ElevatedButton(
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

  void _navigateToSchedule(DateTime date, int dayNumber) async {
    // 로그 추가
    dev.log('TravelDetailScreen - 일정 화면으로 이동: Day $dayNumber, 날짜: ${date.toString()}');
    
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ScheduleDetailScreen(
          date: date,
          dayNumber: dayNumber,
        ),
      ),
    );
    
    if (result == true) {
      dev.log('TravelDetailScreen - 일정 화면에서 변경사항 있음 - 데이터 새로고침');
      
      // 화면 전체 갱신을 위해 여행 ID를 재설정
      final currentId = ref.read(travel_providers.currentTravelIdProvider);
      if (currentId.isNotEmpty) {
        // Provider 캐시 초기화
        ref.invalidate(travel_providers.dayDataProvider(date));
        
        // 통합 컨트롤러를 통한 데이터 새로고침
        final controller = ref.read(unifiedControllerProvider);
        controller.refreshData(date);
        
        // UI 갱신
        if (mounted) {
          setState(() {
            dev.log('TravelDetailScreen - 날짜 데이터 새로고침 후 UI 갱신 ($currentId)');
          });
        }
      }
    } else {
      dev.log('TravelDetailScreen - 일정 화면에서 변경사항 없음 또는 취소됨');
    }
  }
  
  // 모든 데이터 새로고침
  void _refreshAllData() {
    final travel = ref.read(travel_providers.currentTravelProvider);
    if (travel == null || travel.startDate == null) return;
    
    // 현재 여행 ID 가져오기
    final currentId = ref.read(travel_providers.currentTravelIdProvider);
    if (currentId.isEmpty) return;
    
    try {
      // 통합 컨트롤러를 통한 데이터 새로고침
      final controller = ref.read(unifiedControllerProvider);
      
      // 시작일부터 종료일까지 모든 날짜 데이터 새로고침
      if (travel.startDate != null && travel.endDate != null) {
        final dates = TravelDateFormatter.getDateRange(travel.startDate!, travel.endDate!);
        for (final date in dates) {
          controller.refreshData(date);
        }
      }
      
      // UI 갱신
      if (mounted) {
        setState(() {
          dev.log('TravelDetailScreen - 모든 데이터 새로고침 완료');
        });
      }
    } catch (e) {
      dev.log('TravelDetailScreen - 데이터 새로고침 중 오류: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    super.dispose();
  }
} 