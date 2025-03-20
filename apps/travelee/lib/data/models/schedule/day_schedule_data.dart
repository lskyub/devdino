import 'package:travelee/data/models/schedule/schedule.dart';

class DayScheduleData {
  final DateTime date;
  final String countryName; // 국가 이름
  final String flagEmoji; // 국가 플래그 이모지
  final String countryCode; // 국가 코드
  final int dayNumber; // Day 1, Day 2 등의 표시를 위한 번호
  final List<Schedule> schedules; // 시간별 일정 데이터
  
  DayScheduleData({
    required this.date,
    required this.countryName,
    required this.flagEmoji,
    required this.countryCode, // 기본값 빈 문자열
    required this.dayNumber,
    required this.schedules,
  });

  // 편집을 위한 복사본 생성 메서드
  DayScheduleData copyWith({
    DateTime? date,
    String? countryName,
    String? flagEmoji,
    String? countryCode,
    int? dayNumber,
    List<Schedule>? schedules,
  }) {
    return DayScheduleData(
      date: date ?? this.date,
      countryName: countryName ?? this.countryName,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      countryCode: countryCode ?? this.countryCode,
      dayNumber: dayNumber ?? this.dayNumber,
      schedules: schedules ?? this.schedules,
    );
  }
} 