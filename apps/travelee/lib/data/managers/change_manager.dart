import 'package:travelee/models/travel_model.dart';
import 'package:travelee/models/schedule.dart';
import 'dart:developer' as dev;

/// 변경사항 관리 클래스
/// 
/// 여행 정보의 변경사항을 추적하고 관리하는 클래스입니다.
/// 데이터 백업, 복원, 변경사항 감지 기능을 제공합니다.
class ChangeManager {
  TravelModel? _backup;
  
  /// 현재 여행 정보의 백업을 생성합니다.
  void createBackup(TravelModel travel) {
    _backup = travel.copyWith();
    dev.log('ChangeManager: 여행 ID ${travel.id}의 백업 생성됨');
  }
  
  /// 현재 여행 정보에 변경사항이 있는지 확인합니다.
  bool hasChanges(TravelModel current) {
    if (_backup == null) return false;
    return !_isEqual(_backup!, current);
  }
  
  /// 백업된 여행 정보를 반환합니다.
  TravelModel? getBackup() {
    return _backup;
  }
  
  /// 백업에서 여행 정보를 복원합니다.
  TravelModel restoreFromBackup() {
    if (_backup == null) {
      throw Exception('백업이 존재하지 않습니다.');
    }
    dev.log('ChangeManager: 여행 ID ${_backup!.id}가 백업에서 복원됨');
    return _backup!.copyWith();
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