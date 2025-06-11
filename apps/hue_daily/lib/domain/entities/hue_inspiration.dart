import 'package:equatable/equatable.dart';

/// 영감 컬러와 관련된 정보를 담는 엔티티
class HueInspiration extends Equatable {
  final String id;
  final String quote;
  final String? author;
  final int mainColor;
  final DateTime createdAt;
  final String? category;
  final String? mood;

  const HueInspiration({
    required this.id,
    required this.quote,
    this.author,
    required this.mainColor,
    required this.createdAt,
    this.category,
    this.mood,
  });

  @override
  List<Object?> get props => [
        id,
        quote,
        author,
        mainColor,
        createdAt,
        category,
        mood,
      ];

  HueInspiration copyWith({
    String? id,
    String? quote,
    String? author,
    int? mainColor,
    DateTime? createdAt,
    String? category,
    String? mood,
  }) {
    return HueInspiration(
      id: id ?? this.id,
      quote: quote ?? this.quote,
      author: author ?? this.author,
      mainColor: mainColor ?? this.mainColor,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      mood: mood ?? this.mood,
    );
  }
} 