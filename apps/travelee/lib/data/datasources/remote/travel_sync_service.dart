import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelee/domain/entities/travel_model.dart';
import 'package:travelee/domain/entities/schedule.dart';
import 'package:travelee/domain/entities/country_info.dart';

/// 여행 데이터 동기화 서비스
///
/// 주요 기능:
/// 1. 전체 데이터 저장/로드
///    - saveTravel(): 단일 여행 데이터 저장
///    - saveTravels(): 여러 여행 데이터 저장
///    - loadTravel(): 단일 여행 데이터 로드
///    - loadAllTravels(): 모든 여행 데이터 로드
///
/// 2. 부분 업데이트 (데이터 최적화)
///    - updateSchedule(): 일정만 업데이트
///    - updateCountryInfo(): 국가 정보만 업데이트
///
/// 3. 데이터 압축/복원
///    - DateTime -> ISO8601 문자열
///    - TimeOfDay -> "HH:mm" 문자열
///    - 복잡한 객체 -> JSON 문자열
///    - 불필요한 메타데이터 제외
///
/// 사용 예시:
/// ```dart
/// final syncService = TravelSyncService(supabase);
///
/// // 전체 데이터 저장
/// await syncService.saveTravel(travelModel);
///
/// // 일정만 업데이트
/// await syncService.updateSchedule(travelId, newSchedule);
///
/// // 국가 정보만 업데이트
/// await syncService.updateCountryInfo(travelId, date, countryInfo);
/// ```
class TravelSyncService {
  final SupabaseClient _supabase;
  static const String _tableName = 'travels';

  TravelSyncService(this._supabase);

