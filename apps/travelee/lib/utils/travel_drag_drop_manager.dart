import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelee/models/travel_model.dart';
import 'package:travelee/models/schedule.dart';
import 'package:travelee/models/country_info.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/utils/travel_date_formatter.dart';
import 'dart:developer' as dev;

/**
 * TravelDragDropManager
 * 
 * 여행 일정 카드의 드래그 앤 드롭 기능을 관리하는 클래스
 * - 드래그 앤 드롭 이벤트 처리
 * - 일정 간 이동 로직 구현
 * - 드래그 결과 검증 및 오류 처리
 * - 필요한 경우 데이터 새로고침
 */
class TravelDragDropManager {
  final WidgetRef ref;
  
  TravelDragDropManager(this.ref);
  
  /**
   * 드래그 앤 드롭 수락 이벤트 처리
   * @param travelId 여행 ID
   * @param sourceDate 원본 날짜
   * @param targetDate 대상 날짜
   * @param scheduleIds 이동할 일정 ID 목록
   * @param sourceDayNumber 원본 Day 번호
   * @param sourceCountry 원본 국가
   * @param sourceCountryFlag 원본 국가 코드 또는 플래그 (호환성 유지를 위해 파라미터명은 유지)
   */
  void handleDragAccept({
    required String travelId,
    required DateTime sourceDate,
    required DateTime targetDate,
    required List<String> scheduleIds,
    required int sourceDayNumber,
    required String sourceCountry,
    required String sourceCountryFlag,
  }) {
    dev.log('TravelDragDropManager - handleDragAccept 실행');
    dev.log('원본 날짜=${TravelDateFormatter.formatDate(sourceDate)}, 대상 날짜=${TravelDateFormatter.formatDate(targetDate)}');
    dev.log('원본 Day=$sourceDayNumber, 원본 국가=$sourceCountry, 원본 플래그=$sourceCountryFlag');
    
    // 현재 여행 정보 가져오기
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) return;
    
