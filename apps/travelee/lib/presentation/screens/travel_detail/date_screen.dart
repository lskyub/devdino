import 'package:design_systems/dino/components/buttons/button.dino.dart';
import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:travelee/data/controllers/travel_detail_controller.dart';
import 'package:travelee/providers/travel_state_provider.dart'
    as travel_providers;
import 'package:travelee/data/models/travel/travel_model.dart';
import 'package:travelee/core/utils/travel_date_formatter.dart';
import 'package:country_picker/country_picker.dart';
import 'package:travelee/data/models/location/country_info.dart';
import 'package:travelee/presentation/widgets/ad_banner_widget.dart';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:travelee/gen/app_localizations.dart';

final searchTextProvider = StateProvider<String>((ref) => '');

class DateScreen extends ConsumerStatefulWidget {
  static const routeName = 'date';
  static const routePath = '/date';

  const DateScreen({super.key});

  @override
  ConsumerState<DateScreen> createState() => _DateScreenState();
}

class _DateScreenState extends ConsumerState<DateScreen> {
  final DateRangePickerController _controller = DateRangePickerController();
  DateTime? _tempStartDate;
  DateTime? _tempEndDate;

  @override
  Widget build(BuildContext context) {
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
          title: AppLocalizations.of(context)!.newTravel,
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
              B2bText(
                type: DinoTextType.bodyM,
                text: AppLocalizations.of(context)!.creatingNewTravel,
              ),
            ],
          ),
        ),
      );
    }

    // 임시 상태가 없으면 travelInfo의 날짜로 초기화
    _tempStartDate ??= travelInfo.startDate;
    _tempEndDate ??= travelInfo.endDate;

    if (_tempStartDate != null && _tempEndDate != null) {
      _controller.selectedRange = PickerDateRange(
        _tempStartDate!,
        _tempEndDate!,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent, // 자동 색상 변
        title: Align(
          alignment: Alignment.centerLeft,
          child: DinoText.custom(
            fontSize: 17,
            text: travelInfo.id.startsWith('temp_')
                ? AppLocalizations.of(context)!.registerTravelInfo
                : AppLocalizations.of(context)!.editTravelInfo,
            color: $dinoToken.color.blingGray900,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
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
          icon: travelInfo.id.startsWith('temp_')
              ? SvgPicture.asset(
                  'assets/icons/topappbar_back.svg',
                  colorFilter: ColorFilter.mode(
                    $dinoToken.color.blingGray900.resolve(context),
                    BlendMode.srcIn,
                  ),
                )
              : SvgPicture.asset(
                  'assets/icons/appbar_close.svg',
                ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 8,
                      ),
                      child: GestureDetector(
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
                              bottomSheetHeight:
                                  MediaQuery.of(context).size.height * 0.7,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24.0),
                                topRight: Radius.circular(24.0),
                              ),
                              inputDecoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .searchCountryHint,
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: $dinoToken.color.blingGray400
                                        .resolve(context),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: SvgPicture.asset(
                                      'assets/icons/search.svg',
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    maxHeight: 48,
                                    maxWidth: 48,
                                  ),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12.0),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: $dinoToken.color.blingGray75
                                      .resolve(context)),
                            ),
                            onSelect: (Country country) {
                              // Country 객체 정보와 함께 저장
                              final countryName =
                                  country.nameLocalized ?? country.name;

                              // 이미 선택된 국가인지 확인
                              if (travelInfo.destination
                                  .contains(countryName)) {
                                // 이미 선택된 국가는 추가하지 않고 메시지 표시
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .countryAlreadySelected),
                                    duration: const Duration(seconds: 2),
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
                              final countryInfos = List<CountryInfo>.from(
                                  travelInfo.countryInfos);

                              destinations.add(countryInfo.name);
                              countryInfos.add(countryInfo);

                              final updatedTravel = travelInfo.copyWith(
                                destination: destinations,
                                countryInfos: countryInfos,
                              );

                              ref
                                  .read(
                                      travel_providers.travelsProvider.notifier)
                                  .updateTravel(updatedTravel);
                            },
                          );
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/nation.svg',
                              ),
                              const SizedBox(width: 8),
                              DinoText.custom(
                                fontSize: 22.78,
                                text:
                                    AppLocalizations.of(context)!.travelCountry,
                                color: $dinoToken.color.blingGray600,
                                fontWeight: FontWeight.w700,
                              ),
                              const Spacer(),
                              DinoButton.custom(
                                type: DinoButtonType.empty,
                                horizontalPadding: 0,
                                textColor: $dinoToken.color.brandBlingBlue700,
                                backgroundColor: $dinoToken.color.transparent,
                                pressedTextColor:
                                    $dinoToken.color.brandBlingBlue700,
                                radius: 28,
                                textSize: 12.64,
                                trailing: Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: SvgPicture.asset(
                                    'assets/icons/ar_right.svg',
                                    colorFilter: ColorFilter.mode(
                                      $dinoToken.color.brandBlingBlue700
                                          .resolve(context),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                title: AppLocalizations.of(context)!.addCountry,
                              ),
                            ]),
                      ),
                    ),
                    if (travelInfo.destination.isNotEmpty) ...[
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
                                  color:
                                      $dinoToken.color.white.resolve(context),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: $dinoToken.color.blingGray300
                                        .resolve(context),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: $dinoToken.color.black
                                          .resolve(context)
                                          .withAlpha((255 * 0.04).toInt()),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      countryInfo.flagEmoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    DinoText.custom(
                                      fontSize: 14.22,
                                      text: data,
                                      color: $dinoToken.color.blingGray900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        // 목적지와 국가 정보 제거
                                        final destinations = List<String>.from(
                                            travelInfo.destination);
                                        final countryInfos =
                                            List<CountryInfo>.from(
                                                travelInfo.countryInfos);

                                        final index =
                                            destinations.indexOf(data);
                                        if (index != -1) {
                                          destinations.removeAt(index);
                                          if (index < countryInfos.length) {
                                            countryInfos.removeAt(index);
                                          }
                                        }

                                        final updatedTravel =
                                            travelInfo.copyWith(
                                          destination: destinations,
                                          countryInfos: countryInfos,
                                        );

                                        ref
                                            .read(travel_providers
                                                .travelsProvider.notifier)
                                            .updateTravel(updatedTravel);
                                      },
                                      child: SvgPicture.asset(
                                        'assets/icons/chip_cancle.svg',
                                        colorFilter: ColorFilter.mode(
                                          $dinoToken.color.blingGray300
                                              .resolve(context),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    Divider(
                      color: $dinoToken.color.blingGray75.resolve(context),
                      thickness: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/date.svg',
                          ),
                          const SizedBox(width: 8),
                          DinoText.custom(
                            fontSize: 22.78,
                            text: AppLocalizations.of(context)!.travelPeriod,
                            color: $dinoToken.color.blingGray600,
                            fontWeight: FontWeight.w700,
                          ),
                          const Spacer(),
                          DinoText.custom(
                            fontSize: 12.64,
                            text: AppLocalizations.of(context)!
                                .selectTravelPeriod,
                            color: $dinoToken.color.blingGray400,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24, top: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              DateTime current =
                                  _controller.displayDate ?? DateTime.now();
                              setState(() {
                                _controller.displayDate =
                                    DateTime(current.year, current.month - 1);
                              });
                            },
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(top: 2),
                              alignment: Alignment.topLeft,
                              child: SvgPicture.asset(
                                width: 26,
                                height: 26,
                                'assets/icons/datepicket_left_act.svg',
                                colorFilter: ColorFilter.mode(
                                  $dinoToken.color.blingGray900
                                      .resolve(context),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DinoText.custom(
                            fontSize: 20.25,
                            text: DateFormat('yyyy.MM').format(
                              _controller.displayDate ?? DateTime.now(),
                            ),
                            color: $dinoToken.color.blingGray900,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              DateTime current =
                                  _controller.displayDate ?? DateTime.now();
                              setState(() {
                                _controller.displayDate =
                                    DateTime(current.year, current.month + 1);
                              });
                            },
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(top: 2),
                              alignment: Alignment.topLeft,
                              child: SvgPicture.asset(
                                width: 26,
                                height: 26,
                                'assets/icons/datepicket_right_act.svg',
                                colorFilter: ColorFilter.mode(
                                  $dinoToken.color.blingGray900
                                      .resolve(context),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: SfDateRangePicker(
                          controller: _controller,
                          cellBuilder: (context, cellDetails) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final PickerDateRange? selectedRange =
                                    _controller.selectedRange;
                                final DateTime? start =
                                    selectedRange?.startDate;
                                final DateTime? end = selectedRange?.endDate;
                                final date = cellDetails.date;

                                bool isStart = false;
                                bool isEnd = false;
                                bool isInRange = false;

                                if (start != null && end != null) {
                                  isStart = _isSameDate(date, start);
                                  isEnd = _isSameDate(date, end);
                                  isInRange =
                                      date.isAfter(start) && date.isBefore(end);
                                } else if (start != null) {
                                  isStart = _isSameDate(date, start);
                                }

                                Widget dayText = DinoText.custom(
                                  fontSize: 16,
                                  text: date.day.toString(),
                                  color: isStart || isEnd
                                      ? $dinoToken.color.white
                                      : date.weekday == DateTime.sunday
                                          ? $dinoToken.color.brandBlingRed800
                                          : $dinoToken.color.blingGray900,
                                  fontWeight: isStart || isEnd
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                );

                                if (isStart || isEnd) {
                                  var size = min(cellDetails.bounds.width,
                                      cellDetails.bounds.height);
                                  // 원형 배경 (보라색)
                                  return Stack(
                                    children: [
                                      if (start != null &&
                                          end != null &&
                                          start != end) ...[
                                        Align(
                                          alignment: isStart
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Container(
                                            width: size / 2,
                                            height: cellDetails.bounds.width,
                                            alignment: isStart
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE9DDFB), // 연보라색
                                              shape: BoxShape.rectangle,
                                            ),
                                          ),
                                        ),
                                      ],
                                      Center(
                                        child: Container(
                                          width: size,
                                          height: size,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF8e4ec6), // 보라색
                                            shape: BoxShape.circle,
                                          ),
                                          alignment: Alignment.center,
                                          child: dayText,
                                        ),
                                      ),
                                    ],
                                  );
                                } else if (isInRange) {
                                  // 사각형 배경 (연보라색)
                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: cellDetails.bounds.width,
                                        height: cellDetails.bounds.width,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE9DDFB), // 연보라색
                                          shape: BoxShape.rectangle,
                                        ),
                                      ),
                                      Center(child: dayText),
                                    ],
                                  );
                                } else {
                                  // 기본
                                  return Center(child: dayText);
                                }
                              },
                            );
                          },
                          backgroundColor: Colors.white,
                          minDate: DateTime(DateTime.now().year - 1),
                          maxDate: DateTime(DateTime.now().year + 5),
                          startRangeSelectionColor: Colors.transparent,
                          endRangeSelectionColor: Colors.transparent,
                          rangeSelectionColor: Colors.transparent,
                          selectionColor: Colors.transparent,
                          monthViewSettings:
                              const DateRangePickerMonthViewSettings(
                            enableSwipeSelection:
                                false, // 드래그(스와이프)로 범위 선택 비활성화
                          ),
                          onSelectionChanged:
                              (DateRangePickerSelectionChangedArgs args) {
                            if (args.value is PickerDateRange) {
                              setState(() {
                                _tempStartDate = args.value.startDate;
                                _tempEndDate =
                                    args.value.endDate ?? args.value.startDate;
                              });
                            }
                          },
                          selectionMode: DateRangePickerSelectionMode.range,
                          view: DateRangePickerView.month,
                          navigationDirection:
                              DateRangePickerNavigationDirection.horizontal,
                          headerHeight: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DinoButton.custom(
                type: DinoButtonType.solid,
                size: DinoButtonSize.full,
                title: travelInfo.id.startsWith('temp_')
                    ? AppLocalizations.of(context)!.registerTravelInfoButton
                    : AppLocalizations.of(context)!.editTravelInfoButton,
                state: _tempStartDate == null ||
                        _tempEndDate == null ||
                        travelInfo.countryInfos.isEmpty
                    ? DinoButtonState.disabled
                    : DinoButtonState.base,
                backgroundColor: $dinoToken.color.brandBlingPurple600,
                disabledBackgroundColor: $dinoToken.color.blingGray300,
                textColor: $dinoToken.color.white,
                disabledTextColor: $dinoToken.color.white,
                onTap: () {
                  if (!travelInfo.id.startsWith('temp_')) {
                    final updatedTravel = travelInfo.copyWith(
                      startDate: _tempStartDate,
                      endDate: _tempEndDate,
                    );
                    ref
                        .read(travel_providers.travelsProvider.notifier)
                        .updateTravel(updatedTravel);
                    Navigator.pop(context);
                  } else {
                    if (_tempStartDate == null ||
                        _tempEndDate == null ||
                        travelInfo.countryInfos.isEmpty) {
                      return;
                    }

                    // 선택한 날짜 범위에 대해 dayDataMap 초기화
                    final start = _tempStartDate!;
                    final end = _tempEndDate!;

                    // 날짜 범위 내의 모든 날짜 생성
                    final dayDifference = end.difference(start).inDays;
                    Map<String, DayData> initialDayDataMap = {};

                    // 기본 국가 정보 (첫 번째 국가 사용)
                    String defaultCountryName = '';
                    String defaultFlagEmoji = '🏳️';
                    String defaultCountryCode = '';

                    if (travelInfo.countryInfos.isNotEmpty) {
                      defaultCountryName = travelInfo.countryInfos.first.name;
                      defaultFlagEmoji =
                          travelInfo.countryInfos.first.flagEmoji;
                      defaultCountryCode =
                          travelInfo.countryInfos.first.countryCode;
                    } else if (travelInfo.destination.isNotEmpty) {
                      defaultCountryName = travelInfo.destination.first;
                    }

                    // 각 날짜에 대한 DayData 생성
                    for (int i = 0; i <= dayDifference; i++) {
                      final currentDate = start.add(Duration(days: i));
                      final dateKey =
                          TravelDateFormatter.formatDate(currentDate);

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
                      startDate: _tempStartDate,
                      endDate: _tempEndDate,
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
                          .read(
                              travel_providers.currentTravelIdProvider.notifier)
                          .state = newId;

                      // 백업 다시 생성
                      controller.createBackup();

                      // 변경 플래그 초기화
                      controller.hasChanges = false;

                      // 여행 상세 화면으로 이동 (replace 사용)
                      context.replace('/travel_detail/$newId');
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
