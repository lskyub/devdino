import 'package:design_systems/b2b/foundations/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

class B2bSectionTitle extends StatelessWidget {
  final String text;
  const B2bSectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Box(
      style: Style($box.margin.bottom(20)),
      child: StyledText(
        text,
        style: Style(
          $text.style.color.ref($b2bToken.color.gray700),
          $text.style.fontSize(22),
          $text.style.fontWeight.w700(),
        ),
      ),
    );
  }
}
