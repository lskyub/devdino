import 'package:uuid/uuid.dart';
import '../entities/hue_inspiration.dart';
import '../repositories/hue_inspiration_repository.dart';
import '../../core/utils/color_generator.dart';

/// 오늘의 영감 컬러를 가져오는 UseCase
class GetDailyInspiration {
  final HueInspirationRepository _repository;
  final _uuid = const Uuid();

  GetDailyInspiration(this._repository);

  /// 오늘의 영감 컬러를 가져옵니다.
  /// 오늘 날짜의 영감이 없다면 새로 생성합니다.
  Future<HueInspiration> call() async {
    final inspirations = await _repository.getInspirations();
    final today = DateTime.now();

    // 오늘 날짜의 영감이 있는지 확인
    final todayInspiration = inspirations.where((inspiration) {
      final createdAt = inspiration.createdAt;
      return createdAt.year == today.year &&
          createdAt.month == today.month &&
          createdAt.day == today.day;
    }).firstOrNull;

    // 오늘의 영감이 있으면 반환
    if (todayInspiration != null) {
      return todayInspiration;
    }

    // 오늘의 영감이 없으면 새로 생성
    final newInspiration = HueInspiration(
      id: _uuid.v4(),
      quote: _getRandomQuote(),
      mainColor: ColorGenerator.generateRandomColor(),
      createdAt: today,
    );

    await _repository.createInspiration(newInspiration);
    return newInspiration;
  }

  String _getRandomQuote() {
    // TODO: 실제 영감 문구 데이터베이스에서 가져오기
    return '오늘도 당신의 하루가 영감으로 가득하기를';
  }
} 