/// TravelDateFormatter
///
/// 여행 앱에서 사용하는 날짜 관련 유틸리티 클래스
/// - 날짜 포맷팅 (YYYY.MM.DD 형식)
/// - 시작일과 종료일 사이의 날짜 범위 생성
class TravelDateFormatter {
  /// 날짜를 'YYYY.MM.DD' 형식의 문자열로 변환
  /// @param date 변환할 날짜
  /// @return 포맷된 날짜 문자열 (날짜가 null인 경우 '-' 반환)
  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    String formattedDate =
        '${date.year.toString().substring(2, 4)}.${date.month.toString()}.${date.day.toString()}';
    return formattedDate;
  }

  static String formatDateWithoutYear(DateTime? date) {
    if (date == null) return '-';
    String formattedDate =
        '${date.month.toString()}.${date.day.toString()}';
    return formattedDate;
  }

  static String formatDateRange(DateTime start, DateTime end) {
    // 시작연도와 종료 연도가 같을 경우 종료 연도에는 연도를 표시하지 않음
    if (start.year == end.year) {
      return '${formatDate(start)} - ${formatDateWithoutYear(end)}';
    }
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  /// 시작일부터 종료일까지의 연속된 날짜 목록 생성
  /// @param start 시작 날짜
  /// @param end 종료 날짜
  /// @return 날짜 목록 (시작일과 종료일 포함)
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    List<DateTime> dates = [];
    for (DateTime date = start;
        date.isBefore(end.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      dates.add(date);
    }
    return dates;
  }
}
