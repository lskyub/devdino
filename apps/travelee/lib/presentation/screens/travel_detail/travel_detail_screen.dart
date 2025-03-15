import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/models/day_schedule_data.dart';
import 'package:travelee/models/travel_model.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/utils/travel_date_formatter.dart';
import 'package:travelee/data/controllers/travel_detail_controller.dart';
import 'package:travelee/presentation/widgets/travel_detail/travel_detail_app_bar.dart';
import 'package:travelee/presentation/widgets/travel_detail/travel_info_section.dart';
import 'package:travelee/presentation/widgets/travel_detail/travel_action_button.dart';
import 'package:travelee/presentation/widgets/travel_detail/day_schedules_list.dart';
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
      
      if (params.length > 2) {
        final travelId = params[2]; // travel_detail/:id에서 id 추출
        dev.log('TravelDetailScreen - 경로에서 여행 ID 추출: $travelId');
        ref.read(currentTravelIdProvider.notifier).state = travelId;
      }
      
      // 백업 생성
      ref.read(travelDetailControllerProvider).createBackup();
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱 생명주기 변경 시 처리 (필요한 경우 구현)
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 여행 정보 가져오기
    final travelInfo = ref.watch(currentTravelProvider);
    
    // 변경 사항 감지
    ref.listen(travelChangesProvider, (previous, hasChanges) {
      dev.log('TravelDetailScreen - 변경 감지: $previous -> $hasChanges');
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
    final controller = ref.read(travelDetailControllerProvider);
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
      
      // DayScheduleData 객체 생성 후 추가
      final dayData = DayScheduleData(
        date: date,
        countryName: travelInfo.destination.isNotEmpty ? travelInfo.destination.first : '',
        flagEmoji: travelInfo.countryInfos.isNotEmpty ? travelInfo.countryInfos.first.flagEmoji : '',
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
    ref.read(travelsProvider.notifier).updateTravel(updatedTravel);
    
    // 로딩 화면 표시
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TravelDetailAppBar(
        onBackPressed: () => _handleBackNavigation(context),
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
    final controller = ref.read(travelDetailControllerProvider);
    final travelInfo = controller.currentTravel;
    
    if (travelInfo == null) {
      Navigator.of(context).pop();
      return;
    }
    
    final isNewTravel = controller.isNewTravel();
    
    // 변경 사항이 있는지 확인
    final hasChanges = controller.detectChanges();
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
      final shouldSave = await _showExitConfirmDialog(context, isNewTravel);
      
      if (shouldSave == true) {
        // 변경 사항 저장
        dev.log('TravelDetailScreen - 변경사항 저장 후 나가기');
        ref.read(travelsProvider.notifier).commitChanges();
        if (!mounted) return;
        Navigator.of(context).pop(); // 화면 나가기
      } else if (shouldSave == false) {
        // 변경 사항 취소 - 백업 데이터로 복원
        dev.log('TravelDetailScreen - 변경사항 취소 후 나가기');
        await controller.restoreFromBackup();
        ref.read(travelsProvider.notifier).rollbackChanges();
        if (!mounted) return;
        Navigator.of(context).pop(); // 화면 나가기
      }
      // shouldSave가 null이면 (다이얼로그에서 취소 선택) 아무것도 하지 않음
    } else {
      // 변경 사항이 없으면 바로 이전 화면으로 이동
      dev.log('TravelDetailScreen - 변경사항 없음, 바로 나가기');
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  /// 나가기 전 변경 사항 저장 여부 확인 다이얼로그
  Future<bool?> _showExitConfirmDialog(BuildContext context, bool isNewTravel) {
    // 다이얼로그 제목과 내용 설정
    final title = isNewTravel ? '여행 저장' : '변경 사항 저장';
    final content = isNewTravel 
        ? '작성 중인 여행 계획이 있습니다.\n저장하시겠습니까?'
        : '변경된 내용이 있습니다.\n저장하시겠습니까?';
    
    dev.log('TravelDetailScreen - 변경 사항 저장 다이얼로그 표시: isNewTravel=$isNewTravel');
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // 바깥 영역 터치로 닫기 방지
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              dev.log('다이얼로그 - [저장 안 함] 선택');
              Navigator.pop(context, false);
            },
            child: const Text('저장 안 함', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              dev.log('다이얼로그 - [취소] 선택');
              Navigator.pop(context, null);
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              dev.log('다이얼로그 - [저장] 선택');
              Navigator.pop(context, true);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    super.dispose();
  }
} 