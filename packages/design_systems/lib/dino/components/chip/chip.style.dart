import 'package:design_systems/dino/components/chip/chip.variant.dart';
import 'package:design_systems/dino/foundations/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

class B2bChipStyle {
  final B2bChipSize size;
  final B2bChipVariant variant;
  const B2bChipStyle(this.variant, this.size);

  Style container() {
    final color = $dinoToken.color;
    double height = 40;
    switch (size) {
      case B2bChipSize.medium:
        height = 48;
        break;
      case B2bChipSize.small:
        height = 40;
        break;
    }
    return Style(
      $box.minWidth(80),
      $box.height(height),
      $box.padding.horizontal(16),
      $box.borderRadius.all(50),
      $box.color.white(),
      $flex.gap(4),
      $box.alignment.center(),
      $text.textAlign.center(),
      B2bChipVariant.base(
        $box.border(
          color: ColorRef(color.blingGray300),
          strokeAlign: BorderSide.strokeAlignOutside,
          width: 1,
        ),
        $text.style.color.ref(color.blingGray700),
      ),
      B2bChipVariant.selected(
        $box.color.ref(color.blingGray700),
        $text.style.color.ref(color.white),
        $box.border(
          color: ColorRef(color.blingGray700),
          strokeAlign: BorderSide.strokeAlignOutside,
          width: 1,
        ),
      ),
    ).applyVariant(variant);
  }

  Style children() => Style($flex.gap(4));

  Style label() => Style(
        B2bChipVariant.base(
          $text.style(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: ColorRef($dinoToken.color.blingGray700),
            height: 0,
          ),
        ),
        B2bChipVariant.selected(
          $text.style(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: ColorRef($dinoToken.color.white),
            height: 0,
          ),
        ),
      ).applyVariant(variant);
}
