import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 광고 추적 서비스
class AdTrackingService {
  /// 광고 추적 서비스 인스턴스
  static final AdTrackingService instance = AdTrackingService._();

  AdTrackingService._();

  /// 광고 추적 초기화
  Future<void> initialize() async {
    // TODO: 광고 추적 초기화 구현
  }

  /// 광고 이벤트 추적
  Future<void> trackAdEvent(String eventName, Map<String, dynamic> parameters) async {
    // TODO: 광고 이벤트 추적 구현
  }

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

/// 광고 추적 서비스 프로바이더
final adTrackingServiceProvider = Provider<AdTrackingService>((ref) {
  return AdTrackingService.instance;
}); 