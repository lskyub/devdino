import 'package:travelee/models/schedule.dart';
import 'package:travelee/models/country_info.dart';

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
  String toString() => 'DayData(date: $date, countryName: $countryName, flagEmoji: $flagEmoji, countryCode: $countryCode, dayNumber: $dayNumber, schedules: $schedules)';
  
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
  }) : this.createdAt = createdAt ?? DateTime.now(),
       this.updatedAt = updatedAt ?? DateTime.now();
  
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
    return TravelModel(
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
  }
  
  @override
  String toString() => 'TravelModel(id: $id, title: $title, destination: $destination, countryInfos: $countryInfos, startDate: $startDate, endDate: $endDate, schedules: $schedules, dayDataMap: $dayDataMap, createdAt: $createdAt, updatedAt: $updatedAt)';
  
  // 일정 추가
  TravelModel addSchedule(Schedule schedule) {
    // 기존 일정 복사
    final newSchedules = List<Schedule>.from(schedules);
    newSchedules.add(schedule);
    
    // 날짜 키 생성
    final dateKey = _getDateKey(schedule.date);
    
    // 해당 날짜의 DayData 가져오기
    final existingDayData = dayDataMap[dateKey];
    final dayNumber = _calculateDayNumber(schedule.date);
    
    // 해당 날짜의 국가 정보 가져오기 (기본값은 첫 번째 목적지)
    String countryName = destination.isNotEmpty ? destination.first : '';
    String flagEmoji = '🏳️';
    String countryCode = '';
    
    // 기존 DayData가 있으면 해당 정보 사용
    if (existingDayData != null) {
      countryName = existingDayData.countryName.isNotEmpty 
          ? existingDayData.countryName 
          : countryName;
      flagEmoji = existingDayData.flagEmoji.isNotEmpty 
          ? existingDayData.flagEmoji 
          : flagEmoji;
      countryCode = existingDayData.countryCode;
    } else {
      // 국가 정보 찾기
      final countryInfo = getCountryInfo(countryName);
      if (countryInfo != null) {
        flagEmoji = countryInfo.flagEmoji;
        countryCode = countryInfo.countryCode;
      }
    }
    
    // 해당 날짜의 일정 목록 업데이트
    final dateSchedules = newSchedules
        .where((s) => 
            s.travelId == id && 
            s.date.year == schedule.date.year && 
            s.date.month == schedule.date.month && 
            s.date.day == schedule.date.day)
        .toList();
    
    // 새 DayData 생성
    final newDayData = DayData(
      date: schedule.date,
      countryName: countryName,
      flagEmoji: flagEmoji,
      countryCode: countryCode,
      dayNumber: dayNumber,
      schedules: dateSchedules,
    );
    
    // dayDataMap 업데이트
    final newDayDataMap = Map<String, DayData>.from(dayDataMap);
    newDayDataMap[dateKey] = newDayData;
    
    // 새 TravelModel 반환
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
        return updatedSchedule;
      }
      return schedule;
    }).toList();
    
    // dayDataMap 업데이트 (날짜가 변경될 수 있으므로 모든 데이터 재구성)
    final newDayDataMap = _rebuildDayDataMap(newSchedules);
    
    // 새 TravelModel 반환
    return copyWith(
      schedules: newSchedules,
      dayDataMap: newDayDataMap,
      updatedAt: DateTime.now(),
    );
  }
  
  // 일정 삭제
  TravelModel removeSchedule(String scheduleId) {
    // 해당 ID를 가진 일정 제외
    final newSchedules = schedules.where((schedule) => schedule.id != scheduleId).toList();
    
    // dayDataMap 업데이트
    final newDayDataMap = _rebuildDayDataMap(newSchedules);
    
    // 새 TravelModel 반환
    return copyWith(
      schedules: newSchedules,
      dayDataMap: newDayDataMap,
      updatedAt: DateTime.now(),
    );
  }
  
  // 날짜의 국가 정보 설정
  TravelModel setCountryForDate(DateTime date, String country, String flagEmoji, String countryCode) {
    final dateKey = _getDateKey(date);
    final existingDayData = dayDataMap[dateKey];
    final dayNumber = _calculateDayNumber(date);
    
    // 디버깅 로그 추가
    print('TravelModel.setCountryForDate - dateKey: $dateKey, existingDayData: $existingDayData, country: $country');
    print('TravelModel.setCountryForDate - dayDataMap 기존 키: ${dayDataMap.keys.join(', ')}');
    
    // 해당 날짜의 일정 목록
    final dateSchedules = schedules
        .where((s) => 
            s.travelId == id && 
            s.date.year == date.year && 
            s.date.month == date.month && 
            s.date.day == date.day)
        .toList();
    
    // 새 DayData 생성
    final newDayData = DayData(
      date: date,
      countryName: country,
      flagEmoji: flagEmoji,
      countryCode: countryCode,
      dayNumber: dayNumber,
      schedules: dateSchedules,
    );
    
    // dayDataMap 업데이트
    final newDayDataMap = Map<String, DayData>.from(dayDataMap);
    newDayDataMap[dateKey] = newDayData;
    
    print('TravelModel.setCountryForDate - dayDataMap 업데이트 후 키: ${newDayDataMap.keys.join(', ')}');
    print('TravelModel.setCountryForDate - 업데이트된 DayData: ${newDayData.countryName}, ${newDayData.flagEmoji}');
    
    // 새 TravelModel 반환
    return copyWith(
      dayDataMap: newDayDataMap,
      updatedAt: DateTime.now(),
    );
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
    final dateKey = _getDateKey(date);
    return dayDataMap[dateKey];
  }
  
  // 날짜 키 생성 (yyyy-MM-dd 형식)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  // 여행 시작일 기준 일차 계산
  int _calculateDayNumber(DateTime date) {
    if (startDate == null) return 1;
    
    // 시작일과의 차이 계산 (일 단위)
    return date.difference(startDate!).inDays + 1;
  }
  
  // 모든 날짜에 대한 DayData 재구성
  Map<String, DayData> _rebuildDayDataMap(List<Schedule> scheduleList) {
    final Map<String, DayData> newMap = {};
    
    // 1. 먼저 기존 dayDataMap을 복사하여 국가 정보를 보존
    final Map<String, DayData> preservedCountryMap = {};
    for (final entry in dayDataMap.entries) {
      final dateKey = entry.key;
      final dayData = entry.value;
      
      // 국가 정보가 있는 경우에만 보존
      if (dayData.countryName.isNotEmpty) {
        preservedCountryMap[dateKey] = DayData(
          date: dayData.date,
          countryName: dayData.countryName,
          flagEmoji: dayData.flagEmoji,
          countryCode: dayData.countryCode,
          dayNumber: dayData.dayNumber,
          schedules: [], // 일정은 나중에 업데이트
        );
      }
    }
    
    // 2. 모든 일정의 날짜에 대해 DayData 생성
    for (final schedule in scheduleList) {
      if (schedule.travelId != id) continue; // 다른 여행의 일정은 제외
      
      final dateKey = _getDateKey(schedule.date);
      final dayNumber = _calculateDayNumber(schedule.date);
      
      // 해당 날짜의 모든 일정
      final dateSchedules = scheduleList
          .where((s) => 
              s.travelId == id && 
              s.date.year == schedule.date.year && 
              s.date.month == schedule.date.month && 
              s.date.day == schedule.date.day)
          .toList();
      
      // 국가 정보 (보존된 데이터 또는 기본값)
      String countryName = destination.isNotEmpty ? destination.first : '';
      String flagEmoji = '🏳️';
      String countryCode = '';
      
      // 우선 순위: 1) 보존된 국가 정보, 2) 기존 DayDataMap, 3) 기본값
      if (preservedCountryMap.containsKey(dateKey)) {
        countryName = preservedCountryMap[dateKey]!.countryName;
        flagEmoji = preservedCountryMap[dateKey]!.flagEmoji;
        countryCode = preservedCountryMap[dateKey]!.countryCode;
      } else if (dayDataMap.containsKey(dateKey)) {
        final existingDayData = dayDataMap[dateKey];
        if (existingDayData != null && existingDayData.countryName.isNotEmpty) {
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
      } else {
        // 국가 정보 찾기
        final countryInfo = getCountryInfo(countryName);
        if (countryInfo != null) {
          flagEmoji = countryInfo.flagEmoji;
          countryCode = countryInfo.countryCode;
        }
      }
      
      // 새 DayData 생성
      final newDayData = DayData(
        date: schedule.date,
        countryName: countryName,
        flagEmoji: flagEmoji,
        countryCode: countryCode,
        dayNumber: dayNumber,
        schedules: dateSchedules,
      );
      
      newMap[dateKey] = newDayData;
    }
    
    // 3. 일정이 없는 날짜 데이터도 보존 (여행 기간 내)
    if (startDate != null && endDate != null) {
      for (var day = 0; day <= endDate!.difference(startDate!).inDays; day++) {
        final date = startDate!.add(Duration(days: day));
        final dateKey = _getDateKey(date);
        
        // 이미 추가된 날짜는 스킵
        if (newMap.containsKey(dateKey)) continue;
        
        // 국가 정보 (보존된 데이터 또는 기본값)
        String countryName = destination.isNotEmpty ? destination.first : '';
        String flagEmoji = '🏳️';
        String countryCode = '';
        
        // 우선 순위: 1) 보존된 국가 정보, 2) 기존 DayDataMap, 3) 기본값
        if (preservedCountryMap.containsKey(dateKey)) {
          countryName = preservedCountryMap[dateKey]!.countryName;
          flagEmoji = preservedCountryMap[dateKey]!.flagEmoji;
          countryCode = preservedCountryMap[dateKey]!.countryCode;
        } else if (dayDataMap.containsKey(dateKey)) {
          final existingDayData = dayDataMap[dateKey];
          if (existingDayData != null && existingDayData.countryName.isNotEmpty) {
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
        } else {
          // 국가 정보 찾기
          final countryInfo = getCountryInfo(countryName);
          if (countryInfo != null) {
            flagEmoji = countryInfo.flagEmoji;
            countryCode = countryInfo.countryCode;
          }
        }
        
        // 새 DayData 생성 (빈 일정)
        final dayNumber = day + 1;
        final newDayData = DayData(
          date: date,
          countryName: countryName,
          flagEmoji: flagEmoji,
          countryCode: countryCode,
          dayNumber: dayNumber,
          schedules: [],
        );
        
        newMap[dateKey] = newDayData;
      }
    }
    
    return newMap;
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
} 