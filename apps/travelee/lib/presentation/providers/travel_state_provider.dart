import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travelee/data/models/travel/travel_model.dart';
import 'package:travelee/data/models/schedule/schedule.dart';
import 'package:travelee/data/services/database_helper.dart';
import 'package:travelee/core/utils/travel_date_formatter.dart';
import 'dart:developer' as dev;
import 'package:travelee/data/managers/change_manager.dart';

// 현재 선택된 여행 ID
final currentTravelIdProvider = StateProvider<String>((ref) => '');

// 여행 데이터 관리 Notifier
class TravelNotifier extends StateNotifier<List<TravelModel>> {
  TravelNotifier(this.ref) : super([]) {
    // 데이터베이스에서 여행 데이터 로드
    final databaseHelper = ref.read(databaseHelperProvider);
    databaseHelper.loadAllTravels().then((travels) {
      state = travels;
      dev.log('TravelNotifier - 데이터베이스에서 여행 데이터 로드 완료: ${travels.length}개');
    });
  }
  final Ref ref;

  // 임시 편집 상태 관리
  List<TravelModel> _originalState = [];
  bool _isEditing = false;

  // 임시 편집 시작
  void startTempEditing() {
    if (!_isEditing) {
      _originalState = List.from(state);
      _isEditing = true;
      dev.log('TravelNotifier - 임시 편집 모드 시작');
    }
  }

  // 변경사항 확정 및 데이터베이스 저장
  void commitChanges() {
    if (_isEditing) {
      // 변경 사항 확정
      _originalState = List.from(state);
      _isEditing = false;

      // 변경된 여행 데이터만 데이터베이스에 저장
      // final changedTravels = state.where((travel) {
      //   final originalTravel = _originalState.firstWhere(
      //     (original) => original.id == travel.id,
      //     orElse: () => travel,
      //   );
      //   return travel != originalTravel;
      // }).toList();

      // // 변경된 여행만 저장
      // for (final travel in changedTravels) {
      //   ref.read(databaseHelperProvider).saveTravel(travel);
      // }
      // dev.log('TravelNotifier - 변경 사항 확정 완료 (${changedTravels.length}개 여행 저장)');
    }
  }


  // 임시 여행 영구 저장 (temp_ 접두사 제거)
  String? saveTempTravel(String currentTravelId) {
    // 임시 여행인지 확인
    if (!currentTravelId.startsWith('temp_')) {
      dev.log('TravelNotifier - 임시 여행이 아님: $currentTravelId');
      return null;
    }

    try {
      // 현재 여행 찾기
      final travelIndex =
          state.indexWhere((travel) => travel.id == currentTravelId);
      if (travelIndex == -1) {
        dev.log('TravelNotifier - 저장할 임시 여행을 찾을 수 없음: $currentTravelId');
        return null;
      }

      // 현재 여행 정보 가져오기
      final tempTravel = state[travelIndex];

      // 새 고유 ID 생성 (타임스탬프 기반)
      final newId = 'travel_${DateTime.now().millisecondsSinceEpoch}';
      dev.log('TravelNotifier - 임시 여행 ID 변경: $currentTravelId -> $newId');

      // 새 ID로 여행 정보 업데이트
      final updatedTravel = tempTravel.copyWith(id: newId);

      // 스케줄의 travelId도 함께 업데이트
      final updatedSchedules = updatedTravel.schedules.map((schedule) {
        return schedule.copyWith(travelId: newId);
      }).toList();

      // 최종 업데이트된 여행 생성
      final finalTravel = updatedTravel.copyWith(schedules: updatedSchedules);

      // 데이터 베이스 여행 저장
      ref.read(databaseHelperProvider).saveTravel(finalTravel);

      // 상태 업데이트
      state = state.map((travel) {
        if (travel.id == currentTravelId) {
          return finalTravel;
        }
        return travel;
      }).toList();

      // 현재 여행 ID 업데이트

      dev.log('TravelNotifier - 임시 여행을 영구 저장함: $newId');

      // 변경 사항 확정도 함께 호출
      _originalState = List.from(state);
      _isEditing = false;

      return newId;
    } catch (e) {
      dev.log('TravelNotifier - 임시 여행 저장 중 오류 발생: $e');
      return null;
    }
  }

