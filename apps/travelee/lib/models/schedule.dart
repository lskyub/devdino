import 'package:flutter/material.dart';

class Schedule {
  final String id;
  final String travelId;
  final TimeOfDay time;
  final String location;
  final String memo;
  final DateTime date;
  final int dayNumber;

  Schedule({
    required this.id,
    required this.travelId,
    required this.time,
    required this.location,
    required this.memo,
    required this.date,
    required this.dayNumber,
  });

  Schedule copyWith({
    String? id,
    String? travelId,
    TimeOfDay? time,
    String? location,
    String? memo,
    DateTime? date,
    int? dayNumber,
  }) {
    return Schedule(
      id: id ?? this.id,
      travelId: travelId ?? this.travelId,
      time: time ?? this.time,
      location: location ?? this.location,
      memo: memo ?? this.memo,
      date: date ?? this.date,
      dayNumber: dayNumber ?? this.dayNumber,
    );
  }
  @override
  String toString() {
    return 'id: $id, travelId: $travelId, time: $time, location: $location, memo: $memo, date: $date, dayNumber: $dayNumber';
  }
} 