  /// 여행 데이터를 Supabase에 저장
  Future<void> saveTravel(TravelModel travel) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }
      // 압축된 데이터로 변환
      final compressedData = _compressTravel(travel);

      // upsert를 사용하여 기존 데이터가 있으면 업데이트, 없으면 새로 생성
      await _supabase.from(_tableName).upsert({
        'id': travel.id,
        'data': compressedData,
        'updated_at': DateTime.now().toIso8601String(),
        'user_id': user.id,
      });
    } catch (e) {
      print('Error saving travel: $e');
      rethrow;
    }
  }

  /// 여러 여행 데이터를 Supabase에 저장
  Future<void> saveTravels(List<TravelModel> travels) async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not found');
      }

      // 1. 현재 서버의 모든 여행 데이터 ID 목록 가져오기
      final response =
          await _supabase.from(_tableName).select('id').eq('user_id', user.id);

      final serverTravelIds =
          (response as List).map((data) => data['id'] as String).toSet();

      // 2. 로컬 여행 데이터 ID 목록
      final localTravelIds = travels.map((t) => t.id).toSet();

      // 3. 서버에만 있는 데이터 삭제
      final idsToDelete = serverTravelIds.difference(localTravelIds);
      if (idsToDelete.isNotEmpty) {
        await _supabase
            .from(_tableName)
            .delete()
            .inFilter('id', idsToDelete.toList());
      }

      // 4. 로컬 데이터 저장/업데이트
      final compressedData = travels
          .map((travel) => {
                'id': travel.id,
                'data': _compressTravel(travel),
                'updated_at': DateTime.now().toIso8601String(),
                'user_id': user.id,
              })
          .toList();

      if (compressedData.isNotEmpty) {
        await _supabase.from(_tableName).upsert(compressedData);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Supabase에서 여행 데이터 불러오기
  Future<TravelModel?> loadTravel(String travelId) async {
    try {
      final response =
          await _supabase.from(_tableName).select().eq('id', travelId).single();

      return _decompressTravel(response['data']);
    } catch (e) {
      print('Error loading travel: $e');
      rethrow;
    }
  }

  /// Supabase에서 모든 여행 데이터 불러오기
  /// 사용자 기반의 여행 데이터 불러오기
  Future<List<TravelModel>> loadAllTravels() async {
    try {
      final user = _supabase.auth.currentUser;
      print('loadAllTravels user: $user');
      if (user == null) {
        throw Exception('User not found');
      }
      print(user.id);
      final response =
          await _supabase.from(_tableName).select().eq('user_id', user.id);

      return response
          .map<TravelModel>((data) => _decompressTravel(data['data']))
          .toList();
    } catch (e) {
      print('Error loading all travels: $e');
      rethrow;
    }
  }

  /// Supabase에서 사용자의 모든 여행 데이터 삭제
  Future<void> deleteAllTravels() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }
      await _supabase.from(_tableName).delete().eq('user_id', user.id);
    } catch (e) {
      print('Error deleting all travels: $e');
      rethrow;
    }
  }

  /// 사용자 서비스 탈퇴
  Future<void> deleteUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }

      // 1. 사용자의 모든 여행 데이터 삭제
      await _supabase.from(_tableName).delete().eq('user_id', user.id);

      // 2. Edge Function을 호출하여 사용자 삭제
      // 현재 세션의 accessToken(JWT) 가져오기
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No valid session');
      }
      final jwtToken = session.accessToken;

      final response = await _supabase.functions.invoke(
        'delete-user',
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to delete user: ${response.data['error']}');
      }

      // 3. 로컬 세션 종료
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  /// 일정만 업데이트
  Future<void> updateSchedule(String travelId, Schedule schedule) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }
      // 1. 기존 데이터 로드
      final existingTravel = await loadTravel(travelId);
      if (existingTravel == null) throw Exception('Travel not found');

      // 2. 일정 업데이트
      final updatedTravel = existingTravel.updateSchedule(schedule);

      // 3. 변경된 데이터만 저장
      await _supabase.from(_tableName).update({
        'data': {
          'schedules':
              updatedTravel.schedules.map((s) => _compressSchedule(s)).toList(),
          'dayDataMap': updatedTravel.dayDataMap.map(
            (k, v) => MapEntry(k, _compressDayData(v)),
          ),
        },
        'updated_at': DateTime.now().toIso8601String(),
        'user_id': user.id,
      }).eq('id', travelId);
    } catch (e) {
      print('Error updating schedule: $e');
      rethrow;
    }
  }

  /// 국가 정보만 업데이트
  Future<void> updateCountryInfo(
      String travelId, String date, CountryInfo country) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not found');
      }
      final existingTravel = await loadTravel(travelId);
      if (existingTravel == null) throw Exception('Travel not found');

      final updatedTravel = existingTravel.setCountryForDate(
        DateTime.parse(date),
        country.name,
        country.flagEmoji,
        country.countryCode,
      );

      await _supabase.from(_tableName).update({
        'data': {
          'dayDataMap': updatedTravel.dayDataMap.map(
            (k, v) => MapEntry(k, _compressDayData(v)),
          ),
        },
        'updated_at': DateTime.now().toIso8601String(),
        'user_id': user.id,
      }).eq('id', travelId);
    } catch (e) {
      print('Error updating country info: $e');
      rethrow;
    }
  }

  /// 여행 데이터 압축
  Map<String, dynamic> _compressTravel(TravelModel travel) {
    return {
      'id': travel.id,
      'title': travel.title,
      'destination': travel.destination,
      'countryInfos': travel.countryInfos.map((c) => c.toJson()).toList(),
      'startDate': travel.startDate?.toIso8601String(),
      'endDate': travel.endDate?.toIso8601String(),
      'schedules': travel.schedules.map((s) => _compressSchedule(s)).toList(),
      'dayDataMap': travel.dayDataMap.map(
        (k, v) => MapEntry(k, _compressDayData(v)),
      ),
    };
  }

  /// 여행 데이터 복원
  TravelModel _decompressTravel(Map<String, dynamic> data) {
    return TravelModel(
      id: data['id'] as String,
      title: data['title'] as String,
      destination: List<String>.from(data['destination'] as List),
      countryInfos: (data['countryInfos'] as List)
          .map((c) => CountryInfo.fromJson(c as Map<String, dynamic>))
          .toList(),
      startDate: data['startDate'] != null
          ? DateTime.parse(data['startDate'] as String)
          : null,
      endDate: data['endDate'] != null
          ? DateTime.parse(data['endDate'] as String)
          : null,
      schedules: (data['schedules'] as List)
          .map((s) => _decompressSchedule(s as Map<String, dynamic>))
          .toList(),
      dayDataMap: (data['dayDataMap'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, _decompressDayData(v as Map<String, dynamic>)),
      ),
    );
  }

  /// 일정 데이터 압축
  Map<String, dynamic> _compressSchedule(Schedule schedule) {
    return {
      'id': schedule.id,
      'travelId': schedule.travelId,
      'time': '${schedule.time.hour}:${schedule.time.minute}',
      'location': schedule.location,
      'memo': schedule.memo,
      'date': schedule.date.toIso8601String(),
      'dayNumber': schedule.dayNumber,
      'latitude': schedule.latitude,
      'longitude': schedule.longitude,
    };
  }

  /// 일정 데이터 복원
  Schedule _decompressSchedule(Map<String, dynamic> data) {
    final timeParts = (data['time'] as String).split(':');
    return Schedule(
      id: data['id'] as String,
      travelId: data['travelId'] as String,
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      location: data['location'] as String,
      memo: data['memo'] as String,
      date: DateTime.parse(data['date'] as String),
      dayNumber: data['dayNumber'] as int,
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
    );
  }

  /// 일일 데이터 압축
  Map<String, dynamic> _compressDayData(DayData dayData) {
    return {
      'date': dayData.date.toIso8601String(),
      'countryName': dayData.countryName,
      'flagEmoji': dayData.flagEmoji,
      'countryCode': dayData.countryCode,
      'dayNumber': dayData.dayNumber,
      'schedules': dayData.schedules.map((s) => _compressSchedule(s)).toList(),
    };
  }

  /// 일일 데이터 복원
  DayData _decompressDayData(Map<String, dynamic> data) {
    return DayData(
      date: DateTime.parse(data['date'] as String),
      countryName: data['countryName'] as String,
      flagEmoji: data['flagEmoji'] as String,
      countryCode: data['countryCode'] as String,
      dayNumber: data['dayNumber'] as int,
      schedules: (data['schedules'] as List)
          .map((s) => _decompressSchedule(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
