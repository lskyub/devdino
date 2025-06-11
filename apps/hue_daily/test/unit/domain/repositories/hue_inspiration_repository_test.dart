import 'package:flutter_test/flutter_test.dart';
import 'package:hue_daily/domain/entities/hue_inspiration.dart';
import 'package:hue_daily/domain/repositories/hue_inspiration_repository.dart';

class MockHueInspirationRepository implements HueInspirationRepository {
  final List<HueInspiration> _inspirations = [];

  @override
  Future<List<HueInspiration>> getInspirations() async {
    return _inspirations;
  }

  @override
  Future<HueInspiration?> getInspiration(String id) async {
    return _inspirations.firstWhere((inspiration) => inspiration.id == id);
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
  Future<void> syncToCloud() async {
    // Mock implementation
  }
}

void main() {
  late MockHueInspirationRepository repository;
  late HueInspiration testInspiration;

  setUp(() {
    repository = MockHueInspirationRepository();
    testInspiration = HueInspiration(
      id: 'test-id',
      quote: 'Test quote',
      mainColor: 0xFFFF0000,
      createdAt: DateTime(2024, 3, 1),
    );
  });

  group('HueInspirationRepository', () {
    test('should create and retrieve inspiration', () async {
      await repository.createInspiration(testInspiration);
      final inspirations = await repository.getInspirations();
      
      expect(inspirations.length, 1);
      expect(inspirations.first, equals(testInspiration));
    });

    test('should update inspiration', () async {
      await repository.createInspiration(testInspiration);
      
      final updatedInspiration = testInspiration.copyWith(
        quote: 'Updated quote',
      );
      
      await repository.updateInspiration(updatedInspiration);
      final inspiration = await repository.getInspiration(testInspiration.id);
      
      expect(inspiration?.quote, 'Updated quote');
    });

    test('should delete inspiration', () async {
      await repository.createInspiration(testInspiration);
      await repository.deleteInspiration(testInspiration.id);
      
      final inspirations = await repository.getInspirations();
      expect(inspirations.isEmpty, true);
    });
  });
} 