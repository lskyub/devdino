import 'package:mix/mix.dart';

class DinoTypographyToken {
  const DinoTypographyToken();

  TextStyleToken get headingXXL => const TextStyleToken('headingXXL');
  TextStyleToken get headingXL => const TextStyleToken('headingXL');
  TextStyleToken get headingL => const TextStyleToken('headingL');
  TextStyleToken get headingM => const TextStyleToken('headingM');
  TextStyleToken get headingS => const TextStyleToken('headingS');
  TextStyleToken get headingXS => const TextStyleToken('headingXS');

  TextStyleToken get bodyXXL => const TextStyleToken('bodyXXL');
  TextStyleToken get bodyXL => const TextStyleToken('bodyXL');
  TextStyleToken get bodyL => const TextStyleToken('bodyL');
  TextStyleToken get bodyM => const TextStyleToken('bodyM');
  TextStyleToken get bodyS => const TextStyleToken('bodyS');
  TextStyleToken get bodyXS => const TextStyleToken('bodyXS');

  TextStyleToken get detailXXL => const TextStyleToken('detailXXL');
  TextStyleToken get detailXL => const TextStyleToken('detailXL');
  TextStyleToken get detailL => const TextStyleToken('detailL');
  TextStyleToken get detailM => const TextStyleToken('detailM');
  TextStyleToken get detailS => const TextStyleToken('detailS');
}

class DinoTextSizeToken {
  const DinoTextSizeToken();

  static const scale = 1.125;
  static const text300 = 16.0;

  static const text200 = text300 / scale;
  static const text100 = text200 / scale;
  static const text75 = text100 / scale;
  static const text50 = text75 / scale;

  static const text400 = text300 * scale;
  static const text500 = text400 * scale;
  static const text600 = text500 * scale;
  static const text700 = text600 * scale;
  static const text800 = text700 * scale;
  static const text900 = text800 * scale;
  static const text1000 = text900 * scale;
  static const text1100 = text1000 * scale;
}
