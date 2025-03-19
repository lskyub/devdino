import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:design_systems/dino/foundations/theme.dart';
import 'package:mix/mix.dart';

class DinoTextStyle {
  DinoTextStyle(this.type);

  final DinoTextType type;

  Style style() => Style(
        DinoTextType.headingXXL(
          $text.style.ref($dinoToken.typography.headingXXL),
        ),
        DinoTextType.headingXL(
          $text.style.ref($dinoToken.typography.headingXL),
        ),
        DinoTextType.headingL(
          $text.style.ref($dinoToken.typography.headingL),
        ),
        DinoTextType.headingM(
          $text.style.ref($dinoToken.typography.headingM),
        ),
        DinoTextType.headingS(
          $text.style.ref($dinoToken.typography.headingS),
        ),
        DinoTextType.headingXS(
          $text.style.ref($dinoToken.typography.headingXS),
        ),
        DinoTextType.bodyXXL(
          $text.style.ref($dinoToken.typography.bodyXXL),
        ),
        DinoTextType.bodyXL(
          $text.style.ref($dinoToken.typography.bodyXL),
        ),
        DinoTextType.bodyL(
          $text.style.ref($dinoToken.typography.bodyL),
        ),
        DinoTextType.bodyM(
          $text.style.ref($dinoToken.typography.bodyM),
        ),
        DinoTextType.bodyS(
          $text.style.ref($dinoToken.typography.bodyS),
        ),
        DinoTextType.bodyXS(
          $text.style.ref($dinoToken.typography.bodyXS),
        ),
        DinoTextType.detailXL(
          $text.style.ref($dinoToken.typography.detailXL),
        ),
        DinoTextType.detailL(
          $text.style.ref($dinoToken.typography.detailL),
        ),
        DinoTextType.detailM(
          $text.style.ref($dinoToken.typography.detailM),
        ),
        DinoTextType.detailS(
          $text.style.ref($dinoToken.typography.detailS),
        ),
      ).applyVariants([type]);
}
