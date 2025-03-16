import 'package:travelee/models/travel_model.dart';
import 'package:travelee/models/schedule.dart';
import 'dart:developer' as dev;

/// 변경사항 관리 클래스
/// 
/// 여행 정보의 변경사항을 추적하고 관리하는 클래스입니다.
/// 데이터 백업, 복원, 변경사항 감지 기능을 제공합니다.
class ChangeManager {
  TravelModel? _travelBackup;
  DateTime? _backupTime;
  bool _hasChanges = false;
  
  /// 현재 여행 정보의 백업을 생성합니다.
  void createBackup(TravelModel travel) {
    _travelBackup = travel.copyWith();
    _backupTime = DateTime.now();
    // 백업 생성 시 변경 사항 없음으로 초기화
    _hasChanges = false;
    dev.log('ChangeManager: 여행 ID ${travel.id}의 백업 생성됨');
  }
  
  /// 여행 데이터에 변경 사항을 기록합니다.
  void recordChange() {
    _hasChanges = true;
    dev.log('ChangeManager: 변경 사항 기록됨');
  }
  
  /// 여행 데이터에 변경 사항이 있는지 확인합니다.
  bool hasChanges(TravelModel currentTravel) {
    // 백업이 없으면 변경 사항 없음
    if (_travelBackup == null) {
      return false;
    }
    
    // ID가 다르면 다른 여행이므로 변경 사항 없음
    if (_travelBackup!.id != currentTravel.id) {
      return false;
    }
    
    // 실제 변경 여부 확인 - 더 정확한 비교를 위해 기본적인 속성들 비교
    bool hasBasicChanges = _hasBasicChanges(_travelBackup!, currentTravel);
    
    // 변경 플래그 또는 실제 변경사항 중 하나라도 있으면 변경으로 간주
    bool result = _hasChanges || hasBasicChanges;
    dev.log('ChangeManager: 변경 상태 확인 - 플래그=${_hasChanges}, 실제변경=${hasBasicChanges}, 최종=${result}');
    
    return result;
  }
  
  /// 기본 속성 변경 여부를 확인합니다.
  bool _hasBasicChanges(TravelModel backup, TravelModel current) {
    // 1. 제목 변경 확인
    if (backup.title != current.title) {
      dev.log('ChangeManager: 제목 변경 감지');
      return true;
    }
    
    // 2. 날짜 변경 확인
    if (!_areDatesEqual(backup.startDate, current.startDate) || 
        !_areDatesEqual(backup.endDate, current.endDate)) {
      dev.log('ChangeManager: 날짜 변경 감지');
      return true;
    }
    
    // 3. 목적지 변경 확인
    if (backup.destination.length != current.destination.length) {
      dev.log('ChangeManager: 목적지 개수 변경 감지');
      return true;
    }
    
    for (int i = 0; i < backup.destination.length; i++) {
      if (i >= current.destination.length || backup.destination[i] != current.destination[i]) {
        dev.log('ChangeManager: 목적지 내용 변경 감지');
        return true;
      }
    }
    
    // 4. 일정 개수 변경 확인
    if (backup.schedules.length != current.schedules.length) {
      dev.log('ChangeManager: 일정 개수 변경 감지 (${backup.schedules.length} -> ${current.schedules.length})');
      return true;
    }
    
    return false;
  }
  
  /// 날짜 동일 여부를 확인합니다.
  bool _areDatesEqual(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return true;
    if (date1 == null || date2 == null) return false;
    
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  /// 백업된 여행 정보를 반환합니다.
  TravelModel? getBackup() {
    return _travelBackup;
  }
  
  /// 백업에서 여행 정보를 복원합니다.
  TravelModel restoreFromBackup() {
    if (_travelBackup == null) {
      throw Exception('복원할 백업이 없습니다.');
    }

    final restoredTravel = _travelBackup!;
    dev.log('ChangeManager - 백업에서 복원: ${restoredTravel.id}, 백업 생성 시간: ${_backupTime?.toString() ?? "알 수 없음"}');
    
    // 복원 후 변경 사항 없음으로 표시
    _hasChanges = false;
    
    return restoredTravel;
  }
  
  /// 두 여행 정보가 동일한지 비교합니다.
  bool _isEqual(TravelModel a, TravelModel b) {
    // 기본 필드 비교
    if (a.id != b.id || 
        a.title != b.title || 
        a.startDate != b.startDate || 
        a.endDate != b.endDate) {
      return false;
    }
    
    // 목적지 비교
    if (a.destination.length != b.destination.length) {
      return false;
    }
    
    for (int i = 0; i < a.destination.length; i++) {
      if (a.destination[i] != b.destination[i]) {
        return false;
      }
    }
    
    // 일정 비교
    if (!_compareSchedules(a.schedules, b.schedules)) {
      return false;
    }
    
    // dayDataMap 비교
    if (a.dayDataMap.length != b.dayDataMap.length) {
      return false;
    }
    
    for (final key in a.dayDataMap.keys) {
      if (!b.dayDataMap.containsKey(key)) {
        return false;
      }
      
      final dayDataA = a.dayDataMap[key];
      final dayDataB = b.dayDataMap[key];
      
      if (dayDataA == null || dayDataB == null) {
        if (dayDataA != dayDataB) {
          return false;
        }
        continue;
      }
      
      if (dayDataA.countryName != dayDataB.countryName ||
          dayDataA.flagEmoji != dayDataB.flagEmoji ||
          dayDataA.countryCode != dayDataB.countryCode) {
        return false;
      }
    }
    
    return true;
  }
  
  /// 두 일정 목록이 동일한지 비교합니다.
  bool _compareSchedules(List<Schedule> a, List<Schedule> b) {
    if (a.length != b.length) {
      return false;
    }
    
    // ID 기준으로 정렬된 복사본 생성
    final sortedA = List<Schedule>.from(a)..sort((x, y) => x.id.compareTo(y.id));
    final sortedB = List<Schedule>.from(b)..sort((x, y) => x.id.compareTo(y.id));
    
    for (int i = 0; i < sortedA.length; i++) {
      final scheduleA = sortedA[i];
      final scheduleB = sortedB[i];
      
      if (scheduleA.id != scheduleB.id ||
          scheduleA.travelId != scheduleB.travelId ||
          scheduleA.location != scheduleB.location ||
          scheduleA.memo != scheduleB.memo ||
          scheduleA.time.hour != scheduleB.time.hour ||
          scheduleA.time.minute != scheduleB.time.minute ||
          scheduleA.date != scheduleB.date) {
        return false;
      }
    }
    
    return true;
  }
} 