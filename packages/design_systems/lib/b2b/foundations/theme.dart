import 'package:flutter/painting.dart';
import 'package:design_systems/b2b/foundations/colors.dart';
import 'package:design_systems/b2b/foundations/radius.dart';
import 'package:design_systems/b2b/foundations/spaces.dart';
import 'package:design_systems/b2b/foundations/text_styles.dart';
import 'package:mix/mix.dart';

const $b2bToken = ServerBoardThemeToken();

class ServerBoardThemeToken {
  const ServerBoardThemeToken();
  final color = const B2BColorToken();
  final textStyle = const ServerBoardTextStyleToken();
  final radius = const ServerBoardRadiusToken();
  final space = const B2BSpaceToken();
}

final b2bTheme = MixThemeData(
  colors: {
    $b2bToken.color.black: const Color(0xFF000000),
    $b2bToken.color.white: const Color(0xFFFFFFFF),

    // grays
    $b2bToken.color.gray100: const Color(0xFFeeeeef),
    $b2bToken.color.gray200: const Color(0xFFc7c5c8),
    $b2bToken.color.gray300: const Color(0xFFa19ea3),
    $b2bToken.color.gray400: const Color(0xFF7d7980),
    $b2bToken.color.gray500: const Color(0xFF59565B),
    $b2bToken.color.gray600: const Color(0xFF383639),
    $b2bToken.color.gray700: const Color(0xFF19181a),

    // Green
    $b2bToken.color.green100: const Color(0xFFe0f6e9),
    $b2bToken.color.green200: const Color(0xFFA5D9BB),
    $b2bToken.color.green300: const Color(0xFF85b097),
    $b2bToken.color.green400: const Color(0xFF678975),
    $b2bToken.color.green500: const Color(0xFF4a6354),
    $b2bToken.color.green600: const Color(0xFF2e4036),
    $b2bToken.color.green700: const Color(0xFF16201a),

    // Pink
    $b2bToken.color.pink100: const Color(0xFFecd5e2),
    $b2bToken.color.pink200: const Color(0xFFD9A5C3),
    $b2bToken.color.pink300: const Color(0xFFc772a7),
    $b2bToken.color.pink400: const Color(0xFF99527e),
    $b2bToken.color.pink500: const Color(0xFF693756),
    $b2bToken.color.pink600: const Color(0xFF3d1d31),
    $b2bToken.color.pink700: const Color(0xFF1d0b16),

    // Violet
    $b2bToken.color.violet100: const Color(0xFFF3EFFA),
    $b2bToken.color.violet200: const Color(0xFFd4c2eb),
    $b2bToken.color.violet300: const Color(0xFFb595dc),
    $b2bToken.color.violet400: const Color(0xFF9966CC),
    $b2bToken.color.violet500: const Color(0xFF7442a2),
    $b2bToken.color.violet600: const Color(0xFF4b296a),
    $b2bToken.color.violet700: const Color(0xFF251137),

    // Primary
    $b2bToken.color.primary: const Color(0xFF9966CC),
    $b2bToken.color.primary2: const Color(0xFFD9A5C3),
  }.expand,
  textStyles: {
    $b2bToken.textStyle.headline1: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: ColorRef($b2bToken.color.gray700),
    ),
    $b2bToken.textStyle.headline2: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      color: ColorRef($b2bToken.color.gray500),
    ),
    ...display(),
    ...headerline(),
    ...title(),
    ...body(),
    ...caption()
  },
  radii: {
    $b2bToken.radius.large: const Radius.circular(100),
    $b2bToken.radius.medium: const Radius.circular(12),
  },
  spaces: {
    $b2bToken.space.s0: 0,
    $b2bToken.space.s1: 4,
    $b2bToken.space.s2: 6,
    $b2bToken.space.s3: 8,
    $b2bToken.space.s4: 12,
    $b2bToken.space.s5: 16,
    $b2bToken.space.s6: 20,
    $b2bToken.space.s7: 24,
    $b2bToken.space.s8: 28,
    $b2bToken.space.s9: 32,
    $b2bToken.space.s10: 36,
    $b2bToken.space.s11: 40,
    $b2bToken.space.s12: 48,
    $b2bToken.space.s13: 50,
    $b2bToken.space.s14: 72,
    $b2bToken.space.s15: 80,
  },
);

