import 'package:design_systems/dino/components/text/text.dino.style.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class DinoText extends StatelessWidget {
  final String? text;
  final ColorToken? color;
  final DinoTextAlign align;
  final double? fontSize;
  final FontWeight? fontWeight;
  const DinoText({
    this.align = DinoTextAlign.left,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    super.key,
  });

  DinoTextStyle get $style => DinoTextStyle(align);

  @override
  Widget build(BuildContext context) {
    return StyledText(
      text ?? '',
      style: $style.style(color, fontSize, fontWeight),
    );
  }

  factory DinoText.custom({
    required String text,
    DinoTextAlign textAlign = DinoTextAlign.left,
    ColorToken? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return DinoText(
        text: text, color: color, align: textAlign, fontSize: fontSize, fontWeight: fontWeight);
  }
}
