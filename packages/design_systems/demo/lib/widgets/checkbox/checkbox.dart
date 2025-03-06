import 'package:design_systems/b2b/components/checkbox/checkbox.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'WidgetsCheckBox',
  type: B2bCheckBox,
  path: '[widgets]/CheckBox',
)
Widget buildCheckboxUseCase(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return SizedBox(
    width: size.width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        B2bCheckBox(
          value: true,
          onChanged: (bool value) {},
          label: '전체',
        ),
        const SizedBox(height: 20),
        B2bCheckBox(
          value: false,
          onChanged: (bool value) {},
          label: '큰메뉴',
        ),
        const SizedBox(height: 20),
        B2bCheckBox.chevron(
          value: false,
          expaned: false,
          label: '큰메뉴',
          onChanged: (bool value) {},
          onLabelClick: () {},
        ),
      ],
    ),
  );
}
