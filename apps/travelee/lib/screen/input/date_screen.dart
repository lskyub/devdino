import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/screen/travel_detail_screen.dart';
import 'package:travelee/models/travel_model.dart';
import 'package:travelee/screen/input/travel_detail_screen.dart' as input_screens;

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
    final travelInfo = ref.watch(currentTravelProvider);
    
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
        ref.read(travelsProvider.notifier).addTravel(newTravel);
        
        // 현재 여행 ID 설정
        ref.read(currentTravelIdProvider.notifier).state = tempId;
        
        // 임시 편집 모드 시작
        ref.read(travelsProvider.notifier).startTempEditing();
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
                  ref.read(travelsProvider.notifier).updateTravel(updatedTravel);
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
                  final isNewTravel = travelInfo.id.isEmpty || travelInfo.id.startsWith('temp_');
                  
                  if (isNewTravel) {
                    // 세부 일정 화면으로 Navigator를 사용해 직접 이동 (라우터 우회)
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => input_screens.TravelDetailScreen(key: UniqueKey())
                      )
                    );
                  } else {
                    // 기존 여행인 경우 정상 라우팅 사용
                    final travelId = travelInfo.id;
                    context.push('${TravelDetailScreen.routePath}/$travelId');
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
