import 'package:design_systems/b2b/foundations/theme.dart';
import 'package:flutter/painting.dart';
import 'package:mix/mix.dart';

import 'package:design_systems/b2b/components/tag/tag.variant.dart';

class B2BTagStyle {
  B2BTagStyle(this.type, this.size);

  final B2BTagStatus type;
  final B2BTagType size;

  Style container() => Style(
        $box.borderRadius(8),
        $box.padding.horizontal(6),
        $box.padding.vertical(4),
        $box.border.width(1),
        $box.border.strokeAlign(BorderSide.strokeAlignInside),
        $text.style.fontSize(14),
        $text.style.fontWeight(FontWeight.w700),

        B2BTagType.base(),

        B2BTagType.pill(
          $box.borderRadius(25),
          $box.padding.horizontal(10),
        ),

        // 이용 완료
        B2BTagStatus.complete(
          $box.color.ref($b2bToken.color.gray100),
          $box.border.color.ref($b2bToken.color.gray100),
          $text.style.color.ref($b2bToken.color.green500),
        ),

        // 노쇼
        B2BTagStatus.noshow(
          $box.color.ref($b2bToken.color.gray200),
          $box.border.color.ref($b2bToken.color.gray200),
          $text.style.color.ref($b2bToken.color.gray700),
        ),

        // 취소
        B2BTagStatus.cancel(
          $box.color.ref($b2bToken.color.pink100),
          $box.border.color.ref($b2bToken.color.pink100),
          $text.style.color.ref($b2bToken.color.pink500),
        ),

        B2BTagStatus.payPositive(
          $box.color.ref($b2bToken.color.green500),
          $box.border.color.ref($b2bToken.color.green500),
          $text.style.color.ref($b2bToken.color.white),
          $text.style.fontSize(16),
        ),

        B2BTagStatus.payNegative(
          $box.color.ref($b2bToken.color.gray400),
          $box.border.color.ref($b2bToken.color.gray400),
          $text.style.color.ref($b2bToken.color.white),
          $text.style.fontSize(16),
        ),

        // 사용자 VIP
        B2BTagStatus.vip(
          $box.color.ref($b2bToken.color.violet100),
          $box.border.color.ref($b2bToken.color.violet200),
          $text.style.color.ref($b2bToken.color.violet400),
        ),
        // 사용자 첫방문
        B2BTagStatus.first(
          $box.color.ref($b2bToken.color.pink100),
          $box.border.color.ref($b2bToken.color.pink200),
          $text.style.color.ref($b2bToken.color.pink600),
        ),
      ).applyVariants([type, size]);
  Style label() => Style().applyVariants([type, size]);
}
