import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:travelee/providers/unified_travel_provider.dart' as travel_providers;
import 'package:travelee/models/travel_model.dart';
import 'package:travelee/utils/travel_date_formatter.dart';
import 'package:travelee/data/managers/change_manager.dart';
import 'package:travelee/presentation/screens/travel_detail/travel_detail_screen.dart';
import 'dart:developer' as dev;

class DateScreen extends ConsumerWidget {
  static const routeName = 'date';
  static const routePath = '/date';

  const DateScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year.toString().substring(2)}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 여행 정보 확인
    final travelInfo = ref.watch(travel_providers.currentTravelProvider);
    
    // 여행 정보가 null이면 새 여행 생성 시작
    if (travelInfo == null) {
      // 일정 시간 후에 새 여행 생성 (UI 렌더링 후 실행)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 새 임시 ID 생성
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        
        // 빈 여행 객체 생성
        final newTravel = TravelModel(
          id: tempId,
          title: '새 여행',
          destination: [],
          startDate: null,
          endDate: null,
          countryInfos: [],
          schedules: [],
          dayDataMap: {},
        );
        
        // 새 여행 추가
        ref.read(travel_providers.travelsProvider.notifier).addTravel(newTravel);
        
        // 현재 여행 ID 설정
        ref.read(travel_providers.currentTravelIdProvider.notifier).state = tempId;
        
        // 임시 편집 모드 시작
        ref.read(travel_providers.travelsProvider.notifier).startTempEditing();
        
        // 백업 생성
        ref.read(travel_providers.changeManagerProvider).createBackup(newTravel);
        ref.read(travel_providers.travelBackupProvider.notifier).state = newTravel;
      });
      
      // 로딩 표시
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
                text: '새 여행 생성 중...',
              ),
            ],
          ),
        ),
      );
    }

    final startDate = _formatDate(travelInfo.startDate);
    final endDate = _formatDate(travelInfo.endDate);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: B2bText.bold(
          type: B2bTextType.title3,
          text: '여행 기간',
          color: $b2bToken.color.labelNomal.resolve(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            width: 27,
            height: 27,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SfDateRangePicker(
              backgroundColor: Colors.white,
              minDate: DateTime(DateTime.now().year - 1),
              maxDate: DateTime(DateTime.now().year + 5),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  final updatedTravel = travelInfo.copyWith(
                    startDate: args.value.startDate,
                    endDate: args.value.endDate,
                  );
                  ref.read(travel_providers.travelsProvider.notifier).updateTravel(updatedTravel);
                }
              },
              selectionMode: DateRangePickerSelectionMode.range,
              view: DateRangePickerView.month,
              navigationDirection: DateRangePickerNavigationDirection.vertical,
              enableMultiView: true,
              viewSpacing: 0,
              monthViewSettings: const DateRangePickerMonthViewSettings(
                enableSwipeSelection: false,
                numberOfWeeksInView: 6,
              ),
              monthFormat: 'MMM',
              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle:
                    $b2bToken.textStyle.body4regular.resolve(context).merge(
                          TextStyle(
                            color: $b2bToken.color.gray500.resolve(context),
                          ),
                        ),
                todayTextStyle:
                    $b2bToken.textStyle.body4regular.resolve(context).merge(
                          TextStyle(
                            color: $b2bToken.color.gray500.resolve(context),
                          ),
                        ),
              ),
              startRangeSelectionColor:
                  $b2bToken.color.violet200.resolve(context),
              endRangeSelectionColor:
                  $b2bToken.color.violet200.resolve(context),
              rangeSelectionColor: $b2bToken.color.violet200.resolve(context),
              selectionTextStyle:
                  $b2bToken.textStyle.body4regular.resolve(context).merge(
                        TextStyle(
                          color: $b2bToken.color.primary.resolve(context),
                        ),
                      ),
              rangeTextStyle:
                  $b2bToken.textStyle.body4regular.resolve(context).merge(
                        TextStyle(
                          color: $b2bToken.color.primary.resolve(context),
                        ),
                      ),
              todayHighlightColor: $b2bToken.color.primary.resolve(context),
              selectionColor: $b2bToken.color.primary.resolve(context),
              allowViewNavigation: false,
              headerStyle: DateRangePickerHeaderStyle(
                textAlign: TextAlign.end,
                backgroundColor: Colors.white,
                textStyle:
                    $b2bToken.textStyle.body1medium.resolve(context).merge(
                          TextStyle(
                            color: $b2bToken.color.primary.resolve(context),
                          ),
                        ),
              ),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 85,
            ),
            child: SizedBox(
              width: double.infinity,
              child: B2bButton.medium(
                state: startDate != '-' && endDate != '-'
                    ? B2bButtonState.base
                    : B2bButtonState.disabled,
                title: (startDate != '-' && endDate != '-')
                    ? '$startDate ~ $endDate 여행 만들기'
                    : '일정 선택',
                type: B2bButtonType.primary,
                onTap: () {
                  if (travelInfo.startDate == null || travelInfo.endDate == null) {
                    return; // 날짜가 없으면 이동 불가
                  }
                  
                  // 편집 중인 여행인지 확인
                  final isNewTravel = travelInfo.id.startsWith('temp_');
                  
                  // 선택한 날짜 범위에 대해 dayDataMap 초기화
                  final start = travelInfo.startDate!;
                  final end = travelInfo.endDate!;
                  
                  // 날짜 범위 내의 모든 날짜 생성
                  final dayDifference = end.difference(start).inDays;
                  Map<String, DayData> initialDayDataMap = {};
                  
                  // 기본 국가 정보 (첫 번째 국가 사용)
                  String defaultCountryName = '';
                  String defaultFlagEmoji = '🏳️';
                  String defaultCountryCode = '';
                  
                  if (travelInfo.countryInfos.isNotEmpty) {
                    defaultCountryName = travelInfo.countryInfos.first.name;
                    defaultFlagEmoji = travelInfo.countryInfos.first.flagEmoji;
                    defaultCountryCode = travelInfo.countryInfos.first.countryCode;
                  } else if (travelInfo.destination.isNotEmpty) {
                    defaultCountryName = travelInfo.destination.first;
                  }
                  
                  // 각 날짜에 대한 DayData 생성
                  for (int i = 0; i <= dayDifference; i++) {
                    final currentDate = start.add(Duration(days: i));
                    final dateKey = TravelDateFormatter.formatDate(currentDate);
                    
                    // 비어있는 DayData 생성
                    initialDayDataMap[dateKey] = DayData(
                      date: currentDate,
                      dayNumber: i + 1,
                      countryName: defaultCountryName,
                      flagEmoji: defaultFlagEmoji,
                      countryCode: defaultCountryCode,
                      schedules: [],
                    );
                  }
                  
                  // 업데이트된 여행 정보 저장
                  final updatedTravel = travelInfo.copyWith(
                    dayDataMap: initialDayDataMap,
                  );
                  
                  // 여행 정보 업데이트
                  ref.read(travel_providers.travelsProvider.notifier).updateTravel(updatedTravel);
                  
                  // 변경사항 즉시 저장
                  ref.read(travel_providers.travelsProvider.notifier).commitChanges();
                  
                  // 백업 갱신
                  ref.read(travel_providers.changeManagerProvider).createBackup(updatedTravel);
                  ref.read(travel_providers.travelBackupProvider.notifier).state = updatedTravel;
                  
                  dev.log('DateScreen - 여행 상세 화면으로 이동: id=${travelInfo.id}, isNewTravel=$isNewTravel');
                  
                  if (isNewTravel) {
                    // 신규 생성 모드인 경우 이동 방식 변경
                    // 1. Provider 무효화하여 최신 데이터 표시 보장
                    ref.invalidate(travel_providers.currentTravelProvider);
                    
                    // 2. 신규 여행은 새로운 프레젠테이션 구조 사용
                    final travelId = travelInfo.id;
                    context.push('/travel_detail/$travelId');
                    
                    // 로그 출력
                    dev.log('DateScreen - 신규 여행 페이지로 이동: /travel_detail/$travelId');
                  } else {
                    // 기존 여행 수정인 경우
                    final travelId = travelInfo.id;
                    context.push('/travel_detail/$travelId');
                    dev.log('DateScreen - 기존 여행 페이지로 이동: /travel_detail/$travelId');
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
