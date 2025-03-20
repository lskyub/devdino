import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelee/data/models/schedule/schedule.dart';
import 'package:travelee/data/models/travel/travel_model.dart';
import 'package:travelee/presentation/providers/travel_state_provider.dart';
import 'dart:developer' as dev;

/// ScheduleDetailController를 제공하는 Provider
final scheduleDetailControllerProvider = Provider.autoDispose<ScheduleDetailController>((ref) {
  return ScheduleDetailController(ref);
});

/// 일정 상세 화면의 비즈니스 로직을 담당하는 컨트롤러
class ScheduleDetailController {
  final Ref ref;
  
  // 백업 저장 변수
  List<Schedule> _localBackupSchedules = [];
  bool _hasChanges = false;
  
  ScheduleDetailController(this.ref);
  
  /// 현재 변경사항이 있는지 확인
  bool get hasChanges => _hasChanges;
  
  /// 변경 상태 설정
  set hasChanges(bool value) {
    _hasChanges = value;
  }
  
  /// 현재 여행 정보 가져오기
  TravelModel? get currentTravel => ref.read(currentTravelProvider);
  
  /// 현재 날짜의 일정 가져오기
  List<Schedule> getSchedulesForDate(DateTime date) {
    return ref.read(dateSchedulesProvider(date));
  }
  
  /// 현재 날짜의 국가 정보 가져오기
  DayData? getDayData(DateTime date) {
    final travel = currentTravel;
    if (travel == null) return null;
    
    final dateKey = _formatDate(date);
    return travel.dayDataMap[dateKey];
  }
  
  /// 날짜 포맷
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
  
  /// 데이터 백업 생성
  void createBackup(DateTime date) {
    dev.log('ScheduleDetailController - 데이터 백업 생성 시작');
    
    try {
      // 현재 여행 정보 가져오기
      final currentTravel = ref.read(currentTravelProvider);
      if (currentTravel == null) {
        dev.log('ScheduleDetailController - 백업 실패: 현재 여행 정보 없음');
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
      
      dev.log('ScheduleDetailController - 데이터 백업 완료: ${_localBackupSchedules.length}개 (여행 ID: ${currentTravel.id})');
      
    } catch (e) {
      dev.log('ScheduleDetailController - 데이터 백업 중 오류 발생: $e');
    }
  }
  
  /// 백업에서 복원
  void restoreFromBackup(DateTime date) {
    dev.log('ScheduleDetailController - 백업 데이터로 복원 시작');
    
    // 현재 여행 정보 가져오기
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) {
      dev.log('ScheduleDetailController - 복원 실패: 현재 여행 정보 없음');
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
        // Schedule 객체 생성
        final newSchedule = Schedule(
          id: schedule.id,
          travelId: currentTravel.id,
          date: schedule.date,
          time: schedule.time,
          location: schedule.location,
          memo: schedule.memo,
          dayNumber: schedule.dayNumber,
        );
        
        // 일정 추가
        travelNotifier.addSchedule(currentTravel.id, newSchedule);
      }
      
      dev.log('ScheduleDetailController - 백업에서 복원 완료');
      
      // 변경사항 플래그 초기화
      _hasChanges = false;
    } catch (e) {
      dev.log('ScheduleDetailController - 복원 중 오류: $e');
    }
  }
  
  /// 일정 추가
  void addSchedule(DateTime date, TimeOfDay time, String location, String memo) {
    dev.log('ScheduleDetailController - 일정 추가: $date, $time, $location');
    
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) {
      dev.log('ScheduleDetailController - 일정 추가 실패: 현재 여행 정보 없음');
      return;
    }
    
    // 일정 생성
    final dayNumber = _getDayNumber(currentTravel.startDate!, date);
    final newSchedule = Schedule(
      id: 'schedule_${DateTime.now().millisecondsSinceEpoch}',
      travelId: currentTravel.id,
      date: date,
      time: time,
      location: location,
      memo: memo,
      dayNumber: dayNumber,
    );
    
    // 일정 추가
    ref.read(travelsProvider.notifier).addSchedule(currentTravel.id, newSchedule);
    
    _hasChanges = true;
  }
  
  /// 일정 삭제
  void removeSchedule(String scheduleId) {
    dev.log('ScheduleDetailController - 일정 삭제: $scheduleId');
    
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) {
      dev.log('ScheduleDetailController - 일정 삭제 실패: 현재 여행 정보 없음');
      return;
    }
    
    ref.read(travelsProvider.notifier).removeSchedule(currentTravel.id, scheduleId);
    
    _hasChanges = true;
  }
  
  /// 일정 수정
  void updateSchedule(String scheduleId, DateTime date, TimeOfDay time, String location, String memo) {
    dev.log('ScheduleDetailController - 일정 수정: $scheduleId, $date, $time, $location');
    
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) {
      dev.log('ScheduleDetailController - 일정 수정 실패: 현재 여행 정보 없음');
      return;
    }
    
    // dayNumber 계산
    final dayNumber = _getDayNumber(currentTravel.startDate!, date);
    
    // 업데이트된 일정 생성
    final updatedSchedule = Schedule(
      id: scheduleId,
      travelId: currentTravel.id,
      date: date,
      time: time,
      location: location,
      memo: memo,
      dayNumber: dayNumber,
    );
    
    // 일정 업데이트
    ref.read(travelsProvider.notifier).updateSchedule(currentTravel.id, updatedSchedule);
    
    _hasChanges = true;
  }
  
  /// 현재 여행 ID 가져오기
  String _getTravelId() {
    final travel = currentTravel;
    if (travel == null) {
      dev.log('ScheduleDetailController - 여행 정보가 없음');
      return '';
    }
    return travel.id;
  }
  
  /// 국가 정보 업데이트
  void updateCountryInfo(DateTime date, String countryName, String flagEmoji, [String countryCode = '']) {
    final travelId = _getTravelId();
    if (travelId.isEmpty) {
      dev.log('ScheduleDetailController - updateCountryInfo 실패: 여행 ID를 찾을 수 없음');
      return;
    }
    
    try {
      dev.log('ScheduleDetailController - 국가 정보 업데이트: $countryName, $flagEmoji, $countryCode');
      
      // 국가 정보 업데이트
      ref.read(travelsProvider.notifier)
          .setCountryForDate(travelId, date, countryName, flagEmoji, countryCode);
      
      // 변경 플래그 설정
      hasChanges = true;
      
      dev.log('ScheduleDetailController - 국가 정보 업데이트 성공');
    } catch (e) {
      dev.log('ScheduleDetailController - 국가 정보 업데이트 실패: $e');
      throw Exception('국가 정보 업데이트 실패: $e');
    }
  }
  
  /// 날짜의 차이를 계산하여 몇 번째 날인지 반환
  int _getDayNumber(DateTime date, DateTime startDate) {
    return date.difference(startDate).inDays + 1;
  }
  
  /// 일정 시간순 정렬
  List<Schedule> sortSchedulesByTime(List<Schedule> schedules) {
    return List<Schedule>.from(schedules)
      ..sort((a, b) {
        int timeCompare = a.time.hour * 60 + a.time.minute - (b.time.hour * 60 + b.time.minute);
        if (timeCompare != 0) return timeCompare;
        
        // 시간이 같으면 id로 정렬 (최신 추가순)
        return b.id.compareTo(a.id);
      });
  }
  
  /// 변경사항 저장
  void saveChanges() {
    dev.log('ScheduleDetailController - 변경사항 저장');
    ref.read(travelsProvider.notifier).commitChanges();
    _hasChanges = false;
  }
} 