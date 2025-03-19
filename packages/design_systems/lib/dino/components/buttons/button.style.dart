import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:design_systems/dino/foundations/theme.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class B2bButtonStyle {
  B2bButtonStyle(this.type, this.size);

  final B2bButtonType type;
  final B2bButtonSize size;

  Style container(B2bButtonState state) {
    double horizontal = 24;
    double vertical = 16;
    double radius = 12;
    TextStyleToken textStyleToken = $dinoToken.typography.bodyXL;
    switch (size) {
      case B2bButtonSize.large:
        horizontal = 24;
        vertical = 14;
        textStyleToken = $dinoToken.typography.bodyL;
        break;
      case B2bButtonSize.medium:
        horizontal = 16;
        vertical = 10.5;
        textStyleToken = $dinoToken.typography.bodyM;
        break;
      case B2bButtonSize.small:
        horizontal = 12;
        vertical = 9.5;
        textStyleToken = $dinoToken.typography.bodyS;
        break;
      case B2bButtonSize.xsmall:
        horizontal = 12;
        vertical = 8.5;
        textStyleToken = $dinoToken.typography.bodyXS;
        break;
    }
    return Style(
      $box.padding.horizontal(horizontal),
      $box.padding.vertical(vertical),
      $box.borderRadius(radius),
      $text.textAlign.center(),
      $icon.size(20),
      $text.decoration.none(),

      /// Primary
      B2bButtonType.primary(
        $box.color.ref(state == B2bButtonState.pressed
            ? $dinoToken.color.brandBlingPink400
            : $dinoToken.color.brandBlingPink500),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($dinoToken.color.white),
            ),
        $on.press(
          $box.color.ref($dinoToken.color.brandBlingPink400),
        ),
        $on.disabled(
          $box.color.ref($dinoToken.color.brandBlingPink500),
          $text.style.color.ref($dinoToken.color.white),
        ),
      ),

      /// Primary - Light
      B2bButtonType.primaryLight(
        $box.color.ref(state == B2bButtonState.pressed
            ? $dinoToken.color.brandBlingPink400
            : $dinoToken.color.brandBlingPink500),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($dinoToken.color.white),
            ),
        $on.press(
          $box.color.ref($dinoToken.color.brandBlingPink400),
        ),
        $on.disabled(
          $box.color.ref($dinoToken.color.brandBlingPink500),
          $text.style.color.ref($dinoToken.color.white),
        ),
      ),

      /// Primary - Outlined
      B2bButtonType.primaryOutlined(
        $box.color.ref(state == B2bButtonState.pressed
            ? $dinoToken.color.brandBlingPink400
            : $dinoToken.color.white),
        $box.border(
          color: ColorRef($dinoToken.color.brandBlingPink500),
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($dinoToken.color.brandBlingPink500),
            ),
        $on.press(
          $box.color.ref($dinoToken.color.brandBlingPink400),
        ),
        $on.disabled(
          $box.border(
            color: ColorRef($dinoToken.color.brandBlingPink500),
            width: 1,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          $text.style.color.ref($dinoToken.color.white),
        ),
      ),

      /// Secondary
      B2bButtonType.secondary(
        $box.color.ref(state == B2bButtonState.pressed
            ? $dinoToken.color.brandBlingPink400
            : $dinoToken.color.white),
        $box.border(
          color: ColorRef($dinoToken.color.brandBlingPink500),
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($dinoToken.color.brandBlingPink500),
            ),
        $on.press(
          $box.color.ref($dinoToken.color.brandBlingPink400),
        ),
        $on.disabled(
          $box.border(
            color: ColorRef($dinoToken.color.brandBlingPink500),
            width: 1,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          $text.style.color.ref($dinoToken.color.white),
        ),
      ),

      /// Tertiary - Negative
      B2bButtonType.tertiaryNegative(
        $box.color.ref(state == B2bButtonState.pressed
            ? $dinoToken.color.brandBlingPink400
            : $dinoToken.color.brandBlingPink500),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref(state == B2bButtonState.pressed
                  ? $dinoToken.color.brandBlingPink400
                  : $dinoToken.color.white),
            ),
        $on.press(
          $box.color.ref($dinoToken.color.brandBlingPink400),
          $text.style.color.ref($dinoToken.color.white),
        ),
        $on.disabled(
          $box.color.ref($dinoToken.color.brandBlingPink500),
          $text.style.color.ref($dinoToken.color.white),
        ),
      ),

      /// Tertiary - Light Negative
      B2bButtonType.tertiaryNegativeLight(
        $box.color.ref($dinoToken.color.brandBlingPink400),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($dinoToken.color.white),
            ),
      ),

      /// Tertiary - Line Negative
      B2bButtonType.tertiaryNegativeOutlined(
        $box.color.ref(state == B2bButtonState.pressed
            ? $dinoToken.color.brandBlingPink400
            : $dinoToken.color.white),
        $box.border(
          color: ColorRef($dinoToken.color.brandBlingPink500),
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($dinoToken.color.brandBlingPink500),
            ),
      ),

      /// Tertiary - Postive
      B2bButtonType.tertiaryPostive(
        $box.color.ref($dinoToken.color.brandBlingPink400),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($dinoToken.color.white),
            ),
      ),
    ).applyVariants([type]);
  }
}
