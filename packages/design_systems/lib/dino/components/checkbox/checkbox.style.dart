import 'dart:ui';

import 'package:design_systems/dino/components/checkbox/checkbox.variant.dart';
import 'package:design_systems/dino/foundations/theme.dart';
import 'package:mix/mix.dart';

class B2bCheckBoxStyle {
  B2bCheckBoxStyle(this.state);

  final B2bCheckBoxState state;

  Style container() => Style(
        $text.style(
          color: ColorRef($dinoToken.color.blingGray700),
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ).applyVariant(state);
}
