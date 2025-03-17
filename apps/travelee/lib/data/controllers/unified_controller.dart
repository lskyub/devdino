import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelee/models/travel_model.dart';
import 'package:travelee/models/schedule.dart';
import 'package:travelee/data/managers/change_manager.dart';
import 'package:travelee/providers/unified_travel_provider.dart' as travel_providers;
import 'dart:developer' as dev;

/// 단일화된 데이터 관리를 위한 통합 컨트롤러
/// 
/// 여행 데이터의 변경, 저장, 복원 등을 담당하며 Provider와의 상호작용을 처리합니다.
/// ChangeManager와 통합되어 일관된 데이터 관리를 제공합니다.
class UnifiedController {
  final Ref _ref;
  bool hasChanges = false;
  
  UnifiedController(this._ref);
  
  /// 현재 여행 정보를 가져옵니다.
  TravelModel? get currentTravel => _ref.read(travel_providers.currentTravelProvider);
  
  /// 현재 여행 ID를 가져옵니다.
  String get currentTravelId => _ref.read(travel_providers.currentTravelIdProvider);
  
  /// 변경 관리자를 가져옵니다.
  ChangeManager get changeManager => _ref.read(travel_providers.changeManagerProvider);
  
  /// 백업을 생성합니다.
  void createBackup() {
    final travel = currentTravel;
    if (travel == null) {
      dev.log('UnifiedController - 백업 생성 실패: 현재 여행 정보 없음');
      return;
    }
    
    changeManager.createBackup(travel);
    _ref.read(travel_providers.travelBackupProvider.notifier).state = travel;
    dev.log('UnifiedController - 백업 생성 완료: ${travel.id}');
    
    // 변경 사항 없음으로 초기화
    hasChanges = false;
    _ref.read(travel_providers.travelChangesProvider.notifier).state = false;
  }
  
  /// 변경사항을 감지합니다.
  bool detectChanges() {
    final travel = currentTravel;
    if (travel == null) return false;
    
    final changes = changeManager.hasChanges(travel) || hasChanges;
    dev.log('UnifiedController - 변경사항 감지: $changes');
    return changes;
  }
  
  /// 백업에서 복원합니다.
  Future<void> restoreFromBackup() async {
    try {
      final restoredTravel = changeManager.restoreFromBackup();
      _ref.read(travel_providers.travelsProvider.notifier).updateTravel(restoredTravel);
      dev.log('UnifiedController - 백업에서 복원 완료: ${restoredTravel.id}');
      
      // 변경 사항 없음으로 초기화
      hasChanges = false;
      _ref.read(travel_providers.travelChangesProvider.notifier).state = false;
      
      // 백업 후 Provider 캐시 무효화
      _invalidateProviders(restoredTravel);
    } catch (e) {
      dev.log('UnifiedController - 백업에서 복원 실패: $e');
    }
  }
  
  /// 관련 Provider를 무효화합니다.
  void _invalidateProviders(TravelModel travel) {
    if (travel.startDate != null && travel.endDate != null) {
      final dates = travel.startDate!.isBefore(travel.endDate!)
          ? _getDateRange(travel.startDate!, travel.endDate!)
          : [travel.startDate!];
          
      for (final date in dates) {
        final standardDate = DateTime(date.year, date.month, date.day);
        _ref.invalidate(travel_providers.dayDataProvider(standardDate));
        _ref.invalidate(travel_providers.dateSchedulesProvider(standardDate));
      }
    }
    
    _ref.invalidate(travel_providers.currentTravelProvider);
    dev.log('UnifiedController - Provider 무효화 완료');
  }
  
  /// 날짜 범위를 생성합니다.
  List<DateTime> _getDateRange(DateTime start, DateTime end) {
    final List<DateTime> dates = [];
    for (DateTime date = start; 
         !date.isAfter(end); 
         date = date.add(const Duration(days: 1))) {
      dates.add(date);
    }
    return dates;
  }
  