  // 변경사항 취소
  void rollbackChanges() {
    if (_isEditing) {
      state = List.from(_originalState);
      _isEditing = false;
      dev.log('TravelNotifier - 변경 사항 롤백');
    }
  }

  // 변경 사항 여부 확인
  bool hasChanges() {
    if (!_isEditing) return false;

    // 여행 수가 다르면 변경 있음
    if (_originalState.length != state.length) return true;

    // 각 여행별로 일정 수 비교
    for (int i = 0; i < state.length; i++) {
      if (i >= _originalState.length) return true;

      // 같은 인덱스의 여행이라도 ID가 다르면 변경 있음
      if (state[i].id != _originalState[i].id) return true;

      // 일정 수가 다르면 변경 있음
      if (state[i].schedules.length != _originalState[i].schedules.length)
        return true;
    }

    return false;
  }

  // 새 여행 추가
  void addTravel(TravelModel travel) {
    state = [...state, travel];
    dev.log('TravelNotifier - 새 여행 추가: ${travel.id}');
  }

  // 여행 정보 업데이트
  void updateTravel(TravelModel updatedTravel) {
    state = state.map((travel) {
      return travel.id == updatedTravel.id ? updatedTravel : travel;
    }).toList();

    // 로깅 추가
    dev.log('TravelNotifier - 여행 정보 업데이트: ${updatedTravel.id}');

    // 현재 여행 ID가 업데이트된 여행 ID와 같으면 변경 플래그 설정
    final currentTravelId = ref.read(currentTravelIdProvider);
    if (currentTravelId == updatedTravel.id) {
      ref.read(travelChangesProvider.notifier).state = true;

      // ChangeManager에 변경 기록
      ref.read(changeManagerProvider).recordChange();
    }
  }

  // 여행 삭제
  void removeTravel(String travelId) {
    state = state.where((travel) => travel.id != travelId).toList();
    dev.log('TravelNotifier - 여행 삭제: $travelId');

    // 데이터 베이스 여행 저장
    ref.read(databaseHelperProvider).deleteTravel(travelId);
  }

  // 특정 여행 가져오기
  TravelModel? getTravel(String travelId) {
    try {
      return state.firstWhere((travel) => travel.id == travelId);
    } catch (_) {
      dev.log('TravelNotifier - 여행을 찾을 수 없음: $travelId');
      return null;
    }
  }

  // 일정 추가
  void addSchedule(String travelId, Schedule schedule) {
    final travel = getTravel(travelId);
    if (travel == null) {
      dev.log('TravelNotifier - 일정 추가 실패: 여행을 찾을 수 없음 ($travelId)');
      return;
    }

    final updatedTravel = travel.addSchedule(schedule);
    updateTravel(updatedTravel);
    dev.log('TravelNotifier - 일정 추가: ${schedule.id} (여행: $travelId)');
  }

  // 일정 수정
  void updateSchedule(String travelId, Schedule updatedSchedule) {
    final travel = getTravel(travelId);
    if (travel == null) {
      dev.log('TravelNotifier - 일정 수정 실패: 여행을 찾을 수 없음 ($travelId)');
      return;
    }

    final updatedTravel = travel.updateSchedule(updatedSchedule);
    updateTravel(updatedTravel);
    dev.log('TravelNotifier - 일정 수정: ${updatedSchedule.id} (여행: $travelId)');
  }

  // 일정 삭제
  void removeSchedule(String travelId, String scheduleId) {
    final travel = getTravel(travelId);
    if (travel == null) {
      dev.log('TravelNotifier - 일정 삭제 실패: 여행을 찾을 수 없음 ($travelId)');
      return;
    }

    final updatedTravel = travel.removeSchedule(scheduleId);
    updateTravel(updatedTravel);
    dev.log('TravelNotifier - 일정 삭제: $scheduleId (여행: $travelId)');
  }

