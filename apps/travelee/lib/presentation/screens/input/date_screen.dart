import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:travelee/data/controllers/travel_detail_controller.dart';
import 'package:travelee/presentation/providers/travel_state_provider.dart'
    as travel_providers;
import 'package:travelee/data/models/travel/travel_model.dart';
import 'package:travelee/core/utils/travel_date_formatter.dart';
import 'package:country_picker/country_picker.dart';
import 'package:travelee/data/models/location/country_info.dart';
import 'dart:developer' as dev;

final searchTextProvider = StateProvider<String>((ref) => '');

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
        ref
            .read(travel_providers.travelsProvider.notifier)
            .addTravel(newTravel);

        // 현재 여행 ID 설정
        ref.read(travel_providers.currentTravelIdProvider.notifier).state =
            tempId;

        // 임시 편집 모드 시작
        ref.read(travel_providers.travelsProvider.notifier).startTempEditing();

        // 백업 생성
        ref
            .read(travel_providers.changeManagerProvider)
            .createBackup(newTravel);
        ref.read(travel_providers.travelBackupProvider.notifier).state =
            newTravel;
      });

      // 로딩 표시
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: $dinoToken.color.primary.resolve(context),
              ),
              const SizedBox(height: 16),
              const DinoText(
                type: DinoTextType.bodyM,
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
        surfaceTintColor: Colors.transparent, // 자동 색상 변
        title: DinoText(
          type: DinoTextType.bodyXL,
          text: '여행 기간',
          color: $dinoToken.color.black.resolve(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            // 임시 여행 데이터 정리
            final allTravels = ref.read(travel_providers.travelsProvider);
            final tempTravels = allTravels
                .where((travel) => travel.id.startsWith('temp_'))
                .toList();

            if (tempTravels.isNotEmpty) {
              print('DateScreen - 임시 여행 데이터 삭제: ${tempTravels.length}개');
              for (final travel in tempTravels) {
                print('DateScreen - 임시 여행 삭제: ID=${travel.id}');
                ref
                    .read(travel_providers.travelsProvider.notifier)
                    .removeTravel(travel.id);
              }
            }
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
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 8,
            ),
            child: DinoText(
              type: DinoTextType.bodyM,
              text: '여행 목적지를 추가 하세요.',
              color: $dinoToken.color.black.resolve(context),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 8),
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: travelInfo.destination.length,
              itemBuilder: (context, index) {
                final data = travelInfo.destination[index];
                final countryInfo = travelInfo.countryInfos[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: $dinoToken.color.blingGray100.resolve(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          countryInfo.flagEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        DinoText(
                          type: DinoTextType.detailL,
                          text: data,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            // 목적지와 국가 정보 제거
                            final destinations =
                                List<String>.from(travelInfo.destination);
                            final countryInfos =
                                List<CountryInfo>.from(travelInfo.countryInfos);

                            final index = destinations.indexOf(data);
                            if (index != -1) {
                              destinations.removeAt(index);
                              if (index < countryInfos.length) {
                                countryInfos.removeAt(index);
                              }
                            }

                            final updatedTravel = travelInfo.copyWith(
                              destination: destinations,
                              countryInfos: countryInfos,
                            );

                            ref
                                .read(travel_providers.travelsProvider.notifier)
                                .updateTravel(updatedTravel);
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: $dinoToken.color.blingGray400.resolve(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
            child: B2bButton.medium(
              state: B2bButtonState.base,
              title: '목적지 추가하기',
              type: B2bButtonType.primary,
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: false,
                  countryListTheme: CountryListThemeData(
                    backgroundColor: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: $dinoToken.color.black.resolve(context),
                    ),
                    bottomSheetHeight: MediaQuery.of(context).size.height * 0.7,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    inputDecoration: InputDecoration(
                      labelText: '국가 검색',
                      hintText: '국가 이름을 입력하세요',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: $dinoToken.color.black.resolve(context),
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  onSelect: (Country country) {
                    // Country 객체 정보와 함께 저장
                    final countryName = country.nameLocalized ?? country.name;

                    // 이미 선택된 국가인지 확인
                    if (travelInfo.destination.contains(countryName)) {
                      // 이미 선택된 국가는 추가하지 않고 메시지 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('이미 선택된 국가입니다'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    final countryInfo = CountryInfo(
                      name: countryName,
                      countryCode: country.countryCode,
                      flagEmoji: country.flagEmoji,
                    );

                    // 목적지와 국가 정보 추가
                    final destinations =
                        List<String>.from(travelInfo.destination);
                    final countryInfos =
                        List<CountryInfo>.from(travelInfo.countryInfos);

                    destinations.add(countryInfo.name);
                    countryInfos.add(countryInfo);

                    final updatedTravel = travelInfo.copyWith(
                      destination: destinations,
                      countryInfos: countryInfos,
                    );

                    ref
                        .read(travel_providers.travelsProvider.notifier)
                        .updateTravel(updatedTravel);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
            ),
            child: DinoText(  
              type: DinoTextType.bodyM,
              text: '여행 기간을 선택하세요.',
              color: $dinoToken.color.black.resolve(context),
            ),
          ),
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(left: 8, right: 8),
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
                  ref
                      .read(travel_providers.travelsProvider.notifier)
                      .updateTravel(updatedTravel);
                }
              },
              selectionMode: DateRangePickerSelectionMode.range,
              view: DateRangePickerView.month,
              navigationDirection:
                  DateRangePickerNavigationDirection.horizontal,
              enableMultiView: false,
              viewSpacing: 0,
              monthViewSettings: const DateRangePickerMonthViewSettings(
                enableSwipeSelection: false,
                numberOfWeeksInView: 6,
              ),
              monthFormat: 'MMM',
              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle:
                    $dinoToken.typography.detailL.resolve(context).merge(
                          TextStyle(
                            color: $dinoToken.color.blingGray500.resolve(context),
                          ),
                        ),
                todayTextStyle:
                    $dinoToken.typography.detailL.resolve(context).merge(
                          TextStyle(
                            color: $dinoToken.color.blingGray500.resolve(context),
                          ),
                        ),
              ),
              startRangeSelectionColor:
                  $dinoToken.color.brandBlingViolet200.resolve(context),
              endRangeSelectionColor:
                  $dinoToken.color.brandBlingViolet200.resolve(context),
              rangeSelectionColor: $dinoToken.color.brandBlingViolet200.resolve(context),
              selectionTextStyle:
                  $dinoToken.typography.detailL.resolve(context).merge(
                        TextStyle(
                          color: $dinoToken.color.primary.resolve(context),
                        ),
                      ),
              rangeTextStyle:
                  $dinoToken.typography.detailL.resolve(context).merge(
                        TextStyle(
                          color: $dinoToken.color.primary.resolve(context),
                        ),
                      ),
              todayHighlightColor: $dinoToken.color.primary.resolve(context),
              selectionColor: $dinoToken.color.primary.resolve(context),
              allowViewNavigation: false,
              headerStyle: DateRangePickerHeaderStyle(
                textAlign: TextAlign.end,
                backgroundColor: Colors.white,
                textStyle:
                    $dinoToken.typography.bodyM.resolve(context).merge(
                          TextStyle(
                            color: $dinoToken.color.primary.resolve(context),
                          ),
                        ),
              ),
            ),
          )),
          SafeArea(
            minimum: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 50,
            ),
            child: SizedBox(
              width: double.infinity,
              child: B2bButton.medium(
                state: startDate != '-' &&
                        endDate != '-' &&
                        travelInfo.destination.isNotEmpty
                    ? B2bButtonState.base
                    : B2bButtonState.disabled,
                title: (startDate != '-' &&
                        endDate != '-' &&
                        travelInfo.destination.isNotEmpty)
                    ? '$startDate ~ $endDate 여행 만들기'
                    : '목적지와 기간을 선택하세요',
                type: B2bButtonType.primary,
                onTap: () {
                  if (travelInfo.startDate == null ||
                      travelInfo.endDate == null ||
                      travelInfo.destination.isEmpty) {
                    return;
                  }

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
                    defaultCountryCode =
                        travelInfo.countryInfos.first.countryCode;
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
                  ref
                      .read(travel_providers.travelsProvider.notifier)
                      .updateTravel(updatedTravel);

                  // 임시 ID로 된 여행을 영구 저장
                  final travelId = travelInfo.id;
                  final controller = ref.read(travelDetailControllerProvider);
                  final newId = controller.saveTempTravel(travelId);

                  if (newId != null) {
                    // 데이터베이스에 저장
                    dev.log('DateScreen - 임시 여행 ID 변경됨: $travelId -> $newId');

                    // 현재 ID 업데이트
                    ref
                        .read(travel_providers.currentTravelIdProvider.notifier)
                        .state = newId;

                    // 백업 다시 생성
                    controller.createBackup();

                    // 변경 플래그 초기화
                    controller.hasChanges = false;

                    // 여행 상세 화면으로 이동 (replace 사용)
                    context.replace('/travel_detail/$newId');
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
