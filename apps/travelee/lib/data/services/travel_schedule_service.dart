import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../core/utils/log_util.dart';

class TravelScheduleService {
  static final TravelScheduleService instance = TravelScheduleService._();

  TravelScheduleService._();

  /// 추천 여행 일정 조회
  Future<List<Map<String, dynamic>>> fetchRecommendSchedule(
    int travelDays,
    String countryCity,
  ) async {
    try {
      final response = await ApiClient.instance.post<Map<String, dynamic>>(
        '/api/travel-plan',
        data: {
          'destination': '삿포로',
          'days': 4,
          'language': 'ko',
          'budget': 1000,
        },
      );

      LogUtil.debug('API 응답 전체: ${response.toString()}', tag: 'TRAVEL_API');

      if (response.statusCode == 200 && response.data != null) {
        // API 응답 구조에 따라 조정이 필요할 수 있습니다
        final data = response.data!;
        LogUtil.logJson(data, tag: 'TRAVEL_API', prefix: '파싱된 응답 데이터');

        if (data['data'] is List) {
          LogUtil.success('여행 일정 리스트 데이터 반환', tag: 'TRAVEL_API');
          return List<Map<String, dynamic>>.from(data['data']);
        }

        LogUtil.success('여행 일정 단일 데이터 반환', tag: 'TRAVEL_API');
        return [data]; // 단일 객체인 경우
      }

      LogUtil.warning('API 응답이 비어있거나 상태코드가 200이 아님', tag: 'TRAVEL_API');
      return [];
    } catch (e, stackTrace) {
      LogUtil.logError('여행 일정 조회 실패',
          error: e, stackTrace: stackTrace, tag: 'TRAVEL_ERROR');
      rethrow;
    }
  }

  /// 추천 여행 일정 스트림 조회
  Stream<Map<String, dynamic>> fetchRecommendScheduleStream(
    int travelDays,
    String countryCity,
  ) async* {
    try {
      final response = await ApiClient.instance.post<ResponseBody>(
        '/api/travel-plan/stream',
        data: {
          'destination': countryCity,
          'days': travelDays,
          'language': 'ko',
          'budget': 1000,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        LogUtil.warning('스트림 데이터가 없습니다.', tag: 'TRAVEL_API');
        return;
      }

      await for (final chunk in stream) {
        try {
          final String text = utf8.decode(chunk);
          LogUtil.debug('수신된 원본 데이터: $text', tag: 'TRAVEL_API_RAW');

          // 빈 줄과 공백 제거
          final lines = text
              .split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty);

          for (final line in lines) {
            try {
              // SSE 형식에서 'data: ' prefix 제거
              String jsonStr = line;
              if (line.startsWith('data: ')) {
                jsonStr = line.substring(6); // 'data: ' 부분 제거
              }

              // 유효한 JSON 문자열인지 확인
              if (!jsonStr.startsWith('{') || !jsonStr.endsWith('}')) {
                LogUtil.warning('유효하지 않은 JSON 형식: $jsonStr', tag: 'TRAVEL_API');
                continue;
              }

              LogUtil.debug('파싱 시도할 라인: $jsonStr', tag: 'TRAVEL_API_LINE');
              final json = jsonDecode(jsonStr);

              // 필수 필드 확인
              if (json['type'] == null) {
                LogUtil.warning('필수 필드 누락: type', tag: 'TRAVEL_API');
                continue;
              }

              LogUtil.debug(
                '스트림 데이터 수신: ${json['type']} - ${json['description'] ?? ""}',
                tag: 'TRAVEL_API',
              );

              yield json;
            } catch (e) {
              LogUtil.warning('JSON 파싱 실패: $line\n에러: $e', tag: 'TRAVEL_API');
              continue;
            }
          }
        } catch (e) {
          LogUtil.warning('청크 디코딩 실패: $e', tag: 'TRAVEL_API');
          continue;
        }
      }
    } catch (e, stackTrace) {
      LogUtil.logError(
        '여행 일정 스트림 조회 실패',
        error: e,
        stackTrace: stackTrace,
        tag: 'TRAVEL_ERROR',
      );
      rethrow;
    }
  }
}
