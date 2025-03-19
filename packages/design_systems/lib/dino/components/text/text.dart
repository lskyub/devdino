import 'package:design_systems/dino/components/text/text.style.dart';
import 'package:design_systems/dino/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import 'package:design_systems/dino/foundations/theme.dart';

class DinoText extends StatelessWidget {
  final String? text;
  final Color? color;
  final DinoTextType type;
  const DinoText({
    required this.type,
    this.text,
    this.color,
    super.key,
  });

  DinoTextStyle get $style => DinoTextStyle(type);

  @override
  Widget build(BuildContext context) {
    return StyledText(
      text ?? '',
      style: $style.style().merge(Style(
        $text.color(color ?? $dinoToken.color.black.resolve(context)),
      )),
    );
  }
}
