import 'package:travelee/data/models/schedule/schedule.dart';
import 'package:travelee/data/models/location/country_info.dart';

// 하루 데이터 모델
class DayData {
  final DateTime date; // 날짜
  final String countryName; // 국가명
  final String flagEmoji; // 국기 이모지
  final String countryCode; // 국가 코드
  final int dayNumber; // 여행 몇 일차인지
  final List<Schedule> schedules; // 일정 목록

  DayData({
    required this.date,
    required this.countryName,
    required this.flagEmoji,
    required this.countryCode, // 기본값 빈 문자열
    required this.dayNumber,
    required this.schedules,
  });

  @override
  String toString() =>
      'DayData(date: $date, countryName: $countryName, flagEmoji: $flagEmoji, countryCode: $countryCode, dayNumber: $dayNumber, schedules: $schedules)';

  // 복사본 생성
  DayData copyWith({
    DateTime? date,
    String? countryName,
    String? flagEmoji,
    String? countryCode,
    int? dayNumber,
    List<Schedule>? schedules,
  }) {
    return DayData(
      date: date ?? this.date,
      countryName: countryName ?? this.countryName,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      countryCode: countryCode ?? this.countryCode,
      dayNumber: dayNumber ?? this.dayNumber,
      schedules: schedules ?? this.schedules,
    );
  }

  // 특정 날짜의 국가 정보 업데이트
  DayData updateCountry(String country, String emoji, String code) {
    return copyWith(
      countryName: country,
      flagEmoji: emoji,
      countryCode: code,
    );
  }
}

// 통합 여행 모델
class TravelModel {
  final String id;
  final String title;
  final List<String> destination;
  final List<CountryInfo> countryInfos;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Schedule> schedules;
  final Map<String, DayData> dayDataMap; // 날짜별 데이터 (키: 'yyyy-MM-dd')
  final DateTime createdAt; // 생성 시간
  final DateTime updatedAt; // 업데이트 시간

