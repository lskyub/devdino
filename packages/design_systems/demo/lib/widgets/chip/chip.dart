import 'package:design_systems/b2b/components/chip/chip.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'WidgetsChip',
  type: B2bChip,
  path: '[widgets]/Chip',
)
Widget buildChipUseCase(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return SizedBox(
    width: size.width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const B2bChip(label: '알림 설정'),
        const SizedBox(height: 24),
        const B2bChip(label: '알림 설정', selected: true),
        const SizedBox(height: 24),
        B2bChip.setting(label: '알림 설정'),
        const SizedBox(height: 24),
        B2bChip.setting(label: '알림 설정'),
        const SizedBox(height: 24),
        B2bChip.arrowDown(label: '메뉴: 큰메뉴 전체', selected: true),
      ],
    ),
  );
}
