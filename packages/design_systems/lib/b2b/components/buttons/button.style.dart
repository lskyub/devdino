import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:design_systems/b2b/foundations/theme.dart';
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
    TextStyleToken textStyleToken = $b2bToken.textStyle.body1bold;
    switch (size) {
      case B2bButtonSize.large:
        horizontal = 24;
        vertical = 14;
        textStyleToken = $b2bToken.textStyle.body1bold;
        break;
      case B2bButtonSize.medium:
        horizontal = 16;
        vertical = 10.5;
        textStyleToken = $b2bToken.textStyle.body2bold;
        break;
      case B2bButtonSize.small:
        horizontal = 12;
        vertical = 9.5;
        textStyleToken = $b2bToken.textStyle.body3bold;
        break;
      case B2bButtonSize.xsmall:
        horizontal = 12;
        vertical = 8.5;
        textStyleToken = $b2bToken.textStyle.body3bold;
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
            ? $b2bToken.color.buttonPrimaryPressed
            : $b2bToken.color.buttonPrimaryEnabled),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($b2bToken.color.labelNetural),
            ),
        $on.press(
          $box.color.ref($b2bToken.color.buttonPrimaryPressed),
        ),
        $on.disabled(
          $box.color.ref($b2bToken.color.buttonPrimaryDisabled),
          $text.style.color.ref($b2bToken.color.labelDisabled),
        ),
      ),

      /// Primary - Light
      B2bButtonType.primaryLight(
        $box.color.ref(state == B2bButtonState.pressed
            ? $b2bToken.color.buttonPrimaryLightPressed
            : $b2bToken.color.buttonPrimaryLightEnabled),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($b2bToken.color.labelPrimary),
            ),
        $on.press(
          $box.color.ref($b2bToken.color.buttonPrimaryLightPressed),
        ),
        $on.disabled(
          $box.color.ref($b2bToken.color.buttonPrimaryLightDisabled),
          $text.style.color.ref($b2bToken.color.labelDisabled),
        ),
      ),

      /// Primary - Outlined
      B2bButtonType.primaryOutlined(
        $box.color.ref(state == B2bButtonState.pressed
            ? $b2bToken.color.buttonPrimaryLightPressed
            : $b2bToken.color.white),
        $box.border(
          color: ColorRef($b2bToken.color.buttonPrimaryBorder),
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($b2bToken.color.primary),
            ),
        $on.press(
          $box.color.ref($b2bToken.color.buttonPrimaryLightPressed),
        ),
        $on.disabled(
          $box.border(
            color: ColorRef($b2bToken.color.borderNomal),
            width: 1,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          $text.style.color.ref($b2bToken.color.labelDisabled),
        ),
      ),

      /// Secondary
      B2bButtonType.secondary(
        $box.color.ref(state == B2bButtonState.pressed
            ? $b2bToken.color.buttonSecondaryPressed
            : $b2bToken.color.backgroundNomal),
        $box.border(
          color: ColorRef($b2bToken.color.buttonSecondaryBorder),
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($b2bToken.color.labelNomal),
            ),
        $on.press(
          $box.color.ref($b2bToken.color.buttonSecondaryPressed),
        ),
        $on.disabled(
          $box.border(
            color: ColorRef($b2bToken.color.buttonSecondaryBorder),
            width: 1,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          $text.style.color.ref($b2bToken.color.labelNeturalDisabled),
        ),
      ),

      /// Tertiary - Negative
      B2bButtonType.tertiaryNegative(
        $box.color.ref(state == B2bButtonState.pressed
            ? $b2bToken.color.statusNegativelight
            : $b2bToken.color.statusNegative),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref(state == B2bButtonState.pressed
                  ? $b2bToken.color.statusNegative
                  : $b2bToken.color.labelNetural),
            ),
        $on.press(
          $box.color.ref($b2bToken.color.statusNegativelight),
          $text.style.color.ref($b2bToken.color.statusNegative),
        ),
        $on.disabled(
          $box.color.ref($b2bToken.color.backgroundNetural3),
          $text.style.color.ref($b2bToken.color.labelDisabled),
        ),
      ),

      /// Tertiary - Light Negative
      B2bButtonType.tertiaryNegativeLight(
        $box.color.ref($b2bToken.color.statusNegativelight),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($b2bToken.color.statusNegative),
            ),
      ),

      /// Tertiary - Line Negative
      B2bButtonType.tertiaryNegativeOutlined(
        $box.color.ref(state == B2bButtonState.pressed
            ? $b2bToken.color.statusNegative
            : $b2bToken.color.backgroundNomal),
        $box.border(
          color: ColorRef($b2bToken.color.statusNegative),
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($b2bToken.color.statusNegative),
            ),
      ),

      /// Tertiary - Postive
      B2bButtonType.tertiaryPostive(
        $box.color.ref($b2bToken.color.statusPositive),
        $text.maxLines(1),
        $text.style.ref(textStyleToken).merge(
              $text.style.color.ref($b2bToken.color.labelNetural),
            ),
      ),
    ).applyVariants([type]);
  }
}
