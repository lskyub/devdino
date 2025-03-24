import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelee/data/models/schedule/schedule.dart';
import 'package:travelee/data/models/travel/travel_model.dart';
import 'package:travelee/data/models/schedule/day_schedule_data.dart';
import 'package:travelee/providers/travel_state_provider.dart';
import 'package:travelee/core/utils/travel_date_formatter.dart';
import 'dart:math' as Math;
import 'dart:developer' as dev;

/// 여행 상세 화면의 비즈니스 로직을 담당하는 컨트롤러
class TravelDetailController {
  final Ref ref;
  
  // 백업 저장을 위한 변수들
  List<Schedule> _originalScheduleBackup = [];
  List<DayScheduleData> _originalDayScheduleBackup = [];
  bool _hasChanges = false;
  bool _backupCreated = false;
  
  TravelDetailController(this.ref);
  
  /// 백업이 생성되었는지 확인
  bool get isBackupCreated => _backupCreated;
  
  /// 백업 상태 설정
  set backupCreated(bool value) {
    _backupCreated = value;
  }
  
  /// 변경 상태 설정
  set hasChanges(bool value) {
    _hasChanges = value;
  }
  
  /// 현재 여행 정보 가져오기
  TravelModel? get currentTravel => ref.read(currentTravelProvider);
  
