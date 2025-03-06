import 'package:design_systems/b2b/foundations/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

class B2bDivider extends StatelessWidget {
  const B2bDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Box(
      style: Style($box.margin.vertical(32)),
      child: Box(
        style: Style(
          $box.height(1),
          $box.width.infinity(),
          $box.color.ref(
            $b2bToken.color.gray200,
          ),
        ),
      ),
    );
  }
}
