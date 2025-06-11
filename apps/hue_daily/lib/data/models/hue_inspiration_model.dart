import '../../domain/entities/hue_inspiration.dart';

/// 영감 컬러 모델 클래스
class HueInspirationModel extends HueInspiration {
  const HueInspirationModel({
    required super.id,
    required super.quote,
    super.author,
    required super.mainColor,
    required super.createdAt,
    super.category,
    super.mood,
  });

  /// Map에서 모델 인스턴스를 생성합니다.
  factory HueInspirationModel.fromMap(Map<String, dynamic> map) {
    return HueInspirationModel(
      id: map['id'] as String,
      quote: map['quote'] as String,
      author: map['author'] as String?,
      mainColor: map['main_color'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      category: map['category'] as String?,
      mood: map['mood'] as String?,
    );
  }

  /// 모델 인스턴스를 Map으로 변환합니다.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quote': quote,
      'author': author,
      'main_color': mainColor,
      'created_at': createdAt.toIso8601String(),
      'category': category,
      'mood': mood,
    };
  }

  /// JSON에서 모델 인스턴스를 생성합니다.
  factory HueInspirationModel.fromJson(Map<String, dynamic> json) {
    return HueInspirationModel.fromMap(json);
  }

  /// 모델 인스턴스를 JSON으로 변환합니다.
  Map<String, dynamic> toJson() => toMap();

  /// 엔티티를 모델로 변환합니다.
  factory HueInspirationModel.fromEntity(HueInspiration entity) {
    return HueInspirationModel(
      id: entity.id,
      quote: entity.quote,
      author: entity.author,
      mainColor: entity.mainColor,
      createdAt: entity.createdAt,
      category: entity.category,
      mood: entity.mood,
    );
  }
} 