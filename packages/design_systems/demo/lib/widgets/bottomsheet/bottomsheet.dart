import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/bottomsheet/bottomsheet.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Import the widget from your app

@widgetbook.UseCase(
  name: 'WidgetsBottomSheet',
  type: B2bBottomSheet,
  path: '[widgets]/BottomSheet',
)
Widget buildCoolButtonUseCase(BuildContext context) {
  return B2bBottomSheet(
    title: '알림 설정',
    onClosePressed: () {},
    content: const SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              B2bSectionTitle(text: '공간/층'),
              B2bDivider(),
              B2bSectionTitle(text: '카테고리/메뉴'),
            ],
          ),
        ),
      ),
    ),
    footer: Flex(
      direction: Axis.horizontal,
      children: [
        SizedBox(
          width: 180,
          child: B2bButton(
            type: B2bButtonType.secondary,
            size: B2bButtonSize.large,
            title: '초기화',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: B2bButton(
            type: B2bButtonType.primary,
            size: B2bButtonSize.large,
            title: '알림 설정 적용',
            onTap: () {},
          ),
        ),
      ],
    ),
  );
}
