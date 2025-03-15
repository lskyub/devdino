import 'package:country_icons/country_icons.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:travelee/models/country_info.dart';
import 'package:travelee/models/travel_model.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/screen/input/schedule_detail_screen.dart';
import 'package:travelee/utils/date_util.dart';
import 'dart:developer' as dev;

class TravelDetailScreen extends ConsumerStatefulWidget {
  static String routePath = '/travel/detail/:id';

  final String travelId;

  const TravelDetailScreen({super.key, required this.travelId});

  @override
  ConsumerState<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends ConsumerState<TravelDetailScreen>
    with WidgetsBindingObserver {
  late PageController _pageController;
  int _selectedIndex = 0;
  // 강제 리프레시를 위한 키
  final GlobalKey _refreshKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);

    // 여행 ID 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTravelData();

      // 화면 로딩 후 국가 정보 검증
      Future.delayed(const Duration(milliseconds: 500), () {
        _validateCountryInfo();
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 포커스를 얻었을 때 데이터 새로고침
      _refreshTravelData(forceUIUpdate: true);
    }
  }

  // 포커스 변경을 감지하기 위한 FocusNode
  final _focusNode = FocusNode();

  // 국가 정보 유효성 검증 및 필터링
  void _validateCountryInfo() {
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) return;

    // dayDataMap이 비어 있으면 검증 필요 없음
    if (currentTravel.dayDataMap.isEmpty) return;

    dev.log('국가 정보 유효성 검증 시작');

    // 국가 정보 유효성 확인
    bool needsUpdate = false;
    Map<String, DayData> updatedDayDataMap =
        Map<String, DayData>.from(currentTravel.dayDataMap);

    updatedDayDataMap.forEach((dateKey, dayData) {
      // null 체크 추가
      if (dayData == null) return;

      // 해당 국가가 목적지 목록에 없는 경우
      if (dayData.countryName.isNotEmpty &&
          !currentTravel.destination.contains(dayData.countryName)) {
        dev.log('삭제된 국가 발견: ${dateKey}의 ${dayData.countryName}');

        // 새 국가 정보 설정
        String newCountryName = currentTravel.destination.isNotEmpty
            ? currentTravel.destination.first
            : '';
        String newFlagEmoji = '🏳️';

        // 새 국가의 이모지 찾기
        if (newCountryName.isNotEmpty) {
          final countryInfo = currentTravel.countryInfos.firstWhere(
            (info) => info.name == newCountryName,
            orElse: () => CountryInfo(
                name: newCountryName, countryCode: '', flagEmoji: '🏳️'),
          );
          newFlagEmoji = countryInfo.flagEmoji;
        }

        // 해당 날짜의 DayData 업데이트
        updatedDayDataMap[dateKey] = dayData.copyWith(
          countryName: newCountryName,
          flagEmoji: newFlagEmoji,
        );

        needsUpdate = true;
      }
    });

