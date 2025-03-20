/// 애플리케이션 내에서 날짜 표시를 처리하는 유틸리티 클래스
class DateUtil {
  /// 날짜를 'yyyy년 MM월 dd일' 형식으로 변환
  /// null인 경우 '날짜 없음' 반환
  static String formatDate(DateTime? date) {
    if (date == null) return '날짜 없음';
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 날짜를 'yyyy년 MM월 dd일 (요일)' 형식으로 변환
  /// null인 경우 '날짜 없음' 반환
  static String formatDateWithDay(DateTime? date) {
    if (date == null) return '날짜 없음';
    final dayNames = ['월', '화', '수', '목', '금', '토', '일'];
    final dayOfWeek = dayNames[date.weekday - 1]; // weekday는 1(월)~7(일)
    return '${date.year}년 ${date.month}월 ${date.day}일 ($dayOfWeek)';
  }
  
  /// 날짜를 'yyyy.MM.dd' 형식으로 변환
  /// null인 경우 '날짜 없음' 반환
  static String formatShortDate(DateTime? date) {
    if (date == null) return '날짜 없음';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
  
  /// 여행의 시작일과 종료일 사이의 일 수 계산
  /// 둘 중 하나라도 null인 경우 1 반환
  static int getDaysCount(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return 1;
    
    // 날짜만 비교하기 위해 시간 정보 제거
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    // 차이를 일 단위로 계산하고 1을 더함 (시작일 포함)
    return end.difference(start).inDays + 1;
  }
  
  /// 여행의 시작일부터 종료일까지의 모든 날짜 목록 생성
  /// 둘 중 하나라도 null인 경우 빈 목록 반환
  static List<DateTime> getAllDates(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return [];
    
    // 날짜만 비교하기 위해 시간 정보 제거
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    final result = <DateTime>[];
    
    // 시작일부터 종료일까지 모든 날짜 추가
    for (var i = 0; i <= end.difference(start).inDays; i++) {
      result.add(start.add(Duration(days: i)));
    }
    
    return result;
  }
} 