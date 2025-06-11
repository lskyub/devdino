import 'dart:math';

/// 색상 생성을 위한 유틸리티 클래스
class ColorGenerator {
  static final _random = Random();

  /// 랜덤한 색상을 생성합니다.
  /// 
  /// 반환값은 0xFFRRGGBB 형식의 정수입니다.
  static int generateRandomColor() {
    final r = _random.nextInt(256);
    final g = _random.nextInt(256);
    final b = _random.nextInt(256);
    
    return 0xFF000000 | (r << 16) | (g << 8) | b;
  }

  /// 미리 정의된 색상 팔레트에서 색상을 선택합니다.
  /// 
  /// 반환값은 0xFFRRGGBB 형식의 정수입니다.
  static int getColorFromPalette() {
    const colors = [
      0xFFB0E0E6, // 파스텔 블루
      0xFFFDFAF9, // 피치 베이지
      0xFF98FB98, // 민트 그린
      0xFFE6E6FA, // 라벤더
      0xFFFFE4E1, // 미스티 로즈
      0xFFAFEEEE, // 아쿠아마린
      0xFFFFEFD5, // 파파야 휩
      0xFFADD8E6, // 라이트 블루
      0xFFF0FFF0, // 허니듀
      0xFFFFC0CB, // 핑크
    ];

    return colors[_random.nextInt(colors.length)];
  }

  /// 주어진 색상의 밝기를 조절합니다.
  /// 
  /// [color] 원본 색상 (0xFFRRGGBB 형식)
  /// [factor] 밝기 조절 계수 (0.0 ~ 1.0, 1.0이 원본)
  /// 반환값은 0xFFRRGGBB 형식의 정수입니다.
  static int adjustBrightness(int color, double factor) {
    assert(factor >= 0.0 && factor <= 1.0);

    final r = ((color >> 16) & 0xFF);
    final g = ((color >> 8) & 0xFF);
    final b = (color & 0xFF);

    final adjustedR = (r * factor).round().clamp(0, 255);
    final adjustedG = (g * factor).round().clamp(0, 255);
    final adjustedB = (b * factor).round().clamp(0, 255);

    return 0xFF000000 | (adjustedR << 16) | (adjustedG << 8) | adjustedB;
  }
} 