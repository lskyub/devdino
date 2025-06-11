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
        queryParameters: {
          // 'destination': countryCity,
          // 'days': travelDays,
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
}
