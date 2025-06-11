import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class LogUtil {
  /// 긴 텍스트를 잘리지 않게 로그로 출력하는 함수
  static void logLongText(String text, {String tag = 'APP'}) {
    // Release 모드에서는 로그 출력 안함
    if (kReleaseMode) return;

    const int maxLogLength = 800;

    if (text.length <= maxLogLength) {
      developer.log(text, name: tag);
    } else {
      int start = 0;
      int end = maxLogLength;
      int part = 1;

      while (start < text.length) {
        if (end > text.length) end = text.length;

        String partText = text.substring(start, end);
        developer.log(
            '[$part/${((text.length / maxLogLength).ceil())}] $partText',
            name: tag);

        start = end;
        end += maxLogLength;
        part++;
      }
    }
  }

  /// JSON 데이터를 예쁘게 포맷해서 로그 출력
  static void logJson(dynamic jsonData, {String tag = 'JSON', String? prefix}) {
    if (kReleaseMode) return;

    String text = jsonData.toString();
    if (prefix != null) {
      text = '$prefix: $text';
    }

    logLongText(text, tag: tag);
  }

  /// API 요청 로그
  static void logRequest(String method, String url,
      {Map<String, dynamic>? params, dynamic data}) {
    if (kReleaseMode) return;

    logLongText('📤 $method $url', tag: 'API_REQUEST');

    if (params != null && params.isNotEmpty) {
      logJson(params, tag: 'API_REQUEST', prefix: '쿼리 파라미터');
    }

    if (data != null) {
      logJson(data, tag: 'API_REQUEST', prefix: '요청 데이터');
    }
  }

  /// API 응답 로그
  static void logResponse(int statusCode, String url, dynamic data) {
    if (kReleaseMode) return;

    logLongText('📥 $statusCode $url', tag: 'API_RESPONSE');
    logJson(data, tag: 'API_RESPONSE', prefix: '응답 데이터');
  }

  /// 에러 로그
  static void logError(String message,
      {dynamic error, StackTrace? stackTrace, String tag = 'ERROR'}) {
    if (kReleaseMode) return;

    logLongText('❌ $message', tag: tag);

    if (error != null) {
      logLongText('오류 상세: $error', tag: tag);
    }

    if (stackTrace != null) {
      logLongText('스택 트레이스: $stackTrace', tag: tag);
    }
  }

  /// 일반 디버그 로그
  static void debug(String message, {String tag = 'DEBUG'}) {
    if (kReleaseMode) return;
    logLongText('💬 $message', tag: tag);
  }

  /// 성공 로그
  static void success(String message, {String tag = 'SUCCESS'}) {
    if (kReleaseMode) return;
    logLongText('✅ $message', tag: tag);
  }

  /// 경고 로그
  static void warning(String message, {String tag = 'WARNING'}) {
    if (kReleaseMode) return;
    logLongText('⚠️ $message', tag: tag);
  }
}
