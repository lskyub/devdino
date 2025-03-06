import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/dropdown/dropdown.variant.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class B2bDropdownStyle {
  B2bDropdownStyle(this.status);
  final B2bDropdownStatus status;

  Style container() => Style(
        $box.width(200),
        $with.flexible(fit: FlexFit.loose),
        $flex.mainAxisSize.min(),
        $box.padding.all(16),
        $box.borderRadius(10),
        $box.color.ref($b2bToken.color.white),
        B2bDropdownStatus.defalut(
          $box.chain
            ..border.width(1)
            ..border.strokeAlign(BorderSide.strokeAlignOutside)
            ..border.color.ref($b2bToken.color.buttonSecondaryBorder),
        ),
        B2bDropdownStatus.error(
          $box.chain
            ..border.width(2)
            ..border.strokeAlign(BorderSide.strokeAlignOutside)
            ..border.color.ref($b2bToken.color.statusNegative),
        ),
        B2bDropdownStatus.disabled(
          $box.chain
            ..border.width(1)
            ..border.strokeAlign(BorderSide.strokeAlignOutside)
            ..border.color.ref($b2bToken.color.buttonSecondaryBorder),
        ),
      ).applyVariants([status]);

  Style label() => Style(
        $flex.gap(1),
        $with.flexible(fit: FlexFit.tight),
        $text.maxLines(1),
        B2bDropdownStatus.defalut(
          $text.chain
            ..style.ref($b2bToken.textStyle.body2medium)
            ..style.color.ref($b2bToken.color.labelNomal),
        ),
        B2bDropdownStatus.error(
          $text.chain
            ..style.ref($b2bToken.textStyle.body2medium)
            ..style.color.ref($b2bToken.color.labelNomal),
        ),
        B2bDropdownStatus.disabled(
          $text.chain
            ..style.ref($b2bToken.textStyle.body2medium)
            ..style.color.ref($b2bToken.color.labelDisabled),
        ),
      ).applyVariants([status]);

  Style dropdownBox() => Style(
        $box.width(200),
        $with.flexible(fit: FlexFit.loose),
        $flex.mainAxisSize.min(),
        $box.borderRadius(10),
        $box.border.width(1),
        $box.border.strokeAlign(BorderSide.strokeAlignOutside),
        $box.color.ref($b2bToken.color.white),
        $box.border.color.ref($b2bToken.color.gray300),
      ).applyVariants([status]);

  Style dropdownlabel() => Style(
        $flex.gap(1),
        $with.flexible(fit: FlexFit.tight),
        $text.maxLines(1),
        $box.padding.only(
          left: 12,
          right: 8,
          top: 12,
          bottom: 12,
        ),
        $text.chain
          ..style.ref($b2bToken.textStyle.body2medium)
          ..style.color.ref($b2bToken.color.labelNomal)
          ..style.decoration.none(),
      ).applyVariants([status]);

  Style circular() => Style(
        $flex.gap(1),
        $box.height(18.3),
        $box.width(18.3),
        $box.borderRadius.all(9.15),
        $box.padding.all(2.5),
        $box.color.ref($b2bToken.color.primary),
      ).applyVariants([status]);

  Style error() => Style(
        $box.padding.only(left: 8, right: 8, top: 6, bottom: 6),
        $text.chain
          ..style.ref($b2bToken.textStyle.body4regular)
          ..style.color.ref($b2bToken.color.statusNegative),
      ).applyVariants([status]);
}