extension ColorExpand on Map<ColorToken, Color> {
  Map<ColorToken, Color> get expand {
    addAll({
      // Static
      $b2bToken.color.staticNetural: this[$b2bToken.color.white]!,
      $b2bToken.color.staticBlack: this[$b2bToken.color.black]!,

      // Status
      $b2bToken.color.statusPositive: this[$b2bToken.color.green500]!,
      $b2bToken.color.statusPositivelight: this[$b2bToken.color.green100]!,
      $b2bToken.color.statusNegative: this[$b2bToken.color.pink500]!,
      $b2bToken.color.statusNegativelight: this[$b2bToken.color.pink100]!,
      $b2bToken.color.statusCauntionary: this[$b2bToken.color.gray700]!,

      // Button Primary
      $b2bToken.color.buttonPrimaryEnabled: this[$b2bToken.color.violet400]!,
      $b2bToken.color.buttonPrimaryPressed: this[$b2bToken.color.violet500]!,
      $b2bToken.color.buttonPrimaryBorder: this[$b2bToken.color.violet400]!,
      $b2bToken.color.buttonPrimaryDisabled: this[$b2bToken.color.gray300]!,
      $b2bToken.color.buttonPrimaryLightEnabled:
          this[$b2bToken.color.violet100]!,
      $b2bToken.color.buttonPrimaryLightPressed:
          this[$b2bToken.color.violet200]!,
      $b2bToken.color.buttonPrimaryLightBorder:
          this[$b2bToken.color.violet600]!,
      $b2bToken.color.buttonPrimaryLightDisabled:
          this[$b2bToken.color.gray300]!,

      // Button Secondary
      $b2bToken.color.buttonSecondaryNetural: this[$b2bToken.color.white]!,
      $b2bToken.color.buttonSecondaryPressed: this[$b2bToken.color.gray100]!,
      $b2bToken.color.buttonSecondaryBorder: this[$b2bToken.color.gray300]!,
      $b2bToken.color.buttonSecondaryDisabled: this[$b2bToken.color.gray200]!,
      $b2bToken.color.buttonSecondaryActive: this[$b2bToken.color.gray700]!,

      // Label
      $b2bToken.color.labelPrimary: this[$b2bToken.color.primary]!,
      $b2bToken.color.labelNomal: this[$b2bToken.color.gray500]!,
      $b2bToken.color.labelStrong: this[$b2bToken.color.gray700]!,
      $b2bToken.color.labelDisabled: this[$b2bToken.color.gray200]!,
      $b2bToken.color.labelNetural: this[$b2bToken.color.white]!,
      $b2bToken.color.labelNeturalDisabled: this[$b2bToken.color.gray400]!,

      // Background
      $b2bToken.color.backgroundLightPrimary: this[$b2bToken.color.violet100]!,
      $b2bToken.color.backgroundNomal: this[$b2bToken.color.white]!,
      $b2bToken.color.backgroundNetural1: this[$b2bToken.color.gray100]!,
      $b2bToken.color.backgroundNetural2: this[$b2bToken.color.gray200]!,
      $b2bToken.color.backgroundNetural3: this[$b2bToken.color.gray300]!,
      $b2bToken.color.backgroundNetural4: this[$b2bToken.color.gray400]!,

      // Border
      $b2bToken.color.borderNomal: this[$b2bToken.color.gray300]!,
      $b2bToken.color.borderPostive: this[$b2bToken.color.green500]!,
      $b2bToken.color.borderNegative: this[$b2bToken.color.pink500]!,

      // Icon
      $b2bToken.color.iconPrimary: this[$b2bToken.color.primary]!,
      $b2bToken.color.iconNetural: this[$b2bToken.color.white]!,
      $b2bToken.color.iconNomal: this[$b2bToken.color.gray500]!,
      $b2bToken.color.iconStrong: this[$b2bToken.color.gray700]!,
      $b2bToken.color.iconDisabled: this[$b2bToken.color.gray200]!,

      // Divider
      $b2bToken.color.divider1: this[$b2bToken.color.gray200]!,
      $b2bToken.color.divider2: this[$b2bToken.color.gray300]!,
      $b2bToken.color.divider3: this[$b2bToken.color.gray400]!,

      // Dimmed
      $b2bToken.color.dimmed: const Color(0x99000000),

      $b2bToken.color.toastSystem: const Color(0x66131517),
      $b2bToken.color.toastStatus: const Color(0xCC131517),
    });
    return this;
  }
}

