import 'package:flutter/material.dart';
import 'package:travelee/data/models/schedule/schedule.dart';

class ScheduleDBModel {
  final String id;
  final String travelId;
  final String date; // ISO8601 문자열
  final int timeHour;
  final int timeMinute;
  final String location;
  final String memo;
  final int dayNumber;
  final double? latitude;
  final double? longitude;

  ScheduleDBModel({
    required this.id,
    required this.travelId,
    required this.date,
    required this.timeHour,
    required this.timeMinute,
    required this.location,
    this.memo = '',
    required this.dayNumber,
    this.latitude,
    this.longitude,
  });

  // UI 모델에서 DB 모델로 변환
  factory ScheduleDBModel.fromSchedule(Schedule schedule) {
    return ScheduleDBModel(
      id: schedule.id,
      travelId: schedule.travelId,
      date: schedule.date.toIso8601String(),
      timeHour: schedule.time.hour,
      timeMinute: schedule.time.minute,
      location: schedule.location,
      memo: schedule.memo,
      dayNumber: schedule.dayNumber,
      latitude: schedule.latitude,
      longitude: schedule.longitude,
    );
  }

  // DB 모델에서 UI 모델로 변환
  Schedule toSchedule() {
    return Schedule(
      id: id,
      travelId: travelId,
      date: DateTime.parse(date),
      time: TimeOfDay(hour: timeHour, minute: timeMinute),
      location: location,
      memo: memo,
      dayNumber: dayNumber,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // 데이터베이스용 맵으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'travel_id': travelId,
      'date': date,
      'time_hour': timeHour,
      'time_minute': timeMinute,
      'location': location,
      'memo': memo,
      'day_number': dayNumber,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // 데이터베이스 맵에서 객체 생성
  factory ScheduleDBModel.fromMap(Map<String, dynamic> map) {
    return ScheduleDBModel(
      id: map['id'] as String,
      travelId: map['travel_id'] as String,
      date: map['date'] as String,
      timeHour: map['time_hour'] as int,
      timeMinute: map['time_minute'] as int,
      location: map['location'] as String,
      memo: map['memo'] as String? ?? '',
      dayNumber: map['day_number'] as int,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
    );
  }

  @override
  String toString() {
    return 'ScheduleDBModel{id: $id, travelId: $travelId, date: $date, location: $location, memo: $memo, dayNumber: $dayNumber, latitude: $latitude, longitude: $longitude}';
  }
} 