import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import 'package:design_systems/b2b/components/toast/toast.variant.dart';

class B2bToastStyle {
  B2bToastStyle(this.status);
  final B2bToastStatus status;

  Style container(double maxWidth) => Style(
        $box.maxWidth(maxWidth),
        $box.padding.horizontal.ref($b2bToken.space.s7),
        $box.padding.vertical.ref($b2bToken.space.s5),
        $with.flexible(fit: FlexFit.loose),
        $flex.mainAxisSize.min(),
        $flex.crossAxisAlignment.start(),
        B2bToastStatus.success(
          $box.chain..borderRadius(24),
          $box.color.ref($b2bToken.color.toastStatus),
        ),
        B2bToastStatus.fail(
          $box.chain..borderRadius(24),
          $box.color.ref($b2bToken.color.toastStatus),
        ),
        B2bToastStatus.system(
          $box.chain..borderRadius(20),
          $box.color.ref($b2bToken.color.toastSystem),
        ),
      ).applyVariants([status]);

  Style message() => Style(
        $flex.wrap.flexible(),
        $with.flexible(fit: FlexFit.loose),
        B2bToastStatus.success(
          $text.style.ref($b2bToken.textStyle.title2regular).merge(
                $text.style.color.ref($b2bToken.color.labelNetural),
              ),
        ),
        B2bToastStatus.fail(
          $text.style.ref($b2bToken.textStyle.title2regular).merge(
                $text.style.color.ref($b2bToken.color.labelNetural),
              ),
        ),
        B2bToastStatus.system(
          $text.style.ref($b2bToken.textStyle.title1medium).merge(
                $text.style.color.ref($b2bToken.color.labelNetural),
              ),
        ),
      ).applyVariants([status]);

  Style circular() => Style(
        $flex.gap(1),
        $box.height(33),
        $box.width(33),
        $box.borderRadius.all(16.5),
        $box.padding.all(4.5),
      ).applyVariants([status]);
}
