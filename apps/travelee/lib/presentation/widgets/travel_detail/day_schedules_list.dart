import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/text/text.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:travelee/components/travel_day_card.dart';
import 'package:travelee/models/day_schedule_data.dart';
import 'package:travelee/models/travel_model.dart';
import 'package:travelee/utils/travel_date_formatter.dart';
import 'package:travelee/utils/travel_dialog_manager.dart';
import 'package:travelee/utils/travel_drag_drop_manager.dart';
import 'package:travelee/data/controllers/travel_detail_controller.dart';
import 'package:travelee/providers/unified_travel_provider.dart';
import 'package:travelee/models/travel_model.dart';
import 'dart:developer' as dev;

/// 여행 상세 화면의 날짜별 일정 목록 위젯
class DaySchedulesList extends ConsumerWidget {
  final TravelModel travelInfo;
  final List<DayScheduleData> daySchedules;
  
  const DaySchedulesList({
    Key? key,
    required this.travelInfo,
    required this.daySchedules,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(travelDetailControllerProvider);
    final dragDropManager = TravelDragDropManager(ref);
    
    return ListView.builder(
      itemCount: daySchedules.length,
      itemBuilder: (context, index) {
        final daySchedule = daySchedules[index];
        
        // 날짜 키 생성
        final dateKey = TravelDateFormatter.formatDate(daySchedule.date);
        
        // 새로운 방식: dayDataMap에서 직접 최신 데이터 가져오기
        DayData? latestDayData;
        if (travelInfo.dayDataMap.containsKey(dateKey)) {
          latestDayData = travelInfo.dayDataMap[dateKey];
          dev.log('DaySchedulesList - 날짜 $dateKey의 최신 데이터 국가=${latestDayData?.countryName ?? "없음"}, 국기=${latestDayData?.flagEmoji ?? "없음"}');
        } else {
          dev.log('DaySchedulesList - 날짜 $dateKey의 데이터 없음, 기본값 사용');
        }
        
        // 최신 국가 정보 업데이트
        final updatedDaySchedule = daySchedule.copyWith(
          countryName: latestDayData?.countryName ?? daySchedule.countryName,
          flagEmoji: latestDayData?.flagEmoji ?? daySchedule.flagEmoji,
        );
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TravelDayCard(
            daySchedule: updatedDaySchedule,
            formatDate: TravelDateFormatter.formatDate,
            onDeletePressed: () => _handleDeleteDate(context, ref, daySchedule, dateKey),
            onAccept: (data) => _handleDragAccept(ref, dragDropManager, data, updatedDaySchedule),
          ),
        );
      },
    );
  }
  
  /// 날짜 삭제 핸들러
  Future<void> _handleDeleteDate(BuildContext context, WidgetRef ref, DayScheduleData daySchedule, String dateKey) async {
    final shouldDelete = await TravelDialogManager.showDeleteDateConfirmDialog(context);
    if (shouldDelete == true) {
      try {
        // 국가 정보 백업
        String? deletedCountryName;
        String? deletedFlagEmoji;
        String? deletedCountryCode;
        // 삭제할 날짜의 국가 정보 백업
        if (travelInfo.dayDataMap.containsKey(dateKey)) {
          final dayData = travelInfo.dayDataMap[dateKey];
          if (dayData != null) {
            deletedCountryName = dayData.countryName;
            deletedFlagEmoji = dayData.flagEmoji;
            deletedCountryCode = dayData.countryCode;
            dev.log('DaySchedulesList - 삭제 전 국가 정보 백업: $deletedCountryName $deletedFlagEmoji $deletedCountryCode');
          }
        }
        
        // 해당 날짜의 일정들 삭제
        final currentTravel = ref.read(currentTravelProvider);
        if (currentTravel != null) {
          // 해당 날짜의 일정을 제외한 모든 일정 가져오기
          final date = daySchedule.date;
          final updatedSchedules = currentTravel.schedules
            .where((schedule) => 
              schedule.date.year != date.year ||
              schedule.date.month != date.month ||
              schedule.date.day != date.day)
            .toList();
          
          // 기존 dayDataMap 깊은 복사
          final updatedDayDataMap = Map<String, DayData>.from(currentTravel.dayDataMap);
          
          // 해당 날짜의 DayData를 삭제하지 않고 빈 일정으로 유지 (국가 정보 보존)
          if (deletedCountryName != null && deletedFlagEmoji != null && deletedCountryCode != null) {
            updatedDayDataMap[dateKey] = DayData(
              date: date,
              countryName: deletedCountryName,
              flagEmoji: deletedFlagEmoji,
              countryCode: deletedCountryCode,
              dayNumber: daySchedule.dayNumber,
              schedules: [], // 빈 일정
            );
            dev.log('DaySchedulesList - 국가 정보 보존 완료: $dateKey - $deletedCountryName $deletedFlagEmoji');
          }
          
          // 업데이트된 여행 정보로 변경
          final updatedTravel = currentTravel.copyWith(
            schedules: updatedSchedules,
            dayDataMap: updatedDayDataMap,
          );
          
          dev.log('DaySchedulesList - 업데이트된 여행 정보: 일정=${updatedSchedules.length}개, 날짜 데이터=${updatedDayDataMap.length}개');
          ref.read(travelsProvider.notifier).updateTravel(updatedTravel);
          
          // 컨트롤러에 수정 플래그 설정
          ref.read(travelDetailControllerProvider).setModified();
        }
      } catch (e) {
        dev.log('DaySchedulesList - 날짜 삭제 중 오류 발생: $e');
      }
    }
  }
  
  /// 드래그 앤 드롭 처리 핸들러
  void _handleDragAccept(WidgetRef ref, TravelDragDropManager dragDropManager, Map<String, dynamic> data, DayScheduleData updatedDaySchedule) {
    final scheduleIds = data['scheduleIds'] as List<dynamic>;
    final sourceDate = data['date'] as DateTime;
    final sourceDayNumber = data['dayNumber'] as int;
    final sourceCountry = data['country'] as String;
    
    // countryFlag 대신 countryCode로 변경
    // 호환성을 위해 'countryFlag'와 'countryCode' 둘 다 체크
    final String? sourceCountryCode = data.containsKey('countryCode') ? data['countryCode'] as String? : null;
    final String? sourceCountryFlag = data.containsKey('countryFlag') ? data['countryFlag'] as String? : null;
    
    dev.log('드래그 데이터: countryCode=$sourceCountryCode, countryFlag=$sourceCountryFlag');
    
    dragDropManager.handleDragAccept(
      travelId: travelInfo.id,
      sourceDate: sourceDate,
      targetDate: updatedDaySchedule.date,
      scheduleIds: scheduleIds.cast<String>(), // 추가 안전 캐스팅
      sourceDayNumber: sourceDayNumber,
      sourceCountry: sourceCountry,
      sourceCountryFlag: sourceCountryCode ?? sourceCountryFlag ?? '', // countryCode 우선, 없으면 flag 사용
    );
    
    // 컨트롤러에 수정 플래그 설정
    ref.read(travelDetailControllerProvider).setModified();
  }
} 