    try {
      // 1. 대상 날짜와 원본 날짜의 DayData 가져오기
      final targetDateKey = TravelDateFormatter.formatDate(targetDate);
      final sourceDateKey = TravelDateFormatter.formatDate(sourceDate);
      final targetDayData = currentTravel.dayDataMap[targetDateKey];
      final sourceDayData = currentTravel.dayDataMap[sourceDateKey];
      
      // 국가 정보 확인 및 기록
      dev.log('드래그 전 소스 국가 정보: ${sourceDayData?.countryName ?? "없음"}, ${sourceDayData?.flagEmoji ?? "없음"}');
      dev.log('드래그 전 타겟 국가 정보: ${targetDayData?.countryName ?? "없음"}, ${targetDayData?.flagEmoji ?? "없음"}');
      
      // 2. 소스와 타겟의 상태 확인
      final bool isSourceEmpty = (sourceDayData == null || sourceDayData.countryName.isEmpty);
      final bool isTargetEmpty = (targetDayData == null || targetDayData.countryName.isEmpty);
      
      // 3. 대상 날짜의 day 번호 계산
      final targetDayNumber = _calculateDayNumber(currentTravel.startDate!, targetDate);
      
      // 4. 원본 및 대상 일정 분리
      final allSchedules = List<Schedule>.from(currentTravel.schedules);
      
      // 이동할 일정 목록 (드래그된 일정들)
      final schedulesToMove = allSchedules.where((s) => scheduleIds.contains(s.id)).toList();
      
      // 타겟에 있는 일정들
      final targetExistingSchedules = allSchedules.where((s) => 
        !scheduleIds.contains(s.id) && 
        s.date.year == targetDate.year && 
        s.date.month == targetDate.month && 
        s.date.day == targetDate.day
      ).toList();
      
      // 소스에 남아있는 일정들 (이동 대상이 아닌 일정들)
      final remainingSourceSchedules = allSchedules.where((s) => 
        !scheduleIds.contains(s.id) && 
        s.date.year == sourceDate.year && 
        s.date.month == sourceDate.month && 
        s.date.day == sourceDate.day
      ).toList();
      
      // 5. 데이터 교환 처리
      List<Schedule> updatedSchedules = List<Schedule>.from(currentTravel.schedules);
      Map<String, DayData> updatedDayDataMap = Map<String, DayData>.from(currentTravel.dayDataMap);
      
      // 소스 국가 정보 확정 (항상 전달받은 파라미터 사용 - 가장 최신 정보)
      String sourceCountryName = sourceCountry;
      String sourceFlagEmoji = sourceCountryFlag;
      
      // 타겟 국가 정보 확정 (타겟에 데이터가 있으면 그것을 사용)
      String targetCountryName = targetDayData?.countryName ?? "";
      String targetFlagEmoji = targetDayData?.flagEmoji ?? "";
      
      // 양쪽 다 데이터가 있는 경우 - 완전 교환
      if (!isSourceEmpty && !isTargetEmpty) {
        dev.log('📌 양쪽 모두 데이터 있음 - 완전 교환');
        
        // 5.1. 타겟의 일정을 소스로 이동
        for (var schedule in targetExistingSchedules) {
          final index = updatedSchedules.indexWhere((s) => s.id == schedule.id);
          if (index != -1) {
            updatedSchedules[index] = schedule.copyWith(
              date: sourceDate,
              dayNumber: sourceDayNumber,
            );
          }
        }
        
        // 5.2. 드래그한 일정들을 타겟으로 이동
        for (var schedule in schedulesToMove) {
          final index = updatedSchedules.indexWhere((s) => s.id == schedule.id);
          if (index != -1) {
            updatedSchedules[index] = schedule.copyWith(
              date: targetDate,
              dayNumber: targetDayNumber,
            );
          }
        }
        
        // 5.3. 국가 정보 교환 (명시적으로 저장)
        String tempCountryName = sourceCountryName;
        String tempFlagEmoji = sourceFlagEmoji;
        
        // 소스 → 타겟의 국가 정보로 변경
        sourceCountryName = targetCountryName;
        sourceFlagEmoji = targetFlagEmoji;
        
        // 타겟 → 소스의 국가 정보로 변경
        targetCountryName = tempCountryName;
        targetFlagEmoji = tempFlagEmoji;
        
        // 이모지 확인 및 설정 - 국가 정보는 있는데 이모지가 없는 경우
        if (sourceCountryName.isNotEmpty && (sourceFlagEmoji.isEmpty || sourceFlagEmoji == "🏳️")) {
          // 국가 정보에서 이모지 찾기
          final countryInfo = currentTravel.countryInfos.firstWhere(
            (info) => info.name == sourceCountryName,
            orElse: () => CountryInfo(name: sourceCountryName, countryCode: '', flagEmoji: '🏳️'),
          );
          sourceFlagEmoji = countryInfo.flagEmoji;
          dev.log('소스 이모지 복원: $sourceCountryName -> $sourceFlagEmoji');
        }
        
        if (targetCountryName.isNotEmpty && (targetFlagEmoji.isEmpty || targetFlagEmoji == "🏳️")) {
          // 국가 정보에서 이모지 찾기
          final countryInfo = currentTravel.countryInfos.firstWhere(
            (info) => info.name == targetCountryName,
            orElse: () => CountryInfo(name: targetCountryName, countryCode: '', flagEmoji: '🏳️'),
          );
          targetFlagEmoji = countryInfo.flagEmoji;
          dev.log('타겟 이모지 복원: $targetCountryName -> $targetFlagEmoji');
        }
        
        // 5.4. 소스 DayData 업데이트
        updatedDayDataMap[sourceDateKey] = sourceDayData!.copyWith(
          countryName: sourceCountryName,
          flagEmoji: sourceFlagEmoji,
          schedules: targetExistingSchedules.map((s) => s.copyWith(
            date: sourceDate,
            dayNumber: sourceDayNumber,
          )).toList() + remainingSourceSchedules,
        );
        
        // 5.5. 타겟 DayData 업데이트
        updatedDayDataMap[targetDateKey] = targetDayData!.copyWith(
          countryName: targetCountryName, 
          flagEmoji: targetFlagEmoji,
          schedules: schedulesToMove.map((s) => s.copyWith(
            date: targetDate,
            dayNumber: targetDayNumber,
          )).toList(),
        );
      }
      // 그 외 모든 경우 - 무조건 교환 방식으로 처리
      else {
        dev.log('📌 기타 상황 - 무조건 국가 정보 교환 방식으로 처리');
        
        // 5.1. 드래그한 일정들을 타겟으로 이동
        for (var schedule in schedulesToMove) {
          final index = updatedSchedules.indexWhere((s) => s.id == schedule.id);
          if (index != -1) {
            updatedSchedules[index] = schedule.copyWith(
              date: targetDate,
              dayNumber: targetDayNumber,
            );
          }
        }
        
        // 5.2. 국가 정보 교환 (명시적으로 저장)
        String tempCountryName = sourceCountryName;
        String tempFlagEmoji = sourceFlagEmoji;
        
        // 소스 → 타겟의 국가 정보로 변경 (타겟이 비어있으면 비워두지 않고 기본 국가 사용)
        sourceCountryName = targetCountryName.isNotEmpty ? targetCountryName : 
                            (currentTravel.destination.isNotEmpty ? currentTravel.destination.first : "");
        sourceFlagEmoji = targetFlagEmoji.isNotEmpty ? targetFlagEmoji : "🏳️";
        
        // 타겟 → 소스의 국가 정보로 변경
        targetCountryName = tempCountryName;
        targetFlagEmoji = tempFlagEmoji;
        
        // 빈 값 검사 - 타겟 국가가 비어있으면 소스의 값을 그대로 사용
        if (targetCountryName.isEmpty && currentTravel.destination.isNotEmpty) {
          targetCountryName = currentTravel.destination.first;
          final countryInfo = currentTravel.countryInfos.firstWhere(
            (info) => info.name == targetCountryName,
            orElse: () => CountryInfo(name: targetCountryName, countryCode: '', flagEmoji: '🏳️'),
          );
          targetFlagEmoji = countryInfo.flagEmoji;
        }
        
        // 이모지 확인 및 설정 - 국가 정보는 있는데 이모지가 없는 경우
        if (sourceCountryName.isNotEmpty && (sourceFlagEmoji.isEmpty || sourceFlagEmoji == "🏳️")) {
          // 국가 정보에서 이모지 찾기
          final countryInfo = currentTravel.countryInfos.firstWhere(
            (info) => info.name == sourceCountryName,
            orElse: () => CountryInfo(name: sourceCountryName, countryCode: '', flagEmoji: '🏳️'),
          );
          sourceFlagEmoji = countryInfo.flagEmoji;
          dev.log('소스 이모지 복원: $sourceCountryName -> $sourceFlagEmoji');
        }
        
        if (targetCountryName.isNotEmpty && (targetFlagEmoji.isEmpty || targetFlagEmoji == "🏳️")) {
          // 국가 정보에서 이모지 찾기
          final countryInfo = currentTravel.countryInfos.firstWhere(
            (info) => info.name == targetCountryName,
            orElse: () => CountryInfo(name: targetCountryName, countryCode: '', flagEmoji: '🏳️'),
          );
          targetFlagEmoji = countryInfo.flagEmoji;
          dev.log('타겟 이모지 복원: $targetCountryName -> $targetFlagEmoji');
        }
        
        // 5.3. 소스 DayData 업데이트
        if (sourceDayData != null) {
          updatedDayDataMap[sourceDateKey] = sourceDayData.copyWith(
            countryName: sourceCountryName,
            flagEmoji: sourceFlagEmoji,
            schedules: remainingSourceSchedules,
          );
        } else {
          // 소스에 데이터가 없으면 새로 생성
          updatedDayDataMap[sourceDateKey] = DayData(
            date: sourceDate,
            countryName: sourceCountryName,
            flagEmoji: sourceFlagEmoji,
            dayNumber: sourceDayNumber,
            schedules: remainingSourceSchedules,
          );
        }
        
        // 5.4. 타겟 DayData 업데이트 또는 생성
        if (targetDayData != null) {
          updatedDayDataMap[targetDateKey] = targetDayData.copyWith(
            countryName: targetCountryName,
            flagEmoji: targetFlagEmoji,
            schedules: targetExistingSchedules + schedulesToMove.map((s) => s.copyWith(
              date: targetDate,
              dayNumber: targetDayNumber,
            )).toList(),
          );
        } else {
          // 타겟에 데이터가 없으면 새로 생성
          updatedDayDataMap[targetDateKey] = DayData(
            date: targetDate,
            countryName: targetCountryName,
            flagEmoji: targetFlagEmoji,
            dayNumber: targetDayNumber,
            schedules: schedulesToMove.map((s) => s.copyWith(
              date: targetDate,
              dayNumber: targetDayNumber,
            )).toList(),
          );
        }
      }
      
      // 6. 업데이트된 데이터 저장
      final updatedTravel = currentTravel.copyWith(
        schedules: updatedSchedules,
        dayDataMap: updatedDayDataMap,
      );
      
      // 7. 여행 정보 업데이트
      ref.read(travelsProvider.notifier).updateTravel(updatedTravel);
      
      // 8. 변경 사항 즉시 저장
      ref.read(travelsProvider.notifier).commitChanges();
      
      // 9. 로그 출력
      dev.log('TravelDragDropManager - 드래그 앤 드롭 처리 완료');
      dev.log('드래그한 일정 수: ${schedulesToMove.length}개');
      dev.log('타겟 기존 일정 수: ${targetExistingSchedules.length}개');
      
      // 국가 정보 교환 결과 확인 로그
      final updatedSourceData = updatedDayDataMap[sourceDateKey];
      final updatedTargetData = updatedDayDataMap[targetDateKey];
      
      dev.log('국가 정보 교환 결과:');
      dev.log('- 소스 국가 정보: ${updatedSourceData?.countryName ?? "없음"}, ${updatedSourceData?.flagEmoji ?? "없음"}');
      dev.log('- 타겟 국가 정보: ${updatedTargetData?.countryName ?? "없음"}, ${updatedTargetData?.flagEmoji ?? "없음"}');
      
      // 10. 데이터 즉시 반영 및 엄격한 확인
      Future.delayed(const Duration(milliseconds: 100), () {
        final currentId = ref.read(currentTravelIdProvider);
        if (currentId.isNotEmpty) {
          // 여행 데이터 강제 갱신
          ref.read(currentTravelIdProvider.notifier).state = "";
          ref.read(currentTravelIdProvider.notifier).state = currentId;
          
          // 교환 결과 확인 로직 호출
          _verifyDragExchangeResult(travelId, sourceDate, targetDate);
        }
      });
      
    } catch (e, stackTrace) {
      dev.log('TravelDragDropManager - 드래그 앤 드롭 처리 중 오류 발생: $e');
      dev.log('스택 트레이스: $stackTrace');
      
      // 오류 발생 시 즉시 상태 갱신 시도
      _refreshData(travelId);
    }
  }
  
  // 날짜가 몇 번째 날인지 계산하는 헬퍼 메서드
  int _calculateDayNumber(DateTime startDate, DateTime date) {
    return DateTime(date.year, date.month, date.day)
      .difference(DateTime(startDate.year, startDate.month, startDate.day))
      .inDays + 1;
  }
  
  /**
   * 드래그 앤 드롭 결과 검증
   * @param travelId 여행 ID
   * @param sourceDate 원본 날짜
   * @param targetDate 대상 날짜
   */
  void _verifyDragExchangeResult(
    String travelId, 
    DateTime sourceDate, 
    DateTime targetDate
  ) {
    Future.delayed(const Duration(milliseconds: 100), () {
      final currentTravel = ref.read(currentTravelProvider);
      if (currentTravel == null) return;
      
      // 원본과 대상의 상태 확인
      final sourceDayData = currentTravel.getDayData(sourceDate);
      final targetDayData = currentTravel.getDayData(targetDate);
      
      dev.log('TravelDragDropManager - 교환 결과 확인:');
      if (sourceDayData != null) {
        dev.log('  - 원본 Day ${sourceDayData.dayNumber}: 국가=${sourceDayData.countryName}, 일정=${sourceDayData.schedules.length}개');
      }
      if (targetDayData != null) {
        dev.log('  - 대상 Day ${targetDayData.dayNumber}: 국가=${targetDayData.countryName}, 일정=${targetDayData.schedules.length}개');
      }
      
      // 데이터 새로고침
      Future.delayed(const Duration(milliseconds: 300), () {
        _refreshData(travelId);
      });
    });
  }
  
  /**
   * 드래그 앤 드롭 오류 처리
   * @param travelId 여행 ID
   */
  void _handleDragError(String travelId) {
    Future.delayed(const Duration(milliseconds: 500), () {
      _refreshData(travelId);
    });
  }
  
  /**
   * 데이터 새로고침
   * @param travelId 여행 ID
   */
  void _refreshData(String travelId) {
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel != null && currentTravel.id == travelId) {
      dev.log('TravelDragDropManager - 데이터 새로고침');
      // 현재 여행 정보를 다시 로드하기 위해 ID를 재설정
      final currentId = ref.read(currentTravelIdProvider);
      ref.read(currentTravelIdProvider.notifier).state = '';
      ref.read(currentTravelIdProvider.notifier).state = currentId;
    }
  }
} 