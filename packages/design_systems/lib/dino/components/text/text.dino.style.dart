import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:design_systems/dino/foundations/theme.dart';
import 'package:mix/mix.dart';
import 'package:flutter/material.dart';

class DinoTextStyle {
  DinoTextStyle(this.align);

  final DinoTextAlign align;

  Style style(ColorToken? color, double? fontSize, FontWeight? fontWeight) =>
      Style(
        $text.color.ref(color ?? $dinoToken.color.black),
        $text.style.fontSize(fontSize ?? 16),
        $text.style.fontWeight(fontWeight ?? FontWeight.w400),
        $text.style.fontFamily('Pretendard'),
        $text.overflow.ellipsis(),
        DinoTextAlign.left(
          $text.textAlign.left(),
        ),
        DinoTextAlign.right(
          $text.textAlign.right(),
        ),
        DinoTextAlign.center(
          $text.textAlign.center(),
        ),
      ).applyVariants([align]);
}
