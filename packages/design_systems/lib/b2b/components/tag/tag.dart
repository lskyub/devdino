import 'package:design_systems/b2b/components/tag/tag.style.dart';
import 'package:design_systems/b2b/components/tag/tag.variant.dart';
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

export './tag.style.dart';
export './tag.variant.dart';

class B2BTag extends StatelessWidget {
  final B2BTagStatus status;

  const B2BTag({super.key, required this.status});

  B2BTagStyle get $style => B2BTagStyle(status, $type);

  B2BTagType get $type => switch (status) {
        B2BTagStatus.vip || B2BTagStatus.first => B2BTagType.base,
        _ => B2BTagType.pill,
      };

  String get $text => switch (status) {
        B2BTagStatus.complete => '이용 완료',
        B2BTagStatus.noshow => '노쇼',
        B2BTagStatus.cancel => '취소',
        B2BTagStatus.payPositive => '결제 완료',
        B2BTagStatus.payNegative => '결제 취소',
        B2BTagStatus.vip => 'VIP',
        B2BTagStatus.first => '첫 방문',
        _ => '',
      };

  @override
  Widget build(BuildContext context) =>
      Box(style: $style.container(), child: StyledText($text));
}