  // 특정 날짜의 국가 정보 설정
  void setCountryForDate(
      String travelId, DateTime date, String countryName, String flagEmoji,
      [String countryCode = '']) {
    final travel = getTravel(travelId);
    if (travel == null) {
      dev.log('TravelNotifier - setCountryForDate 실패: 여행을 찾을 수 없음 ($travelId)');
      return;
    }

    dev.log(
        'TravelNotifier - setCountryForDate 호출: $countryName, $flagEmoji, 국가코드: $countryCode, 날짜: ${date.toString()}');

    // 임시 편집 모드 시작
    startTempEditing();

    final dateKey = TravelDateFormatter.formatDate(date);

    // 기존 DayData 확인
    final existingDayData = travel.dayDataMap[dateKey];
    bool isDifferent = true;

    // 변경사항이 있는지 확인
    if (existingDayData != null) {
      isDifferent = _isDayDataDifferent(
          existingDayData.countryName,
          existingDayData.flagEmoji,
          existingDayData.countryCode,
          countryName,
          flagEmoji,
          countryCode);
    }

    // 변경사항이 없으면 스킵
    if (!isDifferent) {
      dev.log(
          'TravelNotifier - 국가 정보 업데이트 스킵 (변경 없음): $countryName, $flagEmoji, $countryCode');
      return;
    }

    // 국가 정보 업데이트
    final updatedTravel =
        travel.setCountryForDate(date, countryName, flagEmoji, countryCode);
    updateTravel(updatedTravel);
    dev.log(
        'TravelNotifier - 국가 정보 업데이트 완료: $countryName, $flagEmoji, $countryCode (날짜: $dateKey)');
  }

  // DayData 변경 여부 확인
  bool _isDayDataDifferent(String oldCountry, String oldFlag, String oldCode,
      String newCountry, String newFlag, String newCode) {
    return oldCountry != newCountry || oldFlag != newFlag || oldCode != newCode;
  }

  // 날짜가 몇 번째 날인지 계산하는 헬퍼 메서드
  int _calculateDayNumber(DateTime startDate, DateTime date) {
    return DateTime(date.year, date.month, date.day)
            .difference(
                DateTime(startDate.year, startDate.month, startDate.day))
            .inDays +
        1;
  }

  // 모든 여행 데이터 설정 (데이터 로드 시)
  void setTravels(List<TravelModel> travels) {
    state = travels;
    _originalState = List.from(travels);
    _isEditing = false;
    dev.log('TravelNotifier - 모든 여행 데이터 설정 (${travels.length}개)');
  }

  /// 특정 날짜의 모든 일정 삭제
  void removeAllSchedulesForDate(String travelId, DateTime date) {
    dev.log('특정 날짜의 모든 일정 삭제 시작: $travelId, ${date.toString()}');

    // 여행 ID 유효성 검사
    if (travelId.isEmpty) {
      dev.log('오류: 여행 ID가 비어 있습니다.');
      return;
    }

    // 해당 여행 찾기
    final travelIndex = state.indexWhere((travel) => travel.id == travelId);
    if (travelIndex == -1) {
      dev.log('오류: 해당 ID의 여행을 찾을 수 없습니다: $travelId');
      return;
    }

    // 해당 날짜의 일정만 필터링하여 제거
    final travel = state[travelIndex];
    final filteredSchedules = travel.schedules
        .where((schedule) =>
            schedule.date.year != date.year ||
            schedule.date.month != date.month ||
            schedule.date.day != date.day)
        .toList();

    // 삭제된 일정 수 계산
    final removedCount = travel.schedules.length - filteredSchedules.length;

    // 새 여행 객체 생성 (불변성 유지)
    final updatedTravel = travel.copyWith(schedules: filteredSchedules);

    // 상태 업데이트
    state = [
      ...state.sublist(0, travelIndex),
      updatedTravel,
      ...state.sublist(travelIndex + 1),
    ];

    dev.log('특정 날짜의 일정 삭제 완료: $removedCount개 일정 삭제됨');
  }
}