  /// 화면 시작 시 데이터 백업 생성
  void createBackup() {
    dev.log('TravelDetailController - 데이터 백업 생성 시작');
    
    try {
      // 스케줄 데이터 백업 전에 명시적 임시 편집 모드 종료 (초기화 전)
      ref.read(travelsProvider.notifier).commitChanges();
      
      // 1. 여행 정보 백업
      final travelInfo = currentTravel;
      if (travelInfo == null) return;
      
      dev.log('TravelDetailController - 백업할 여행 정보: ID=${travelInfo.id}, 일정=${travelInfo.schedules.length}개');
      
      // 2. 스케줄 데이터 백업 (깊은 복사)
      final schedules = travelInfo.schedules;
      _originalScheduleBackup = schedules.map((schedule) {
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
      
      // 3. 날짜별 데이터 백업 (깊은 복사)
      // 통합 Provider에서는 날짜별 DayData를 TravelModel에서 직접 가져옴
      final dayDataMap = travelInfo.dayDataMap;
      _originalDayScheduleBackup = dayDataMap.values.map((dayData) {
        return DayScheduleData(
          date: DateTime(dayData.date.year, dayData.date.month, dayData.date.day),
          countryName: dayData.countryName,
          flagEmoji: dayData.flagEmoji,
          dayNumber: dayData.dayNumber,
          countryCode: dayData.countryCode,
          schedules: dayData.schedules.map((schedule) {
            return Schedule(
              id: schedule.id,
              travelId: schedule.travelId,
              date: DateTime(schedule.date.year, schedule.date.month, schedule.date.day),
              time: TimeOfDay(hour: schedule.time.hour, minute: schedule.time.minute),
              location: schedule.location,
              memo: schedule.memo,
              dayNumber: schedule.dayNumber,
            );
          }).toList(),
        );
      }).toList();
      
      // 일부 백업 데이터 로깅
      for (int i = 0; i < Math.min(3, dayDataMap.length); i++) {
        final key = dayDataMap.keys.elementAt(i);
        final dayData = dayDataMap[key];
        dev.log('TravelDetailController - 백업 데이터[$i]: 날짜=$key, 국가=${dayData?.countryName}, 플래그=${dayData?.flagEmoji}');
      }
      
      // 백업 후에 임시 편집 모드 다시 시작
      ref.read(travelsProvider.notifier).startTempEditing();
      
      _backupCreated = true;
      _hasChanges = false;
      
      dev.log('TravelDetailController - 데이터 백업 완료');
      dev.log('  - 일정 데이터: ${_originalScheduleBackup.length}개');
      dev.log('  - 날짜별 데이터: ${_originalDayScheduleBackup.length}개');
      
    } catch (e) {
      dev.log('TravelDetailController - 데이터 백업 중 오류 발생: $e');
      dev.log('TravelDetailController - 오류 스택: ${e is Error ? e.stackTrace : ""}');
    }
  }
  
  /// 변경 사항 감지
  bool detectChanges() {
    if (!_backupCreated) {
      dev.log('TravelDetailController - 백업이 아직 생성되지 않았습니다.');
      return false;
    }
    
    // 강제 설정된 변경 사항 확인
    if (_hasChanges) {
      dev.log('TravelDetailController - 변경 플래그가 설정되어 있습니다.');
      return true;
    }
    
    // Provider의 변경 사항 확인
    final providerHasChanges = ref.read(travelsProvider.notifier).hasChanges();
    dev.log('TravelDetailController - travelsProvider.hasChanges(): $providerHasChanges');
    
    // 현재 상태 확인
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) return false;
    
    final currentSchedules = currentTravel.schedules;
    
    // 일정 개수 비교
    if (_originalScheduleBackup.length != currentSchedules.length) {
      dev.log('TravelDetailController - 일정 개수가 변경되었습니다 (${_originalScheduleBackup.length} -> ${currentSchedules.length})');
      return true;
    }
    
    return providerHasChanges || _hasChanges;
  }
  
  /// 수정 플래그 설정
  void setModified() {
    dev.log('TravelDetailController - 수정 플래그 설정');
    _hasChanges = true;
  }
  
  /// 백업 데이터로 원래 상태 복원
  Future<void> restoreFromBackup() async {
    dev.log('TravelDetailController - 백업 데이터로 복원 시작');
    
    // 여행 정보 확인
    final travelInfo = currentTravel;
    if (travelInfo == null) return;
    
    // 임시 여행(신규 생성)인 경우 복원 무시
    if (travelInfo.id.isEmpty || travelInfo.id.startsWith('temp_')) {
      dev.log('TravelDetailController - 신규 여행 생성 모드: 복원 로직 무시');
      return;
    }
    
    if (!_backupCreated) {
      dev.log('TravelDetailController - 백업 데이터가 없습니다.');
      return;
    }
    
    // 백업 데이터 유효성 검사
    if (_originalScheduleBackup.isEmpty) {
      dev.log('TravelDetailController - 경고: 백업 일정 데이터가 비어 있습니다. 안전한 복원이 불가능합니다.');
      dev.log('TravelDetailController - 현재 백업 데이터 크기: ${_originalScheduleBackup.length}');
      
      final currentTravel = ref.read(currentTravelProvider);
      if (currentTravel != null) {
        dev.log('TravelDetailController - 현재 스케줄 수: ${currentTravel.schedules.length}');
      }
    } else {
      dev.log('TravelDetailController - 백업 데이터 유효성 확인됨: ${_originalScheduleBackup.length}개 일정');
      
      // 백업 데이터 내용 확인을 위한 기본 정보 로깅
      for (int i = 0; i < Math.min(3, _originalScheduleBackup.length); i++) {
        final schedule = _originalScheduleBackup[i];
        dev.log('  백업[$i]: ID=${schedule.id}, 위치=${schedule.location}');
      }
    }
    
    try {
      // 1. 상태 초기화
      _hasChanges = false;
      
      // 2. scheduleProvider를 직접 정확히 백업 상태로 복원 (Provider 내부 롤백 함수 대신 직접 상태 설정)
      final schedulesCopy = _originalScheduleBackup.map((schedule) => 
        Schedule(
          id: schedule.id,
          travelId: schedule.travelId,
          date: DateTime(schedule.date.year, schedule.date.month, schedule.date.day),
          time: TimeOfDay(hour: schedule.time.hour, minute: schedule.time.minute),
          location: schedule.location,
          memo: schedule.memo,
          dayNumber: schedule.dayNumber,
        )
      ).toList();
      
      // 3. 날짜별 데이터 dayDataMap 복원 준비
      final dayDataMapCopy = <String, DayData>{};
      for (final dayScheduleData in _originalDayScheduleBackup) {
        final dateKey = TravelDateFormatter.formatDate(dayScheduleData.date);
        dayDataMapCopy[dateKey] = DayData(
          date: dayScheduleData.date,
          countryName: dayScheduleData.countryName,
          flagEmoji: dayScheduleData.flagEmoji,
          countryCode: dayScheduleData.countryCode,
          dayNumber: dayScheduleData.dayNumber,
          schedules: dayScheduleData.schedules.map((s) => 
            Schedule(
              id: s.id,
              travelId: s.travelId,
              date: DateTime(s.date.year, s.date.month, s.date.day),
              time: TimeOfDay(hour: s.time.hour, minute: s.time.minute),
              location: s.location,
              memo: s.memo,
              dayNumber: s.dayNumber,
            )
          ).toList(),
        );
      }
      
      dev.log('TravelDetailController - dayDataMap 복원 준비 완료: ${dayDataMapCopy.length}개 날짜 데이터');
      
      // 기존 여행 정보 가져오기
      final currentTravel = ref.read(currentTravelProvider);
      if (currentTravel != null) {
        // 업데이트된 여행 정보로 변경 (스케줄과 dayDataMap 모두 복원)
        final updatedTravel = currentTravel.copyWith(
          schedules: schedulesCopy,
          dayDataMap: dayDataMapCopy,
        );
        
        dev.log('TravelDetailController - 복원된 여행 정보: ID=${updatedTravel.id}, 일정=${updatedTravel.schedules.length}개, 날짜 데이터=${updatedTravel.dayDataMap.length}개');
        
        ref.read(travelsProvider.notifier).updateTravel(updatedTravel);
        dev.log('TravelDetailController - 원본 데이터 직접 강제 복원 성공');
      } else {
        dev.log('TravelDetailController - 일정 복원 실패: 현재 여행 정보 없음');
      }
      
      // 3. 강제 리렌더링을 위해 모든 상태 갱신
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 4. 강제로 현재 여행 ID 재설정하여 화면 갱신
      final currentId = ref.read(currentTravelIdProvider);
      ref.read(currentTravelIdProvider.notifier).state = '';
      await Future.delayed(const Duration(milliseconds: 50));
      ref.read(currentTravelIdProvider.notifier).state = currentId;
      
      dev.log('TravelDetailController - 복원 작업 완료');
      dev.log('TravelDetailController - 복원 후 일정 수: ${ref.read(currentTravelProvider)?.schedules.length ?? 0}개 (백업 원본: ${_originalScheduleBackup.length}개)');
      
    } catch (e) {
      dev.log('TravelDetailController - 백업 복원 중 오류 발생: $e');
      dev.log('TravelDetailController - 오류 스택: ${e is Error ? e.stackTrace : ""}');
      
      // 오류 복구 시도
      try {
        // 기본 롤백 시도
        ref.read(travelsProvider.notifier).rollbackChanges();
        dev.log('TravelDetailController - 기본 롤백 메서드로 복구 시도');
      } catch (recoverError) {
        dev.log('TravelDetailController - 복구 시도 중 추가 오류: $recoverError');
      }
    }
  }
  
  /// 임시 여행 ID를 영구 저장
  String? saveTempTravel(String currentId) {
    if (currentId.isNotEmpty && currentId.startsWith('temp_')) {
      return ref.read(travelsProvider.notifier).saveTempTravel(currentId);
    }
    return null;
  }
  
  /// 현재 여행이 새 여행인지 확인
  bool isNewTravel() {
    final travel = currentTravel;
    if (travel == null) return true;
    return travel.id.isEmpty || travel.id.startsWith('temp_');
  }
  
  /// 날짜가 여행의 몇 번째 날인지 계산
  int getDayNumber(DateTime startDate, DateTime date) {
    // 두 날짜간 차이 계산 (일 단위)
    final difference = DateTime(date.year, date.month, date.day)
        .difference(DateTime(startDate.year, startDate.month, startDate.day))
        .inDays;
    
    // Day 1부터 시작
    return difference + 1;
  }
}

// TravelDetailController Provider 등록
final travelDetailControllerProvider = Provider.autoDispose<TravelDetailController>((ref) {
  return TravelDetailController(ref);
});

// 여행 변경 감지 Provider
final travelChangesProvider = Provider.autoDispose<bool>((ref) {
  final controller = ref.watch(travelDetailControllerProvider);
  return controller.detectChanges();
}); 