Map<TextStyleToken, TextStyle> display() {
  return {
    ///Display
    $b2bToken.textStyle.displaybold: TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.2,
    ),
    $b2bToken.textStyle.displaymedium: TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.w500,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.2,
    ),
    $b2bToken.textStyle.displayregular: TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.w400,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.2,
    ),
  };
}

Map<TextStyleToken, TextStyle> headerline() {
  return {
    ///Headline
    ///Headline1
    $b2bToken.textStyle.headline1bold: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.3,
    ),
    $b2bToken.textStyle.headline1medium: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w500,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.3,
    ),
    $b2bToken.textStyle.headline1regular: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w400,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.3,
    ),

    ///Headline2
    $b2bToken.textStyle.headline2bold: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.3,
    ),
    $b2bToken.textStyle.headline2medium: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w500,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.3,
    ),
    $b2bToken.textStyle.headline2regular: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.3,
    ),
  };
}

Map<TextStyleToken, TextStyle> title() {
  return {
    ///Title
    ///Title1
    $b2bToken.textStyle.title1bold: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.4,
    ),
    $b2bToken.textStyle.title1medium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.4,
    ),
    $b2bToken.textStyle.title1regular: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.4,
    ),

    ///Title2
    $b2bToken.textStyle.title2bold: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.4,
    ),
    $b2bToken.textStyle.title2medium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.4,
    ),
    $b2bToken.textStyle.title2regular: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.4,
    ),

    ///Title3
    $b2bToken.textStyle.title3bold: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),
    $b2bToken.textStyle.title3medium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),
    $b2bToken.textStyle.title3regular: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),
  };
}

Map<TextStyleToken, TextStyle> body() {
  return {
    ///Body
    ///Body1
    $b2bToken.textStyle.body1bold: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),
    $b2bToken.textStyle.body1medium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),
    $b2bToken.textStyle.body1regular: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),

    ///Body2
    $b2bToken.textStyle.body2bold: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),
    $b2bToken.textStyle.body2medium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),
    $b2bToken.textStyle.body2regular: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),

    ///Body3
    $b2bToken.textStyle.body3bold: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),
    $b2bToken.textStyle.body3medium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),
    $b2bToken.textStyle.body3regular: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),

    ///Body4
    $b2bToken.textStyle.body4bold: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),
    $b2bToken.textStyle.body4medium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),
    $b2bToken.textStyle.body4regular: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.5,
    ),
  };
}

Map<TextStyleToken, TextStyle> caption() {
  return {
    ///Caption
    ///Caption1
    $b2bToken.textStyle.caption1bold: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.6,
    ),
    $b2bToken.textStyle.caption1medium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.6,
    ),
    $b2bToken.textStyle.caption1regular: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.6,
    ),

    ///Caption2
    $b2bToken.textStyle.caption2bold: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.6,
    ),
    $b2bToken.textStyle.caption2medium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.6,
    ),
    $b2bToken.textStyle.caption2regular: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      fontFamily: 'Pretendard',
      color: ColorRef($b2bToken.color.gray700),
      height: 1.6,
    ),
  };
}
