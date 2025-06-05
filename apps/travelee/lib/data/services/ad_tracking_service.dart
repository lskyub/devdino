import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AdTrackingService {
  /// 광고 추적 권한 요청
  static Future<bool> requestTrackingAuthorization() async {
    if (!Platform.isIOS) return true;

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // 추적 권한 요청 전에 잠시 대기 (Apple 권장사항)
        await Future.delayed(const Duration(milliseconds: 200));
        final result = await AppTrackingTransparency.requestTrackingAuthorization();
        return result == TrackingStatus.authorized;
      }
      return status == TrackingStatus.authorized;
    } catch (e) {
      // 오류 발생 시 추적 불가로 처리
      return false;
    }
  }

  /// 현재 추적 권한 상태 확인
  static Future<bool> isTrackingAuthorized() async {
    if (!Platform.isIOS) return true;

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      return status == TrackingStatus.authorized;
    } catch (e) {
      return false;
    }
  }
} 