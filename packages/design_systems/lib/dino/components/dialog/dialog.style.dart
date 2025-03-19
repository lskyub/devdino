import 'package:design_systems/dino/components/dialog/dialog.variant.dart';
import 'package:design_systems/dino/foundations/theme.dart';
import 'package:mix/mix.dart';
import 'package:flutter/material.dart';

class B2bDialogStyle {
  B2bDialogStyle(this.type, this.imagePosition);

  final B2bDialogType type;
  final B2bDialogImagePosition imagePosition;

  Style container(Size size) {
    return Style(
      $box.padding.top(24),
      $box.padding.bottom(24),
      $box.padding.right(24),
      $box.padding.left(24),
      $box.borderRadius(24),
      $box.color.white(),
      $flex.mainAxisSize.min(),
      $box.constraints.maxWidth(size.width - 32),
      $box.constraints.maxHeight(size.height - 96),
    ).applyVariants([type]);
  }
  // Style container() {
  //   return Style(
  //     $box.width(588),
  //     $box.height(588),
  //     $box.maxHeight(588),
  //     $box.padding.top(24),
  //     $box.padding.bottom(24),
  //     $box.padding.right(24),
  //     $box.padding.left(24),
  //     $box.borderRadius(24),
  //     $box.color.white(),
  //   ).applyVariants([type, imagePosition]);
  // }

  Style title() {
    return Style(
      B2bDialogImagePosition.top(
        $box.padding.top(24),
      ),
      B2bDialogImagePosition.bottom(
        $box.padding.top(16),
      ),
      $text.textAlign.center(),
      $text.maxLines(2),
      $text.softWrap(true),
      $text.style.ref($dinoToken.typography.headingXS).merge(
            $text.style.color.ref($dinoToken.color.blingGray700),
          ),
    ).applyVariants([type, imagePosition]);
  }

  Style subTitle() {
    return Style(
      $box.padding.top(24),
      $text.maxLines(2),
      $text.textAlign.center(),
      $text.softWrap(true),
      $text.style.ref($dinoToken.typography.bodyS).merge(
            $text.style.color.ref($dinoToken.color.blingGray700),
          ),
    ).applyVariants([type, imagePosition]);
  }
}
