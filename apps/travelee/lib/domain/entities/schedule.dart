import 'package:flutter/material.dart';

class Schedule {
  final String id;
  final String travelId;
  final TimeOfDay time;
  final String location;
  final String memo;
  final DateTime date;
  final int dayNumber;
  final double? latitude;
  final double? longitude;

  Schedule({
    required this.id,
    required this.travelId,
    required this.time,
    required this.location,
    required this.memo,
    required this.date,
    required this.dayNumber,
    this.latitude,
    this.longitude,
  });

  Schedule copyWith({
    String? id,
    String? travelId,
    TimeOfDay? time,
    String? location,
    String? memo,
    DateTime? date,
    int? dayNumber,
    double? latitude,
    double? longitude,
  }) {
    return Schedule(
      id: id ?? this.id,
      travelId: travelId ?? this.travelId,
      time: time ?? this.time,
      location: location ?? this.location,
      memo: memo ?? this.memo,
      date: date ?? this.date,
      dayNumber: dayNumber ?? this.dayNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
  @override
  String toString() {
    return 'id: $id, travelId: $travelId, time: $time, location: $location, memo: $memo, date: $date, dayNumber: $dayNumber';
  }
} 