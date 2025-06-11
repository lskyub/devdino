import 'package:flutter_test/flutter_test.dart';
import 'package:hue_daily/domain/entities/hue_inspiration.dart';
import 'package:hue_daily/domain/repositories/hue_inspiration_repository.dart';
import 'package:hue_daily/domain/usecases/get_daily_inspiration.dart';

class MockHueInspirationRepository implements HueInspirationRepository {
  final List<HueInspiration> _inspirations = [];

  @override
  Future<List<HueInspiration>> getInspirations() async => _inspirations;

  @override
  Future<HueInspiration?> getInspiration(String id) async {
    try {
      return _inspirations.firstWhere((inspiration) => inspiration.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createInspiration(HueInspiration inspiration) async {
    _inspirations.add(inspiration);
  }

  @override
  Future<void> updateInspiration(HueInspiration inspiration) async {
    final index = _inspirations.indexWhere((item) => item.id == inspiration.id);
    if (index != -1) {
      _inspirations[index] = inspiration;
    }
  }

  @override
  Future<void> deleteInspiration(String id) async {
    _inspirations.removeWhere((inspiration) => inspiration.id == id);
  }

  @override
  Future<void> syncToCloud() async {}
}

void main() {
  late GetDailyInspiration getDailyInspiration;
  late MockHueInspirationRepository repository;

  setUp(() {
    repository = MockHueInspirationRepository();
    getDailyInspiration = GetDailyInspiration(repository);
  });

  test('should return today\'s inspiration when exists', () async {
    final today = DateTime.now();
    final todayInspiration = HueInspiration(
      id: 'today-id',
      quote: 'Today\'s quote',
      mainColor: 0xFFFF0000,
      createdAt: today,
    );

    await repository.createInspiration(todayInspiration);

    final result = await getDailyInspiration();
    expect(result, equals(todayInspiration));
  });

  test('should create new inspiration when none exists for today', () async {
    final result = await getDailyInspiration();
    
    expect(result, isNotNull);
    expect(result.createdAt.day, equals(DateTime.now().day));
    expect(result.createdAt.month, equals(DateTime.now().month));
    expect(result.createdAt.year, equals(DateTime.now().year));
  });
} 