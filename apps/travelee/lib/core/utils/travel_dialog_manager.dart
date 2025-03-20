import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_systems/dino/dino.dart';
import 'package:travelee/data/models/location/country_info.dart';
import 'package:travelee/data/models/travel/travel_model.dart';
import 'package:travelee/presentation/providers/travel_state_provider.dart';
import 'package:travelee/presentation/screens/travel_detail/edit/edit_travel_dialog.dart';
import 'package:travelee/core/utils/date_util.dart';
import 'dart:developer' as dev;
/// TravelDialogManager
///
/// 여행 관련 다이얼로그를 관리하는 유틸리티 클래스
/// - 여행 일정 날짜 삭제 확인 다이얼로그
/// - 여행 정보 수정 다이얼로그 및 관련 로직 처리
/// - 국가 정보 백업 및 복원 기능 제공
class TravelDialogManager {
  /// 날짜 삭제 확인 다이얼로그 표시
  /// @param context 현재 빌드 컨텍스트
  /// @return 사용자 응답 (true: 삭제 승인, false: 취소)
  static Future<bool?> showDeleteDateConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const DinoText(
          type: DinoTextType.bodyXL,
          text: '날짜 삭제 확인',
        ),
        content: const DinoText(
          type: DinoTextType.bodyL,
          text: '해당 날짜의 모든 일정이 삭제됩니다.\n계속하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: DinoText(
              type: DinoTextType.bodyL,
              text: '취소',
              color: $dinoToken.color.blingGray400.resolve(context),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const DinoText(
              type: DinoTextType.bodyXL,
              text: '삭제',
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  /// 여행 정보 수정 다이얼로그 표시 및 결과 처리
  /// @param context 현재 빌드 컨텍스트
  /// @param ref Provider 참조
  static Future<void> showEditTravelDialog(
      BuildContext context, WidgetRef ref) async {
    final currentTravel = ref.read(currentTravelProvider);
    if (currentTravel == null) {
      dev.log('여행 정보 없음');
      return;
    }

    // 기존 국가 목록 백업 (국가 삭제 여부 확인을 위함)
    final oldDestinations = List<String>.from(currentTravel.destination);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => EditTravelDialog(
        initialDestination: currentTravel.destination,
        initialCountryInfos: currentTravel.countryInfos,
        initialStartDate: currentTravel.startDate ?? DateTime.now(),
        initialEndDate: currentTravel.endDate ??
            DateTime.now().add(const Duration(days: 1)),
      ),
    );

    if (result != null) {
      final newStartDate = result['startDate'] as DateTime;
      final newEndDate = result['endDate'] as DateTime;
      final newDestination = result['destination'] as List<String>;
      final newCountryInfos =
          (result['countryInfos'] as List).cast<CountryInfo>();

      // 삭제된 국가 확인
      final removedDestinations =
          oldDestinations.where((d) => !newDestination.contains(d)).toList();

      // 새로 추가된 국가 확인
      final addedDestinations =
          newDestination.where((d) => !oldDestinations.contains(d)).toList();

      if (removedDestinations.isNotEmpty) {
        dev.log('travel_detail_screen - 삭제된 국가: $removedDestinations');

        // 삭제된 국가를 사용 중인 날짜들의 국가 정보 초기화
        // 데이터가 없어도 국가 정보를 초기화하도록 조건 제거
        _resetCountryInfoForRemovedDestinations(
            ref, currentTravel, removedDestinations, newDestination);
      }

      if (addedDestinations.isNotEmpty) {
        dev.log('travel_detail_screen - 새로 추가된 국가: $addedDestinations');
      }

      // 날짜가 변경되었는지 확인
      final isDateChanged = newStartDate != currentTravel.startDate ||
          newEndDate != currentTravel.endDate;

      if (isDateChanged) {
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const DinoText(
              type: DinoTextType.bodyXL,
              text: '날짜 변경 확인',
            ),
            content: const DinoText(
              type: DinoTextType.bodyL,
              text: '날짜를 변경하면 기존 일정의 날짜가 조정됩니다.\n계속하시겠습니까?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: DinoText(
                  type: DinoTextType.bodyL,
                  text: '취소',
                  color: $dinoToken.color.blingGray400.resolve(context),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: DinoText(
                  type: DinoTextType.bodyL,
                  text: '확인',
                  color: $dinoToken.color.blingGray400.resolve(context),
                ),
              ),
            ],
          ),
        );

        if (shouldProceed == true) {
          // 새 TravelModel 생성
          final updatedTravel = currentTravel.copyWith(
            destination: newDestination,
            countryInfos: newCountryInfos,
            startDate: newStartDate,
            endDate: newEndDate,
          );

          // 업데이트 적용
          ref.read(travelsProvider.notifier).updateTravel(updatedTravel);

          // 기존 일정들의 날짜를 새로운 날짜 범위에 맞게 조정
          final schedules = currentTravel.schedules.toList();

          if (schedules.isNotEmpty) {
            final oldDateRange = DateUtil.getAllDates(
                currentTravel.startDate, currentTravel.endDate);
            final newDateRange = DateUtil.getAllDates(newStartDate, newEndDate);

            // 날짜별 국가 정보 백업
            Map<int, String> dayNumberToCountry = {};
            Map<int, String> dayNumberToFlagEmoji = {};
            Map<int, String> dayNumberToCountryCode = {};

            for (final dayData in currentTravel.getAllDaysSorted()) {
              dayNumberToCountry[dayData.dayNumber] = dayData.countryName;
              dayNumberToFlagEmoji[dayData.dayNumber] = dayData.flagEmoji;
              dayNumberToCountryCode[dayData.dayNumber] = dayData.countryCode;
              dev.log(
                  '날짜 편집 - 기존 Day ${dayData.dayNumber} 국가 정보 백업: ${dayData.countryName}');
            }

            // 각 일정 업데이트
            for (final schedule in schedules) {
              final oldIndex = oldDateRange.indexWhere((date) =>
                  date.year == schedule.date.year &&
                  date.month == schedule.date.month &&
                  date.day == schedule.date.day);

              if (oldIndex >= 0 && oldIndex < newDateRange.length) {
                // Day 번호에 해당하는 국가 정보도 함께 유지
                final dayNumber = oldIndex + 1;
                final country = dayNumberToCountry[dayNumber];
                final flagEmoji = dayNumberToFlagEmoji[dayNumber];
                final countryCode = dayNumberToCountryCode[dayNumber] ?? '';

                if (country != null && flagEmoji != null) {
                  // 날짜 변경 시 국가 정보도 함께 유지
                  final date = newDateRange[oldIndex];
                  ref.read(travelsProvider.notifier).setCountryForDate(
                      currentTravel.id, date, country, flagEmoji, countryCode);
                  dev.log(
                      '날짜 편집 - Day $dayNumber 국가 정보 유지: $country, 코드: $countryCode');
                }

                // 새 일정 객체 생성
                final updatedSchedule = schedule.copyWith(
                  date: newDateRange[oldIndex],
                  dayNumber: oldIndex + 1,
                );

                // 일정 업데이트
                ref.read(travelsProvider.notifier).updateSchedule(
                      currentTravel.id,
                      updatedSchedule,
                    );
              }
            }
          }
        }
      } else {
        // 날짜 변경이 없는 경우 목적지만 업데이트
        final updatedTravel = currentTravel.copyWith(
          destination: newDestination,
          countryInfos: newCountryInfos,
        );

        ref.read(travelsProvider.notifier).updateTravel(updatedTravel);
      }
    }
  }

  // 삭제된 국가를 사용 중인 날짜들의 국가 정보 초기화
  static void _resetCountryInfoForRemovedDestinations(
      WidgetRef ref,
      TravelModel travel,
      List<String> removedDestinations,
      List<String> newDestinations) {
    dev.log('_resetCountryInfoForRemovedDestinations - 실행');
    dev.log('삭제된 국가 목록: $removedDestinations');
    dev.log('새 국가 목록: $newDestinations');

    // dayDataMap이 비어있으면 초기 구성
    if (travel.dayDataMap.isEmpty &&
        travel.startDate != null &&
        travel.endDate != null) {
      dev.log('dayDataMap이 비어있어 초기 구성을 시도합니다.');

      // 여행 날짜들 계산
      final allDates = DateUtil.getAllDates(travel.startDate!, travel.endDate!);
      String defaultCountry =
          newDestinations.isNotEmpty ? newDestinations.first : '';
      String defaultEmoji = '🏳️';
      String defaultCountryCode = '';

      if (defaultCountry.isNotEmpty) {
        // 기본 국가의 이모지 찾기
        final countryInfo = travel.countryInfos.firstWhere(
          (info) => info.name == defaultCountry,
          orElse: () => CountryInfo(
              name: defaultCountry, countryCode: '', flagEmoji: '🏳️'),
        );
        defaultEmoji = countryInfo.flagEmoji;
        defaultCountryCode = countryInfo.countryCode;
      }

      // 모든 날짜에 대해 초기 국가 정보 설정
      for (int i = 0; i < allDates.length; i++) {
        final date = allDates[i];
        final dayNumber = i + 1;

        dev.log(
            '날짜 $date (Day $dayNumber)에 대해 기본 국가 정보 설정: $defaultCountry $defaultEmoji $defaultCountryCode');

        ref.read(travelsProvider.notifier).setCountryForDate(
            travel.id, date, defaultCountry, defaultEmoji, defaultCountryCode);
      }

      // 초기 설정 후 바로 반환
      return;
    }

    // 새로운 dayDataMap 생성
    final updatedDayDataMap = Map<String, DayData>.from(travel.dayDataMap);
    bool hasChanges = false;

    // 모든 날짜 확인
    updatedDayDataMap.forEach((dateKey, dayData) {
      // null 체크 추가
      if (removedDestinations.contains(dayData.countryName)) {
        dev.log('국가 초기화 - 날짜 $dateKey의 국가 ${dayData.countryName}이 삭제됨');

        // 새 국가 정보 설정 (기본값은 첫 번째 목적지 또는 빈 값)
        String newCountryName =
            newDestinations.isNotEmpty ? newDestinations.first : '';
        String newFlagEmoji = '🏳️';
        String newCountryCode = '';

        // 새 국가에 해당하는 국기 이모지 찾기
        if (newCountryName.isNotEmpty) {
          final countryInfo = travel.countryInfos.firstWhere(
            (info) => info.name == newCountryName,
            orElse: () => CountryInfo(
                name: newCountryName, countryCode: '', flagEmoji: '🏳️'),
          );
          newFlagEmoji = countryInfo.flagEmoji;
          newCountryCode = countryInfo.countryCode;
          dev.log(
              '새 국가 정보의 이모지 확인: $newCountryName -> $newFlagEmoji, 코드: $newCountryCode');
        }

        // 해당 날짜의 DayData 업데이트 (국가 정보만 변경)
        updatedDayDataMap[dateKey] = dayData.copyWith(
          countryName: newCountryName,
          flagEmoji: newFlagEmoji,
          countryCode: newCountryCode,
        );

        dev.log(
            '국가 초기화 - 날짜 $dateKey의 국가 정보 변경: $newCountryName $newFlagEmoji $newCountryCode');
        hasChanges = true;
      }
    });

    // 변경 사항이 있는 경우에만 업데이트
    if (hasChanges) {
      final updatedTravel = travel.copyWith(
        dayDataMap: updatedDayDataMap,
      );

      ref.read(travelsProvider.notifier).updateTravel(updatedTravel);
      dev.log('국가 초기화 - 모든 관련 날짜의 국가 정보 초기화 완료');
    }
  }
}
