import 'package:flutter_test/flutter_test.dart';
import 'package:hue_daily/domain/entities/hue_inspiration.dart';

void main() {
  group('HueInspiration Entity', () {
    test('should create HueInspiration instance with all properties', () {
      final inspiration = HueInspiration(
        id: 'test-id',
        quote: 'Test quote',
        author: 'Test author',
        mainColor: 0xFFFF0000,
        createdAt: DateTime(2024, 3, 1),
        category: 'peace',
        mood: 'calm',
      );

      expect(inspiration.id, 'test-id');
      expect(inspiration.quote, 'Test quote');
      expect(inspiration.author, 'Test author');
      expect(inspiration.mainColor, 0xFFFF0000);
      expect(inspiration.createdAt, DateTime(2024, 3, 1));
      expect(inspiration.category, 'peace');
      expect(inspiration.mood, 'calm');
    });

    test('should create HueInspiration instance with required properties only', () {
      final inspiration = HueInspiration(
        id: 'test-id',
        quote: 'Test quote',
        mainColor: 0xFFFF0000,
        createdAt: DateTime(2024, 3, 1),
      );

      expect(inspiration.id, 'test-id');
      expect(inspiration.quote, 'Test quote');
      expect(inspiration.mainColor, 0xFFFF0000);
      expect(inspiration.createdAt, DateTime(2024, 3, 1));
      expect(inspiration.author, isNull);
      expect(inspiration.category, isNull);
      expect(inspiration.mood, isNull);
    });

    test('should compare two HueInspiration instances correctly', () {
      final inspiration1 = HueInspiration(
        id: 'test-id',
        quote: 'Test quote',
        mainColor: 0xFFFF0000,
        createdAt: DateTime(2024, 3, 1),
      );

      final inspiration2 = HueInspiration(
        id: 'test-id',
        quote: 'Test quote',
        mainColor: 0xFFFF0000,
        createdAt: DateTime(2024, 3, 1),
      );

      expect(inspiration1, equals(inspiration2));
    });
  });
} 