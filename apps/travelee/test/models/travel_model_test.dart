import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelee/data/models/travel/travel_model.dart';
import 'package:travelee/data/models/schedule/schedule.dart';
import 'package:travelee/data/models/location/country_info.dart';

void main() {
  group('TravelModel Tests', () {
    late TravelModel travel;
    late DateTime startDate;
    late DateTime endDate;

    setUp(() {
      startDate = DateTime(2024, 3, 1);
      endDate = DateTime(2024, 3, 3);
      travel = TravelModel(
        id: 'test_id',
        title: 'Test Travel',
        destination: ['Japan'],
        countryInfos: [
          CountryInfo(
            name: 'Japan',
            flagEmoji: '🇯🇵',
            countryCode: 'JP',
          ),
        ],
        startDate: startDate,
        endDate: endDate,
        schedules: [],
        dayDataMap: {},
      );
    });

    test('일정 추가 시 올바른 일차로 저장되어야 함', () {
      final schedule = Schedule(
        id: 'schedule1',
        travelId: 'test_id',
        time: const TimeOfDay(hour: 10, minute: 0),
        location: 'Tokyo',
        memo: 'Visit Tokyo Tower',
        date: startDate,
        dayNumber: 1,
      );

      final updatedTravel = travel.addSchedule(schedule);
      expect(updatedTravel.schedules.length, 1);
      expect(updatedTravel.schedules.first.dayNumber, 1);
      expect(updatedTravel.dayDataMap['1']?.schedules.length, 1);
    });

    test('여행 날짜 변경 시 일정의 일차는 유지되어야 함', () {
      // 1일차 일정 추가
      final schedule1 = Schedule(
        id: 'schedule1',
        travelId: 'test_id',
        time: const TimeOfDay(hour: 10, minute: 0),
        location: 'Tokyo',
        memo: 'Visit Tokyo Tower',
        date: startDate,
        dayNumber: 1,
      );

      var updatedTravel = travel.addSchedule(schedule1);

      // 여행 날짜 변경
      final newStartDate = DateTime(2024, 3, 15);
      updatedTravel = updatedTravel.copyWith(
        startDate: newStartDate,
        endDate: newStartDate.add(const Duration(days: 2)),
      );

      // 일정의 일차는 유지되어야 함
      expect(updatedTravel.schedules.first.dayNumber, 1);
      expect(updatedTravel.dayDataMap['1']?.schedules.first.dayNumber, 1);
      // 날짜는 새로운 시작일 기준으로 변경되어야 함
      expect(updatedTravel.dayDataMap['1']?.date, newStartDate);
    });

    test('일차 변경 시 자동으로 일정이 이동되어야 함', () {
      // 3일차 일정 추가
      final schedule = Schedule(
        id: 'schedule1',
        travelId: 'test_id',
        time: const TimeOfDay(hour: 10, minute: 0),
        location: 'Tokyo',
        memo: 'Visit Tokyo Tower',
        date: startDate.add(const Duration(days: 2)),
        dayNumber: 3,
      );

      var updatedTravel = travel.addSchedule(schedule);

      // 여행 종료일을 2일로 변경
      updatedTravel = updatedTravel.copyWith(
        endDate: startDate.add(const Duration(days: 1)),
      );

      // 3일차 일정이 2일차로 이동되어야 함
      expect(updatedTravel.schedules.first.dayNumber, 2);
      expect(updatedTravel.dayDataMap['2']?.schedules.length, 1);
    });
  });
} 