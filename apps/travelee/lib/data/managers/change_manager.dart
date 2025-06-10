import 'package:travelee/domain/entities/travel_model.dart';
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
  
  /// 변경사항 초기화
  void clearChanges() {
    _hasChanges = false;
  }
  
  bool detectChanges() {
    return _hasChanges;
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
    dev.log('ChangeManager: 변경 상태 확인 - 플래그=$_hasChanges, 실제변경=$hasBasicChanges, 최종=$result');
    
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

    if (backup != current) {
      dev.log('ChangeManager: 목적지 개수 변경 감지');
      return true;
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
} 