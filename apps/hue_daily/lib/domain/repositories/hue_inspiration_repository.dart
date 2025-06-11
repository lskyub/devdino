import '../entities/hue_inspiration.dart';

/// 영감 컬러 데이터 관리를 위한 리포지토리 인터페이스
abstract class HueInspirationRepository {
  /// 모든 영감 컬러 목록을 가져옵니다.
  Future<List<HueInspiration>> getInspirations();

  /// 특정 ID의 영감 컬러를 가져옵니다.
  Future<HueInspiration?> getInspiration(String id);

  /// 새로운 영감 컬러를 생성합니다.
  Future<void> createInspiration(HueInspiration inspiration);

  /// 기존 영감 컬러를 업데이트합니다.
  Future<void> updateInspiration(HueInspiration inspiration);

  /// 특정 ID의 영감 컬러를 삭제합니다.
  Future<void> deleteInspiration(String id);

  /// 로컬 데이터를 클라우드와 동기화합니다.
  Future<void> syncToCloud();
} 