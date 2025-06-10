import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:travelee/domain/entities/schedule.dart';
import 'package:travelee/domain/entities/country_info.dart';
import 'package:travelee/domain/entities/travel_model.dart';
import 'package:travelee/data/models/db/schedule_db_model.dart';

class TravelDBModel {
  final String id;
  final String title;
  final String destination; // 콤마로 구분된 문자열
  final String startDate; // ISO8601 문자열
  final String endDate; // ISO8601 문자열
  final String countryInfos; // JSON 문자열
  final String dayDataMap; // JSON 문자열
  final String createdAt; // ISO8601 문자열
  final String updatedAt; // ISO8601 문자열
  final List<ScheduleDBModel> schedules; // 별도 테이블에 저장될 일정 객체들

  TravelDBModel({
    required this.id,
    required this.title,
    required this.destination,
    this.startDate = '',
    this.endDate = '',
    required this.countryInfos,
    required this.dayDataMap,
    required this.createdAt,
    required this.updatedAt,
    this.schedules = const [],
  });

  // UI 모델에서 DB 모델로 변환
  factory TravelDBModel.fromTravelModel(TravelModel model) {
    // 여행 목적지 리스트를 문자열로 변환
    final destinationString = model.destination.isNotEmpty 
        ? model.destination.join(',') 
        : '';
    
    // 국가 정보 리스트를 JSON 문자열로 변환
    final countryInfosJson = model.countryInfos.map((info) => {
      'name': info.name,
      'country_code': info.countryCode,
      'flag_emoji': info.flagEmoji,
    }).toList();
    final countryInfosString = jsonEncode(countryInfosJson);
    
    // DayData 맵을 JSON 문자열로 변환
    final dayDataJson = <String, dynamic>{};
    model.dayDataMap.forEach((date, data) {
      dayDataJson[date] = {
        'date': data.date.toIso8601String(),
        'country_name': data.countryName,
        'flag_emoji': data.flagEmoji,
        'country_code': data.countryCode,
        'day_number': data.dayNumber,
      };
    });
    final dayDataString = jsonEncode(dayDataJson);
    
    // Schedule을 ScheduleDBModel로 변환
    final scheduleDbModels = model.schedules.map((schedule) => 
      ScheduleDBModel.fromSchedule(schedule)
    ).toList();
    
    return TravelDBModel(
      id: model.id,
      title: model.title,
      destination: destinationString,
      startDate: model.startDate?.toIso8601String() ?? '',
      endDate: model.endDate?.toIso8601String() ?? '',
      countryInfos: countryInfosString,
      dayDataMap: dayDataString,
      createdAt: model.createdAt.toIso8601String(),
      updatedAt: model.updatedAt.toIso8601String(),
      schedules: scheduleDbModels,
    );
  }

  // DB 모델에서 UI 모델로 변환 (schedules는 별도로 변환)
  TravelModel toTravelModel() {
    // 여행 목적지 문자열을 리스트로 변환
    final destinationList = destination.isNotEmpty 
        ? destination.split(',') 
        : <String>[];
    
    // 국가 정보 JSON 문자열을 객체 리스트로 변환
    final countryInfosJson = jsonDecode(countryInfos) as List<dynamic>;
    final countryInfosList = countryInfosJson
        .map((infoJson) => CountryInfo(
          name: infoJson['name'] as String,
          countryCode: infoJson['country_code'] as String,
          flagEmoji: infoJson['flag_emoji'] as String,
        ))
        .toList();
    
    // DayData 맵 JSON 문자열을 객체 맵으로 변환
    final dayDataJsonMap = jsonDecode(dayDataMap) as Map<String, dynamic>;
    final dayDataMapResult = <String, DayData>{};
    
    dayDataJsonMap.forEach((date, dataJson) {
      final data = dataJson as Map<String, dynamic>;
      dayDataMapResult[date] = DayData(
        date: DateTime.parse(data['date'] as String),
        countryName: data['country_name'] as String,
        flagEmoji: data['flag_emoji'] as String,
        countryCode: data['country_code'] as String,
        dayNumber: data['day_number'] as int,
        schedules: [], // schedules는 별도로 처리
      );
    });
    
    // 날짜 처리
    DateTime? parsedStartDate;
    if (startDate.isNotEmpty) {
      parsedStartDate = DateTime.parse(startDate);
    }
    
    DateTime? parsedEndDate;
    if (endDate.isNotEmpty) {
      parsedEndDate = DateTime.parse(endDate);
    }
    
    // 생성일, 수정일 파싱
    final parsedCreatedAt = DateTime.parse(createdAt);
    final parsedUpdatedAt = DateTime.parse(updatedAt);
    
    // Schedule DB 모델들을 일반 Schedule 객체로 변환
    final scheduleModels = schedules.isNotEmpty
        ? schedules.map((s) => s.toSchedule()).toList()
        : <Schedule>[];
    
    return TravelModel(
      id: id,
      title: title,
      destination: destinationList,
      startDate: parsedStartDate,
      endDate: parsedEndDate,
      countryInfos: countryInfosList,
      dayDataMap: dayDataMapResult,
      schedules: scheduleModels,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  // 데이터베이스용 맵으로 변환 (schedules 제외)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'start_date': startDate,
      'end_date': endDate,
      'country_infos': countryInfos,
      'day_data_map': dayDataMap,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // 데이터베이스 맵에서 객체 생성 (schedules 제외)
  factory TravelDBModel.fromMap(Map<String, dynamic> map) {
    return TravelDBModel(
      id: map['id'] as String,
      title: map['title'] as String,
      destination: map['destination'] as String,
      startDate: map['start_date'] as String? ?? '',
      endDate: map['end_date'] as String? ?? '',
      countryInfos: map['country_infos'] as String,
      dayDataMap: map['day_data_map'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      schedules: [], // schedules는 별도로 처리
    );
  }

  // 새 여행 생성 (ID 필요)
  factory TravelDBModel.create(String id, String title, List<String> destination, List<CountryInfo> countryInfos) {
    final now = DateTime.now().toIso8601String();
    
    return TravelDBModel(
      id: id,
      title: title,
      destination: destination.join(','),
      countryInfos: jsonEncode(countryInfos.map((info) => {
        'name': info.name,
        'country_code': info.countryCode,
        'flag_emoji': info.flagEmoji,
      }).toList()),
      dayDataMap: '{}',
      createdAt: now,
      updatedAt: now,
      schedules: [],
    );
  }

  @override
  String toString() {
    return 'TravelDBModel{id: $id, title: $title, schedules: ${schedules.length} items}';
  }
} 