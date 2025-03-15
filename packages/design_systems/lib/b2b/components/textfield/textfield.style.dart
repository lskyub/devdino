import 'package:design_systems/b2b/foundations/theme.dart';
import 'package:flutter/painting.dart';
import 'package:mix/mix.dart';

import 'package:design_systems/b2b/components/textfield/textfield.variant.dart';

class B2bTextfieldStyle {
  B2bTextfieldStyle(this.size, this.boder, this.status);

  final B2bTextFieldSize size;
  final B2bTextFieldBoder boder;
  final B2bTextFieldStatus status;

  Style container(
    Color defaultColor,
    Color writeColor,
    Color errorColor,
  ) =>
      Style(
        B2bTextFieldSize.small(
          // $box.padding.vertical(8),
          $box.width(116),
        ),
        B2bTextFieldBoder.box(
          $box.borderRadius(10),
          $box.border.strokeAlign(BorderSide.strokeAlignOutside),
          B2bTextFieldStatus.before(
            $box.chain
              ..border.width(0.7)
              ..border.color(defaultColor),
          ),
          B2bTextFieldStatus.write(
            $box.chain
              ..border.width(1)
              ..border.color(writeColor),
          ),
          B2bTextFieldStatus.error(
            $box.chain
              ..border.width(1)
              ..border.color(errorColor),
          ),
          B2bTextFieldStatus.after(
            $box.chain
              ..border.width(0.7)
              ..border.color(defaultColor),
          ),
        ),
      ).applyVariants([size, status, boder]);

  Style title() => Style(
        $box.padding.bottom.ref($b2bToken.space.s3),
        $text.style.ref($b2bToken.textStyle.headline1).merge(
              $text.style.color.ref($b2bToken.color.labelNomal),
            ),
      ).applyVariants([size, status, boder]);

  Style error() => Style(
        $box.padding.top.ref($b2bToken.space.s2),
        $text.style.ref($b2bToken.textStyle.body4regular).merge(
              $text.style.color.ref($b2bToken.color.statusNegative),
            ),
      ).applyVariants([size, status, boder]);
}
