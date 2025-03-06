import 'dart:ui';

import 'package:design_systems/b2b/components/checkbox/checkbox.variant.dart';
import 'package:design_systems/b2b/foundations/theme.dart';
import 'package:mix/mix.dart';

class B2bCheckBoxStyle {
  B2bCheckBoxStyle(this.state);

  final B2bCheckBoxState state;

  Style container() => Style(
        $text.style(
          color: ColorRef($b2bToken.color.gray700),
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ).applyVariant(state);
}