  TravelModel({
    required this.id,
    required this.title,
    required this.destination,
    required this.countryInfos,
    this.startDate,
    this.endDate,
    required this.schedules,
    required this.dayDataMap,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // 복사본 생성
  TravelModel copyWith({
    String? id,
    String? title,
    List<String>? destination,
    List<CountryInfo>? countryInfos,
    DateTime? startDate,
    DateTime? endDate,
    List<Schedule>? schedules,
    Map<String, DayData>? dayDataMap,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final model = TravelModel(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      countryInfos: countryInfos ?? this.countryInfos,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      schedules: schedules ?? this.schedules,
      dayDataMap: dayDataMap ?? this.dayDataMap,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

    // 날짜가 변경된 경우 일정 재배치
    if (startDate != null || endDate != null) {
      return model._adjustSchedulesForDateChange();
    }

    return model;
  }

  @override
  String toString() =>
      'TravelModel(id: $id, title: $title, destination: $destination, countryInfos: $countryInfos, startDate: $startDate, endDate: $endDate, schedules: $schedules, dayDataMap: $dayDataMap, createdAt: $createdAt, updatedAt: $updatedAt)';

  // 날짜를 일차로 변환
  int _calculateDayNumber(DateTime date) {
    if (startDate == null) return 1;
    return date.difference(startDate!).inDays + 1;
  }

  // 일차를 날짜로 변환
  DateTime _calculateDateFromDayNumber(int dayNumber) {
    if (startDate == null) return DateTime.now();
    return startDate!.add(Duration(days: dayNumber - 1));
  }

  // 일정 추가
  TravelModel addSchedule(Schedule schedule) {
    // 기존 일정 복사
    final newSchedules = List<Schedule>.from(schedules);
    
    // 날짜를 시작일 기준으로 조정
    final adjustedDate = _calculateDateFromDayNumber(schedule.dayNumber);
    final adjustedSchedule = schedule.copyWith(date: adjustedDate);
    newSchedules.add(adjustedSchedule);

    // 해당 일차의 DayData 가져오기
    final dayKey = schedule.dayNumber.toString();
    final existingDayData = dayDataMap[dayKey];

    // 해당 일차의 국가 정보 가져오기 (기본값은 첫 번째 목적지)
    String countryName = destination.isNotEmpty ? destination.first : '';
    String flagEmoji = '🏳️';
    String countryCode = '';

    // 기존 DayData가 있으면 해당 정보 사용
    if (existingDayData != null) {
      countryName = existingDayData.countryName;
      flagEmoji = existingDayData.flagEmoji;
      countryCode = existingDayData.countryCode;
    } else {
      // 국가 정보 찾기
      final countryInfo = getCountryInfo(countryName);
      if (countryInfo != null) {
        flagEmoji = countryInfo.flagEmoji;
        countryCode = countryInfo.countryCode;
      }
    }

    // 해당 일차의 일정 목록 업데이트
    final daySchedules = newSchedules
        .where((s) => s.dayNumber == schedule.dayNumber)
        .toList();

    // 새 DayData 생성
    final newDayData = DayData(
      date: adjustedDate,
      countryName: countryName,
      flagEmoji: flagEmoji,
      countryCode: countryCode,
      dayNumber: schedule.dayNumber,
      schedules: daySchedules,
    );

    // dayDataMap 업데이트
    final newDayDataMap = Map<String, DayData>.from(dayDataMap);
    newDayDataMap[dayKey] = newDayData;

    return copyWith(
      schedules: newSchedules,
      dayDataMap: newDayDataMap,
      updatedAt: DateTime.now(),
    );
  }

  // 일정 수정
  TravelModel updateSchedule(Schedule updatedSchedule) {
    // 기존 일정 중 해당 ID를 가진 일정 찾아 업데이트
    final newSchedules = schedules.map((schedule) {
      if (schedule.id == updatedSchedule.id) {
        // 날짜를 시작일 기준으로 조정
        final adjustedDate = _calculateDateFromDayNumber(updatedSchedule.dayNumber);
        return updatedSchedule.copyWith(date: adjustedDate);
      }
      return schedule;
    }).toList();

    // dayDataMap 재구성
    final newDayDataMap = _rebuildDayDataMap(newSchedules);

    return copyWith(
      schedules: newSchedules,
      dayDataMap: newDayDataMap,
      updatedAt: DateTime.now(),
    );
  }

  // 날짜 변경 시 일정 재배치
  TravelModel _adjustSchedulesForDateChange() {
    if (startDate == null || endDate == null) return this;

    final totalDays = endDate!.difference(startDate!).inDays + 1;
    final newSchedules = schedules.map((schedule) {
      // 일차가 총 일수를 초과하면 마지막 날로 이동
      final adjustedDayNumber = schedule.dayNumber > totalDays 
          ? totalDays 
          : schedule.dayNumber;
      
      // 날짜 재계산
      final adjustedDate = _calculateDateFromDayNumber(adjustedDayNumber);
      
      return schedule.copyWith(
        dayNumber: adjustedDayNumber,
        date: adjustedDate,
      );
    }).toList();

    // dayDataMap 재구성
    final newDayDataMap = _rebuildDayDataMap(newSchedules);

    return copyWith(
      schedules: newSchedules,
      dayDataMap: newDayDataMap,
      updatedAt: DateTime.now(),
    );
  }

  // dayDataMap 재구성
  Map<String, DayData> _rebuildDayDataMap(List<Schedule> schedules) {
    final newDayDataMap = <String, DayData>{};

    // 일차별로 그룹화
    final groupedSchedules = <int, List<Schedule>>{};
    for (final schedule in schedules) {
      groupedSchedules.putIfAbsent(schedule.dayNumber, () => []).add(schedule);
    }

    // 각 일차별 DayData 생성
    for (final entry in groupedSchedules.entries) {
      final dayNumber = entry.key;
      final daySchedules = entry.value;
      final date = _calculateDateFromDayNumber(dayNumber);

      // 국가 정보 설정 (기존 정보 유지 또는 새로 설정)
      final existingDayData = dayDataMap[dayNumber.toString()];
      String countryName = existingDayData?.countryName ?? 
          (destination.isNotEmpty ? destination.first : '');
      String flagEmoji = existingDayData?.flagEmoji ?? '🏳️';
      String countryCode = existingDayData?.countryCode ?? '';

      if (existingDayData == null) {
        final countryInfo = getCountryInfo(countryName);
        if (countryInfo != null) {
          flagEmoji = countryInfo.flagEmoji;
          countryCode = countryInfo.countryCode;
        }
      }

      newDayDataMap[dayNumber.toString()] = DayData(
        date: date,
        countryName: countryName,
        flagEmoji: flagEmoji,
        countryCode: countryCode,
        dayNumber: dayNumber,
        schedules: daySchedules,
      );
    }

    return newDayDataMap;
  }

  // 빈 여행 객체 생성
  factory TravelModel.empty() {
    return TravelModel(
      id: '',
      title: '',
      destination: [],
      countryInfos: [],
      schedules: [],
      dayDataMap: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 모든 날짜 데이터를 날짜순으로 정렬하여 반환
  List<DayData> getAllDaysSorted() {
    final sortedDays = dayDataMap.values.toList();
    sortedDays.sort((a, b) => a.date.compareTo(b.date));
    return sortedDays;
  }

  // 두 TravelModel 객체의 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TravelModel) return false;

    return id == other.id &&
        title == other.title &&
        _listEquals(destination, other.destination) &&
        _listEquals(countryInfos, other.countryInfos) &&
        _areDatesEqual(startDate, other.startDate) &&
        _areDatesEqual(endDate, other.endDate) &&
        _listEquals(schedules, other.schedules) &&
        _mapEquals(dayDataMap, other.dayDataMap) &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      Object.hashAll(destination),
      Object.hashAll(countryInfos),
      startDate,
      endDate,
      Object.hashAll(schedules),
      Object.hashAll(dayDataMap.entries),
      createdAt,
      updatedAt,
    );
  }

  // 리스트 동등성 비교 헬퍼
  bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  // 맵 동등성 비교 헬퍼
  bool _mapEquals(Map<String, DayData> map1, Map<String, DayData> map2) {
    if (map1.length != map2.length) return false;
    return map1.entries
        .every((e) => map2.containsKey(e.key) && map2[e.key] == e.value);
  }

  // 날짜 동등성 비교 헬퍼
  bool _areDatesEqual(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return true;
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 국가 정보 가져오기
  CountryInfo? getCountryInfo(String countryName) {
    try {
      return countryInfos.firstWhere((info) => info.name == countryName);
    } catch (_) {
      return null;
    }
  }

  // 날짜에 해당하는 DayData 가져오기
  DayData? getDayData(DateTime date) {
    final dateKey = _calculateDayNumber(date).toString();
    return dayDataMap[dateKey];
  }

  // 특정 날짜의 국가 정보 설정
  TravelModel setCountryForDate(
    DateTime date,
    String countryName,
    String flagEmoji,
    String countryCode,
  ) {
    final dayNumber = _calculateDayNumber(date);
    final dayKey = dayNumber.toString();
    final newDayDataMap = Map<String, DayData>.from(dayDataMap);

    if (newDayDataMap.containsKey(dayKey)) {
      newDayDataMap[dayKey] = newDayDataMap[dayKey]!.updateCountry(
        countryName,
        flagEmoji,
        countryCode,
      );
    } else {
      newDayDataMap[dayKey] = DayData(
        date: date,
        countryName: countryName,
        flagEmoji: flagEmoji,
        countryCode: countryCode,
        dayNumber: dayNumber,
        schedules: [],
      );
    }

    return copyWith(
      dayDataMap: newDayDataMap,
      updatedAt: DateTime.now(),
    );
  }

  // 일정 삭제
  TravelModel removeSchedule(String scheduleId) {
    // 해당 일정 찾기
    final scheduleToRemove = schedules.firstWhere(
      (schedule) => schedule.id == scheduleId,
      orElse: () => throw Exception('Schedule not found: $scheduleId'),
    );

    // 일정 목록에서 제거
    final newSchedules = schedules.where((s) => s.id != scheduleId).toList();

    // dayDataMap 재구성
    final newDayDataMap = _rebuildDayDataMap(newSchedules);

    return copyWith(
      schedules: newSchedules,
      dayDataMap: newDayDataMap,
      updatedAt: DateTime.now(),
    );
  }
}