    // 변경사항이 있는 경우에만 업데이트
    if (needsUpdate) {
      dev.log('삭제된 국가 정보 필터링 적용');
      final updatedTravel =
          currentTravel.copyWith(dayDataMap: updatedDayDataMap);

      ref.read(travelsProvider.notifier).updateTravel(updatedTravel);

      // UI 갱신
      Future.microtask(() {
        if (mounted) {
          setState(() {
            // 강제 UI 갱신
            dev.log('국가 정보 필터링 후 UI 갱신');
          });
        }
      });
    } else {
      dev.log('모든 국가 정보가 유효함');
    }
  }

  // 여행 데이터 초기 로드
  void _loadTravelData() {
    ref.read(currentTravelIdProvider.notifier).state = widget.travelId;
    dev.log('여행 ID 설정됨: ${widget.travelId}');
  }

  // 여행 데이터 새로고침
  void _refreshTravelData({bool forceUIUpdate = false}) {
    final currentId = ref.read(currentTravelIdProvider);
    if (currentId.isNotEmpty) {
      // 여행 데이터 강제 새로고침
      dev.log('여행 데이터 새로고침: $currentId');
      ref.read(currentTravelIdProvider.notifier).state = "";
      ref.read(currentTravelIdProvider.notifier).state = currentId;

      // 국가 정보 유효성 검증
      Future.delayed(const Duration(milliseconds: 300), () {
        _validateCountryInfo();
      });

      if (forceUIUpdate) {
        // 강제로 UI 갱신
        setState(() {
          // 키를 이용한 강제 리빌드 트리거
        });
      }
    }
  }

  @override
  void didUpdateWidget(TravelDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.travelId != widget.travelId) {
      _loadTravelData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _navigateToSchedule(DateTime date, int dayNumber) async {
    // 일정 화면으로 직접 네비게이션 (go_router 대신 Navigator 사용)
    dev.log('일정 화면으로 이동: Day $dayNumber, 날짜: ${date.toString()}');

    // Navigator를 사용하여 ScheduleDetailScreen으로 이동
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ScheduleDetailScreen(
          date: date,
          dayNumber: dayNumber,
        ),
      ),
    );

    // 결과가 있으면 (변경사항이 있으면) 강제 새로고침
    if (result == true) {
      dev.log('일정 화면에서 변경사항 있음 - 데이터 새로고침');
      _refreshTravelData(forceUIUpdate: true);

      // 추가적인 강제 새로고침 - 국가 정보가 업데이트 되지 않을 경우를 대비
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            // 강제 UI 갱신
            dev.log('추가 UI 갱신 실행');
          });
        }
      });
    } else {
      dev.log('일정 화면에서 변경사항 없음 또는 취소됨');
    }
  }

  @override
  Widget build(BuildContext context) {
    // FocusScope와 FocusNode를 사용하여 화면 포커스 변경 감지
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          // 화면이 다시 포커스를 얻으면 데이터 새로고침
          _refreshTravelData(forceUIUpdate: true);
        }
      },
      child: Builder(
          key: _refreshKey,
          builder: (context) {
            final travel = ref.watch(currentTravelProvider);

            if (travel == null) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('여행 상세'),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            // 여행의 목적지 목록 감시 - 변경시 UI 갱신
            ref.listen(
                currentTravelProvider.select((travel) => travel?.destination),
                (previous, next) {
              if (previous != next) {
                dev.log('여행 목적지 변경 감지: 강제 UI 갱신');
                Future.microtask(() {
                  if (mounted) {
                    setState(() {
                      // UI 강제 갱신
                    });
                  }
                });
              }
            });

            // 여행의 모든 날짜 목록 (dayData)
            final daysList = travel.getAllDaysSorted();

            return Scaffold(
              appBar: AppBar(
                title: B2bText.bold(
                  type: B2bTextType.title3,
                  text: travel.title,
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _refreshTravelData(forceUIUpdate: true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // 여행 편집 기능 추가
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  // 여행 기간 표시
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        B2bText.medium(
                          type: B2bTextType.body2,
                          text:
                              '${DateUtil.formatDate(travel.startDate)} - ${DateUtil.formatDate(travel.endDate)}',
                        ),
                      ],
                    ),
                  ),

                  // 날짜 탭 목록
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: daysList.length,
                      itemBuilder: (context, index) {
                        // 각 날짜에 대한 DayData를 Provider에서 직접 가져오기
                        final day = daysList[index];
                        // 각 날짜에 대한 최신 DayData 가져오기 (캐시된 데이터가 아닌 최신 상태)
                        final dayData = ref.watch(dayDataProvider(day.date));

                        // dayData가 있으면 최신 데이터 사용, 없으면 기존 데이터 사용
                        final displayDay = dayData ?? day;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              color: _selectedIndex == index
                                  ? $b2bToken.color.primary.resolve(context)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedIndex == index
                                    ? $b2bToken.color.primary.resolve(context)
                                    : $b2bToken.color.gray300.resolve(context),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: $b2bToken.color.gray100
                                          .resolve(context),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: $b2bToken.color.gray100
                                            .resolve(context),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.zero,
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: displayDay.countryCode.isEmpty
                                              ? const Icon(Icons.flag, color: Colors.grey) // 국가 코드가 없는 경우 기본 아이콘 표시
                                              : CountryIcons.getSvgFlag(displayDay.countryCode),
                                          ),
                                        ),
                                        B2bText.medium(
                                          type: B2bTextType.body3,
                                          text: 'Day ${displayDay.dayNumber}',
                                          color: _selectedIndex == index
                                              ? Colors.white
                                              : $b2bToken.color.labelNomal
                                                  .resolve(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 일정 페이지 뷰
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: daysList.length,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final dayData = daysList[index];
                        // 각 날짜에 대한 최신 DayData 가져오기
                        final updatedDayData =
                            ref.watch(dayDataProvider(dayData.date)) ?? dayData;
                        final schedules = updatedDayData.schedules;

                        return Column(
                          children: [
                            // 날짜 및 국가 정보
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        B2bText.bold(
                                          type: B2bTextType.title3,
                                          text: DateUtil.formatDateWithDay(
                                              updatedDayData.date),
                                        ),
                                        if (updatedDayData
                                            .countryName.isNotEmpty)
                                          Row(
                                            children: [
                                              Text(updatedDayData.flagEmoji,
                                                  style: const TextStyle(
                                                      fontSize: 16)),
                                              const SizedBox(width: 4),
                                              B2bText.regular(
                                                type: B2bTextType.body2,
                                                text:
                                                    updatedDayData.countryName,
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _navigateToSchedule(
                                        updatedDayData.date,
                                        updatedDayData.dayNumber),
                                    icon: const Icon(Icons.edit_calendar,
                                        size: 18),
                                    label: const Text('일정 관리'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: $b2bToken.color.primary
                                          .resolve(context),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 일정 목록
                            Expanded(
                              child: schedules.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.event_note,
                                            size: 48,
                                            color: $b2bToken.color.gray300
                                                .resolve(context),
                                          ),
                                          const SizedBox(height: 8),
                                          B2bText.medium(
                                            type: B2bTextType.body2,
                                            text: '등록된 일정이 없습니다.',
                                            color: $b2bToken.color.gray400
                                                .resolve(context),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _navigateToSchedule(
                                                    updatedDayData.date,
                                                    updatedDayData.dayNumber),
                                            child: const Text('일정 추가하기'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: $b2bToken
                                                  .color.primary
                                                  .resolve(context),
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: schedules.length,
                                      padding: const EdgeInsets.all(16),
                                      itemBuilder: (context, index) {
                                        final schedule = schedules[index];

                                        return Card(
                                          elevation: 2,
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            onTap: () => _navigateToSchedule(
                                                updatedDayData.date,
                                                updatedDayData.dayNumber),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // 시간 표시
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: $b2bToken
                                                          .color.gray100
                                                          .resolve(context),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: B2bText.bold(
                                                      type: B2bTextType.body2,
                                                      text:
                                                          '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}',
                                                      color: $b2bToken
                                                          .color.primary
                                                          .resolve(context),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  // 일정 내용
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        B2bText.bold(
                                                          type:
                                                              B2bTextType.body1,
                                                          text:
                                                              schedule.location,
                                                        ),
                                                        if (schedule.memo
                                                            .isNotEmpty) ...[
                                                          const SizedBox(
                                                              height: 4),
                                                          B2bText.regular(
                                                            type: B2bTextType
                                                                .body3,
                                                            text: schedule.memo,
                                                            color: $b2bToken
                                                                .color.gray600
                                                                .resolve(
                                                                    context),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
