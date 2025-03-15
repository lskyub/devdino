import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:travelee/models/schedule.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/screen/input/schedule_input_modal.dart';
import 'package:travelee/screen/input/country_select_modal.dart';
import 'dart:developer' as dev;

class ScheduleDetailScreen extends ConsumerStatefulWidget {
  static const routeName = 'schedule_detail';
  static const routePath = '/schedule/detail';

  final DateTime date;
  final int dayNumber;

  const ScheduleDetailScreen({
    super.key,
    required this.date,
    required this.dayNumber,
  });
  
  @override
  ConsumerState<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends ConsumerState<ScheduleDetailScreen> {
  List<Schedule> _localBackupSchedules = [];
  bool _hasChanges = false;
  late DateTime date;

  @override
  void initState() {
    super.initState();
    date = widget.date;
    
    _createBackup();
  }
  
  // 현재 여행의 일정 백업 생성
  void _createBackup() {
    dev.log('ScheduleDetailScreen - 데이터 백업 생성 시작');
    
    try {
      // 현재 여행 정보 가져오기
      final currentTravel = ref.read(currentTravelProvider);
      if (currentTravel == null) {
        dev.log('ScheduleDetailScreen - 백업 실패: 현재 여행 정보 없음');
        return;
      }
      
      // 현재 여행의 일정 중 이 날짜의 일정만 백업
      final schedules = ref.read(dateSchedulesProvider(date));
      
      // 깊은 복사로 백업
      _localBackupSchedules = schedules.map((schedule) {
        return Schedule(
          id: schedule.id,
          travelId: schedule.travelId,
          date: DateTime(schedule.date.year, schedule.date.month, schedule.date.day),
          time: TimeOfDay(hour: schedule.time.hour, minute: schedule.time.minute),
          location: schedule.location,
          memo: schedule.memo,
          dayNumber: schedule.dayNumber,
        );
      }).toList();
      
      dev.log('ScheduleDetailScreen - 데이터 백업 완료: ${_localBackupSchedules.length}개 (여행 ID: ${currentTravel.id})');
      
    } catch (e) {
      dev.log('ScheduleDetailScreen - 데이터 백업 중 오류 발생: $e');
    }
  }
  
  // 백업에서 복원
  void _restoreFromBackup() {
    dev.log('ScheduleDetailScreen - 백업 데이터로 복원 시작');
    
    // 현재 여행 정보 가져오기
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) {
      dev.log('ScheduleDetailScreen - 복원 실패: 현재 여행 정보 없음');
      return;
    }
    
    dev.log('일정 백업에서 복원 시작 (${_localBackupSchedules.length}개 일정)');
    
    try {
      // 선택한 날짜의 일정을 모두 삭제하고 백업에서 복원
      final travelNotifier = ref.read(travelsProvider.notifier);
      
      // 현재 날짜에 해당하는 일정 모두 삭제
      travelNotifier.removeAllSchedulesForDate(currentTravel.id, date);
      
      // 백업에서 복원
      for (final schedule in _localBackupSchedules) {
        travelNotifier.addSchedule(currentTravel.id, schedule);
      }
      
      dev.log('일정 복원 완료');
      setState(() {
        _hasChanges = false;
      });
      
    } catch (e) {
      dev.log('일정 복원 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일정을 복원하는 중 오류가 발생했습니다.')),
      );
    }
  }

  // 변경 사항 감지
  bool _detectChanges() {
    if (_localBackupSchedules.isEmpty) {
      dev.log('ScheduleDetailScreen - 백업이 아직 생성되지 않았습니다.');
      return false;
    }
    
    // 변경 사항 확인
    final hasChanges = ref.read(travelsProvider.notifier).hasChanges();
    dev.log('ScheduleDetailScreen - travelsProvider.hasChanges(): $hasChanges');
    
    // 현재 일정
    final currentDateSchedules = ref.read(dateSchedulesProvider(date));
    
    // 일정 개수 비교
    if (_localBackupSchedules.length != currentDateSchedules.length) {
      dev.log('ScheduleDetailScreen - 일정 개수가 변경되었습니다 (${_localBackupSchedules.length} -> ${currentDateSchedules.length})');
      return true;
    }
    
    return hasChanges;
  }

  // 나가기 전 변경 사항 저장 여부 확인 다이얼로그
  Future<bool?> _showExitConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // 바깥 영역 터치로 닫기 방지
      builder: (context) => AlertDialog(
        title: B2bText.bold(
          type: B2bTextType.title3,
          text: '변경 사항 저장',
        ),
        content: B2bText.regular(
          type: B2bTextType.body2,
          text: '변경된 내용이 있습니다.\n저장하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              dev.log('다이얼로그 - [저장 안 함] 선택');
              Navigator.pop(context, false);
            },
            child: B2bText.medium(
              type: B2bTextType.body2,
              text: '저장 안 함',
              color: Colors.red, // 경고 색상
            ),
          ),
          TextButton(
            onPressed: () {
              dev.log('다이얼로그 - [취소] 선택');
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
              dev.log('다이얼로그 - [저장] 선택');
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

  // _addSchedule 메소드 수정
  void _addSchedule() {
    // 현재 여행 정보 가져오기
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) {
      dev.log('일정 추가 실패: 현재 여행 정보 없음');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('여행 정보를 찾을 수 없습니다. 다시 시도해주세요.'))
      );
      return;
    }
    
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
          date: date,
          dayNumber: widget.dayNumber,
        ),
      ),
    ).then((_) {
      // 변경사항 발생 상태 업데이트
      setState(() {
        _hasChanges = true;
      });
    });
  }

  // _editSchedule 메소드 수정
  void _editSchedule(Schedule schedule) {
    // 현재 여행 정보 가져오기
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) {
      dev.log('일정 수정 실패: 현재 여행 정보 없음');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('여행 정보를 찾을 수 없습니다. 다시 시도해주세요.'))
      );
      return;
    }

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
          date: date,
          dayNumber: widget.dayNumber,
          scheduleId: schedule.id,
        ),
      ),
    ).then((_) {
      // 변경사항 발생 상태 업데이트
      setState(() {
        _hasChanges = true;
      });
    });
  }

  void _selectCountry() async {
    // 현재 날짜에 대한 국가 정보 가져오기
    final travel = ref.read(currentTravelProvider);
    if (travel == null) {
      dev.log('국가 선택 실패: 현재 여행 정보 없음');
      return;
    }
    
    dev.log('국가 선택 시작 - 현재 날짜: ${date.toString()}');
    
    final dayData = ref.read(dayDataProvider(date));
    final currentCountryName = dayData?.countryName ?? '';
    final currentFlag = dayData?.flagEmoji ?? '';
    
    dev.log('현재 선택된 국가: $currentCountryName, 플래그: $currentFlag');
    
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
      
      dev.log('선택된 국가: $countryName, 플래그: $flagEmoji');
      
      if (countryName.isNotEmpty) {
        try {
          dev.log('국가 정보 업데이트 시작: $countryName $flagEmoji');
          
          // 국가 정보 업데이트 전에 UI 갱신 중단
          setState(() {
            // UI 갱신이 진행 중임을 표시하는 로직을 추가할 수 있음
          });
          
          // 국가 정보 업데이트
          ref.read(travelsProvider.notifier).setCountryForDate(
            travel.id,
            date,
            countryName,
            flagEmoji,
          );
          
          // 즉시 변경사항 커밋 (저장)
          ref.read(travelsProvider.notifier).commitChanges();
          
          // 여행 데이터 직접 가져와서 확인
          final updatedTravel = ref.read(travelsProvider.notifier).getTravel(travel.id);
          final updatedDateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final updatedDayData = updatedTravel?.dayDataMap[updatedDateKey];
          
          dev.log('업데이트된 여행 데이터 확인: ${updatedDayData?.countryName ?? '없음'}, ${updatedDayData?.flagEmoji ?? '없음'}');
          
          // 변경된 정보가 즉시 반영되도록 강력한 새로고침 적용
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Provider 캐시 초기화 및 상태 갱신
            final currentId = travel.id;
            ref.invalidate(dayDataProvider(date)); // 특정 날짜의 Provider 캐시 무효화
            ref.read(currentTravelIdProvider.notifier).state = "";
            ref.read(currentTravelIdProvider.notifier).state = currentId;
            
            // 0.1초 후 다시 한번 확인 및 UI 갱신
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                final latestDayData = ref.read(dayDataProvider(date));
                dev.log('딜레이 후 데이터 확인: ${latestDayData?.countryName ?? '없음'}, ${latestDayData?.flagEmoji ?? '없음'}');
                
                setState(() {
                  _hasChanges = true;
                });
                
                // 성공 알림
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$countryName 국가로 설정되었습니다'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            });
          });
          
          dev.log('국가 정보 설정 완료: $countryName $flagEmoji (${date})');
        } catch (e) {
          dev.log('국가 정보 설정 중 오류 발생: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('국가 정보 변경 중 오류가 발생했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      dev.log('국가 선택 취소 또는 결과 없음');
    }
  }

  // 날짜 범위 생성 헬퍼 메서드
  List<DateTime> _getDateRange(DateTime start, DateTime end) {
    List<DateTime> dates = [];
    for (DateTime date = start;
        date.isBefore(end.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      dates.add(date);
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    // 현재 여행 정보 가져오기
    final currentTravel = ref.watch(currentTravelProvider);
    if (currentTravel == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: $b2bToken.color.gray400.resolve(context),
              ),
              const SizedBox(height: 16),
              B2bText.medium(
                type: B2bTextType.body2,
                text: '여행 정보를 찾을 수 없습니다',
                color: $b2bToken.color.gray400.resolve(context),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      );
    }
    
    // 현재 날짜의 DayData 가져오기 (새로고침 보장을 위해 watch 사용)
    // 캐시 문제를 해결하기 위해 명시적으로 invalidate 수행
    ref.invalidate(dayDataProvider(date));
    final dayData = ref.watch(dayDataProvider(date));
    
    // 현재 날짜의 DayData에 대한 로그 추가
    dev.log('빌드 시 dayData 확인: ${dayData?.countryName ?? '국가 없음'}, ${dayData?.flagEmoji ?? '국기 없음'}');
    
    // 국가 및 국기 정보
    String selectedCountryName = currentTravel.destination.isNotEmpty 
        ? currentTravel.destination.first 
        : '';
    String flagEmoji = currentTravel.countryInfos.isNotEmpty 
        ? currentTravel.countryInfos.first.flagEmoji 
        : "🏳️";
    
    // DayData가 있으면 해당 정보 사용
    if (dayData != null) {
      if (dayData.countryName.isNotEmpty) {
        selectedCountryName = dayData.countryName;
        flagEmoji = dayData.flagEmoji.isNotEmpty ? dayData.flagEmoji : flagEmoji;
        dev.log('dayData에서 국가 정보 사용: $selectedCountryName, $flagEmoji');
      } else {
        dev.log('dayData가 있지만 국가 정보가 비어있음 - 기본값 사용');
      }
    } else {
      dev.log('dayData가 null - 기본 국가 정보 사용');
    }
    
    dev.log('ScheduleDetailScreen - 최종 표시 국가: $selectedCountryName, 플래그: $flagEmoji');
    
    return WillPopScope(
      onWillPop: () async {
        // 변경 사항이 있으면 확인 대화상자 표시
        if (_hasChanges) {
          final shouldDiscardChanges = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('변경사항 저장'),
              content: const Text('변경사항을 저장하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () {
                    // 변경사항 취소 (백업에서 복원)
                    _restoreFromBackup();
                    Navigator.pop(context, true);
                  },
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('저장'),
                ),
              ],
            ),
          );
          return shouldDiscardChanges ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Row(
            children: [
              B2bText.bold(
                type: B2bTextType.title3,
                text: 'Day ${widget.dayNumber}',
                color: $b2bToken.color.labelNomal.resolve(context),
              ),
              const SizedBox(width: 8),
              // 국기 표시 - 커지고 더 눈에 띄게
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: $b2bToken.color.primary.resolve(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      flagEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    if (selectedCountryName.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      B2bText.medium(
                        type: B2bTextType.body3,
                        text: selectedCountryName,
                        color: $b2bToken.color.primary.resolve(context),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              dev.log('ScheduleDetailScreen - 뒤로가기 버튼 클릭');
              
              // 변경사항 저장
              ref.read(travelsProvider.notifier).commitChanges();
              
              // 현재 여행 ID 가져오기
              final travelId = ref.read(currentTravelIdProvider);
              
              // 뒤로 가기
              Navigator.pop(context, true); // 결과값 전달하여 부모 화면에서 새로고침 유도
              
              // 변경된 정보가 즉시 반영되도록 프로바이더 갱신
              // 작업이 비동기적으로 처리되도록 조금 딜레이를 줌
              Future.delayed(const Duration(milliseconds: 50), () {
                // 현재 여행 정보가 메인 화면에 반영되도록 ID 재설정
                if (travelId.isNotEmpty) {
                  dev.log('ScheduleDetailScreen - 부모 화면 갱신을 위한 상태 업데이트');
                  ref.read(currentTravelIdProvider.notifier).state = "";
                  ref.read(currentTravelIdProvider.notifier).state = travelId;
                }
              });
            },
            icon: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 27,
              height: 27,
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _selectCountry(),
              icon: Icon(
                Icons.flag,
                color: $b2bToken.color.primary.resolve(context),
              ),
              label: B2bText.regular(
                type: B2bTextType.body2,
                text: '국가 변경',
                color: $b2bToken.color.primary.resolve(context),
              ),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: $b2bToken.color.primary.resolve(context).withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Builder(
                builder: (context) {
                  // 현재 날짜의 일정 목록
                  final schedules = ref.watch(dateSchedulesProvider(date))
                    ..sort((a, b) {
                      final aMinutes = a.time.hour * 60 + a.time.minute;
                      final bMinutes = b.time.hour * 60 + b.time.minute;
                      return aMinutes.compareTo(bMinutes);
                    });
                    
                  if (schedules.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 48,
                            color: $b2bToken.color.gray400.resolve(context),
                          ),
                          const SizedBox(height: 16),
                          B2bText.medium(
                            type: B2bTextType.body2,
                            text: '아직 등록된 일정이 없습니다',
                            color: $b2bToken.color.gray400.resolve(context),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: schedules.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: $b2bToken.color.gray200.resolve(context),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _editSchedule(schedule),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: $b2bToken.color.gray100
                                                  .resolve(context),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: B2bText.medium(
                                              type: B2bTextType.body2,
                                              text:
                                                  '${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}',
                                              color: $b2bToken.color.labelNomal
                                                  .resolve(context),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () {
                                              // 삭제 확인 대화 상자
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('일정 삭제'),
                                                  content: const Text('이 일정을 삭제하시겠습니까?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('취소'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        
                                                        dev.log('일정 삭제 시작: ID=${schedule.id}');
                                                        
                                                        // 현재 여행 정보 확인
                                                        final currentTravel = ref.read(currentTravelProvider);
                                                        if (currentTravel == null) {
                                                          dev.log('일정 삭제 실패: 현재 여행 정보 없음');
                                                          return;
                                                        }
                                                        
                                                        // 삭제 전 일정 수 확인
                                                        final beforeCount = ref.read(dateSchedulesProvider(date)).length;
                                                        
                                                        // 일정 삭제
                                                        ref.read(travelsProvider.notifier).removeSchedule(
                                                          currentTravel.id,
                                                          schedule.id
                                                        );
                                                        
                                                        // 변경사항 즉시 저장
                                                        ref.read(travelsProvider.notifier).commitChanges();
                                                        
                                                        // 삭제 후 일정 수 확인
                                                        final afterCount = ref.read(dateSchedulesProvider(date)).length;
                                                        
                                                        dev.log('일정 삭제 결과: ${beforeCount - afterCount}개 삭제됨 (${beforeCount} -> ${afterCount})');
                                                        
                                                        // 화면 갱신
                                                        if (mounted) {
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: const Text('삭제'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: $b2bToken.color.pink700
                                                  .resolve(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (schedule.location.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        B2bText.medium(
                                          type: B2bTextType.body2,
                                          text: schedule.location,
                                          color: $b2bToken.color.labelNomal
                                              .resolve(context),
                                        ),
                                      ],
                                      if (schedule.memo.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        B2bText.regular(
                                          type: B2bTextType.body3,
                                          text: schedule.memo,
                                          color: $b2bToken.color.gray500
                                              .resolve(context),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SafeArea(
              minimum: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: B2bButton.medium(
                  title: '일정 추가',
                  type: B2bButtonType.primary,
                  onTap: _addSchedule,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