  /// 모든 관련 Provider를 갱신합니다.
  void refreshData(DateTime date) {
    final standardDate = DateTime(date.year, date.month, date.day);
    final dateKey = '${standardDate.year}-${standardDate.month.toString().padLeft(2, '0')}-${standardDate.day.toString().padLeft(2, '0')}';
    
    dev.log('UnifiedController - Provider 무효화 시작: $dateKey');
    
    // 1. 날짜별 Provider 무효화 
    _ref.invalidate(travel_providers.dayDataProvider(standardDate));
    _ref.invalidate(travel_providers.dateSchedulesProvider(standardDate));
    
    // 2. 여행 Provider 무효화
    _ref.invalidate(travel_providers.currentTravelProvider);
    
    dev.log('UnifiedController - Provider 무효화 완료');
    
    // 3. 현재 여행 ID를 사용하여 강제 갱신 (필요한 경우만)
    if (detectChanges()) {
      dev.log('UnifiedController - 데이터 변경 감지, 변경사항 커밋');
      _ref.read(travel_providers.travelsProvider.notifier).commitChanges();
    }
  }
  
  /// 일정을 추가합니다.
  void addSchedule(Schedule schedule) {
    final travel = currentTravel;
    if (travel == null) return;
    
    _ref.read(travel_providers.travelsProvider.notifier).addSchedule(travel.id, schedule);
    hasChanges = true;
    dev.log('UnifiedController - 일정 추가 완료: ${schedule.id}');
  }
  
  /// 일정을 업데이트합니다.
  void updateSchedule(Schedule schedule) {
    final travel = currentTravel;
    if (travel == null) return;
    
    _ref.read(travel_providers.travelsProvider.notifier).updateSchedule(travel.id, schedule);
    hasChanges = true;
    dev.log('UnifiedController - 일정 업데이트 완료: ${schedule.id}');
  }
  
  /// 일정을 삭제합니다.
  void removeSchedule(String scheduleId) {
    final travel = currentTravel;
    if (travel == null) return;
    
    final scheduleToRemove = travel.schedules.firstWhere(
      (s) => s.id == scheduleId,
      orElse: () => throw Exception('일정을 찾을 수 없음: $scheduleId'),
    );
    
    _ref.read(travel_providers.travelsProvider.notifier).removeSchedule(travel.id, scheduleId);
    hasChanges = true;
    dev.log('UnifiedController - 일정 삭제 완료: $scheduleId, 위치: ${scheduleToRemove.location}');
  }
  
  /// 국가 정보를 업데이트합니다.
  void updateCountryInfo(DateTime date, String countryName, String flagEmoji, String countryCode) {
    final travel = currentTravel;
    if (travel == null) return;
    
    final standardDate = DateTime(date.year, date.month, date.day);
    final dateKey = '${standardDate.year}-${standardDate.month}-${standardDate.day}';
    
    // 기존 DayData 가져오기
    final existingDayData = travel.dayDataMap[dateKey];
    if (existingDayData == null) {
      dev.log('UnifiedController - 국가 정보 업데이트 실패: 날짜 데이터 없음 - $dateKey');
      return;
    }
    
    // 업데이트된 DayData 생성
    final updatedDayData = existingDayData.copyWith(
      countryName: countryName,
      flagEmoji: flagEmoji,
      countryCode: countryCode,
    );
    
    // DayDataMap 업데이트
    final updatedMap = Map<String, DayData>.from(travel.dayDataMap);
    updatedMap[dateKey] = updatedDayData;
    
    // 여행 정보 업데이트
    final updatedTravel = travel.copyWith(dayDataMap: updatedMap);
    _ref.read(travel_providers.travelsProvider.notifier).updateTravel(updatedTravel);
    
    hasChanges = true;
    dev.log('UnifiedController - 국가 정보 업데이트 완료: $dateKey, 국가: $countryName');
  }
  
  /// 날짜가 며칠째인지 계산합니다.
  int getDayNumber(DateTime startDate, DateTime date) {
    final difference = date.difference(startDate).inDays;
    return difference + 1; // 1일차부터 시작
  }
  
  /// 일정을 시간순으로 정렬합니다.
  List<Schedule> sortSchedulesByTime(List<Schedule> schedules) {
    final sorted = List<Schedule>.from(schedules);
    sorted.sort((a, b) {
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return sorted;
  }
  
  // /// 신규 여행인지 확인합니다.
  // bool isNewTravel() {
  //   final travel = currentTravel;
  //   if (travel == null) return false;
    
  //   return travel.id.startsWith('temp_') || travel.schedules.isEmpty;
  // }
}

/// UnifiedController Provider
final unifiedControllerProvider = Provider<UnifiedController>((ref) {
  return UnifiedController(ref);
}); 