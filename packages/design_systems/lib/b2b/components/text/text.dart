import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/text/text.style.dart';
import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class B2bText extends StatelessWidget {
  final B2bTextType type;
  final B2bTextWeight weight;
  final String? text;
  final Color? color;
  const B2bText({
    required this.type,
    required this.weight,
    this.text,
    this.color,
    super.key,
  });

  B2bTextStyle get $style => B2bTextStyle(weight);

  @override
  Widget build(BuildContext context) {
    return StyledText(
      text ?? '',
      style: $style.style(type).merge(Style(
            $text.color(color ?? $b2bToken.color.primary.resolve(context)),
          )),
    );
  }

  factory B2bText.bold(
      {required B2bTextType type, required String text, Color? color}) {
    return B2bText(
      type: type,
      weight: B2bTextWeight.bold,
      text: text,
      color: color,
    );
  }

  factory B2bText.medium(
      {required B2bTextType type, required String text, Color? color}) {
    return B2bText(
      type: type,
      weight: B2bTextWeight.medium,
      text: text,
      color: color,
    );
  }

  factory B2bText.regular(
      {required B2bTextType type, required String text, Color? color}) {
    return B2bText(
      type: type,
      weight: B2bTextWeight.regular,
      text: text,
      color: color,
    );
  }
}
