import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:design_systems/dino/foundations/theme.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class DinoButtonStyle {
  DinoButtonStyle(this.type, this.size);

  final DinoButtonType type;
  final DinoButtonSize size;

  Style container({
    DinoButtonState? state,
    double? horizontalPadding,
    double? verticalPadding,
    double? setRadius,
    double? textSize,
    double? height,
    double? width,
    int? textMaxLines,
    FontWeight? fontWeight,
    ColorToken? textColor,
    ColorToken? borderColor,
    ColorToken? disabledTextColor,
    ColorToken? disabledBorderColor,
    ColorToken? pressedTextColor,
    ColorToken? pressedBorderColor,
    ColorToken? backgroundColor,
    ColorToken? disabledBackgroundColor,
    ColorToken? pressedBackgroundColor,
    LinearGradient? gradient,
  }) {
    double horizontal = horizontalPadding ?? 35;
    double vertical = verticalPadding ?? 16;
    double radius = setRadius ?? 12;
    return Style(
      $box.chain
        ..padding.horizontal(horizontal)
        ..padding.vertical(vertical)
        ..color.ref(backgroundColor ?? $dinoToken.color.primary)
        ..shapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(
              color: ColorRef(borderColor ?? $dinoToken.color.transparent),
              width: width ?? 0,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          gradient: gradient,
        ),
      $text.chain
        ..textAlign.center()
        ..maxLines(textMaxLines ?? 1)
        ..style.fontSize(textSize ?? 16)
        ..style.fontWeight(fontWeight ?? FontWeight.w600)
        ..decoration.none()
        ..style.fontFamily('Pretendard')
        ..style.color.ref(textColor ?? $dinoToken.color.white),
      DinoButtonSize.full(
        $flex.chain
          ..mainAxisAlignment.center()
          ..mainAxisSize.max(),
      ),
      DinoButtonSize.wrap(
        $flex.chain
          ..mainAxisAlignment.center()
          ..mainAxisSize.min(),
      ),
      DinoButtonType.solid(
        $on.press(
          $box.color.ref(state == DinoButtonState.pressed
              ? pressedBackgroundColor ?? $dinoToken.color.brandBlingPink400
              : backgroundColor ?? $dinoToken.color.blingGray100),
          $text.style.color
              .ref(pressedTextColor ?? $dinoToken.color.blingGray100),
        ),
        $on.disabled(
          $box.color.ref(state == DinoButtonState.disabled
              ? disabledBackgroundColor ?? $dinoToken.color.brandBlingPink500
              : backgroundColor ?? $dinoToken.color.brandBlingPink500),
          $text.style.color
              .ref(disabledTextColor ?? $dinoToken.color.blingGray100),
        ),
      ),
      DinoButtonType.outline(
        $on.press(
          $box.border(
            color: ColorRef(
                pressedBorderColor ?? $dinoToken.color.brandBlingPink500),
            width: 1,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          $box.color.ref(state == DinoButtonState.pressed
              ? pressedBackgroundColor ?? $dinoToken.color.brandBlingPink400
              : backgroundColor ?? $dinoToken.color.blingGray100),
          $text.style.color
              .ref(pressedTextColor ?? $dinoToken.color.blingGray100),
        ),
        $on.disabled(
          $box.border(
            color: ColorRef(
                disabledBorderColor ?? $dinoToken.color.brandBlingPink500),
            width: 1,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          $box.color.ref(state == DinoButtonState.disabled
              ? disabledBackgroundColor ?? $dinoToken.color.brandBlingPink500
              : backgroundColor ?? $dinoToken.color.blingGray100),
          $text.style.color
              .ref(disabledTextColor ?? $dinoToken.color.blingGray100),
        ),
      ),
      DinoButtonType.empty(
        $on.press(
          $box.color.ref($dinoToken.color.transparent),
          $text.style.color
              .ref(pressedTextColor ?? $dinoToken.color.blingGray100),
        ),
        $on.disabled(
          $box.color.ref($dinoToken.color.transparent),
          $text.style.color
              .ref(disabledTextColor ?? $dinoToken.color.blingGray100),
        ),
      ),
    ).applyVariants([type, size]);
  }
}