// 여행 목록 Provider
final travelsProvider =
    StateNotifierProvider<TravelNotifier, List<TravelModel>>((ref) {
  return TravelNotifier(ref);
});

// 현재 선택된 여행 Provider
final currentTravelProvider = Provider<TravelModel?>((ref) {
  final currentId = ref.watch(currentTravelIdProvider);
  if (currentId.isEmpty) return null;

  final travels = ref.watch(travelsProvider);

  try {
    return travels.firstWhere((travel) => travel.id == currentId);
  } catch (_) {
    dev.log('currentTravelProvider - 현재 여행을 찾을 수 없음: $currentId');
    return null;
  }
});

// 날짜별 일정 Provider
final dateSchedulesProvider =
    Provider.family<List<Schedule>, DateTime>((ref, date) {
  final travel = ref.watch(currentTravelProvider);
  if (travel == null) return [];

  final standardDate = DateTime(date.year, date.month, date.day);
  return travel.schedules
      .where((s) =>
          s.date.year == standardDate.year &&
          s.date.month == standardDate.month &&
          s.date.day == standardDate.day)
      .toList();
});

// 특정 날짜의 DayData Provider
final dayDataProvider = Provider.family<DayData?, DateTime>((ref, date) {
  final travel = ref.watch(currentTravelProvider);
  if (travel == null) return null;

  final standardDate = DateTime(date.year, date.month, date.day);
  final dateKey =
      '${standardDate.year}-${standardDate.month.toString().padLeft(2, '0')}-${standardDate.day.toString().padLeft(2, '0')}';

  dev.log(
      'dayDataProvider - 날짜 키: $dateKey, 존재 여부: ${travel.dayDataMap.containsKey(dateKey)}');

  // dayDataMap에서 데이터 찾기
  if (travel.dayDataMap.containsKey(dateKey)) {
    final data = travel.dayDataMap[dateKey];
    dev.log(
        'dayDataProvider - 찾은 데이터: ${data?.countryName}, ${data?.flagEmoji}');
    return data;
  }

  // 데이터가 없으면 기본 값 반환
  dev.log('dayDataProvider - 데이터 없음: $dateKey');
  return null;
});

// 날짜별 선택된 국가 Provider (기존 selectedCountryProvider 대체)
final selectedDateCountryProvider =
    Provider.family<String?, DateTime>((ref, date) {
  final dayData = ref.watch(dayDataProvider(date));
  if (dayData == null || dayData.countryName.isEmpty) {
    final currentTravel = ref.watch(currentTravelProvider);
    if (currentTravel == null || currentTravel.destination.isEmpty) return null;
    return currentTravel.destination.first;
  }

  return dayData.countryName;
});

// 이전 버전과의 호환성을 위해 유지하는 Provider (날짜키 포맷: travelId_yyyy-MM-dd)
final selectedCountryProvider =
    Provider.family<String?, String>((ref, dateKey) {
  // dateKey에서 날짜 정보 추출 (형식: travelId_yyyy-MM-dd)
  try {
    final parts = dateKey.split('_');
    if (parts.length != 2) return null;

    final dateParts = parts[1].split('-');
    if (dateParts.length != 3) return null;

    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);

    final date = DateTime(year, month, day);

    // 날짜 정보로 selectedDateCountryProvider 사용
    return ref.watch(selectedDateCountryProvider(date));
  } catch (e) {
    dev.log('selectedCountryProvider 오류: 잘못된 dateKey 형식 - $dateKey');
    return null;
  }
});

// 여행 데이터 변경 여부 감지 Provider
final travelChangesProvider = StateProvider<bool>((ref) {
  return false;
});

// 여행 백업 Provider
final travelBackupProvider = StateProvider<TravelModel?>((ref) => null);

// 변경 관리자 Provider
final changeManagerProvider = Provider((ref) => ChangeManager());
