import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:design_systems/b2b/components/dialog/dialog.dart';
import 'package:design_systems/b2b/components/dialog/dialog.variant.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'WidgetsDialog',
  type: B2bDialog,
  path: '[widgets]/Dialog',
)
Widget buildDialogUseCase(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return Container(
    color: Colors.black54,
    width: size.width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        B2bDialog(
          type: context.knobs.list(
              label: 'Dialog type',
              options: [
                B2bDialogType.alert,
                B2bDialogType.confirm,
                B2bDialogType.notice
              ],
              labelBuilder: (value) =>
                  value.toString().split('.').last.replaceAll(')', '')),
          title: context.knobs.string(
              label: 'title',
              initialValue: '타이틀 영역입니다.\n타이틀 영역은 두줄까지 작성 가능합니다.',
              maxLines: 2),
          subTitle: context.knobs.string(
              label: 'subTitle',
              initialValue: '서브타이틀 영역입니다.\n서브텍스트 또한 두줄까지 작성 가능합니다',
              maxLines: 2),
          confirmLabel:
              context.knobs.string(label: 'confirmLabel', initialValue: '업데이트'),
          cancelLabel:
              context.knobs.string(label: 'cancelLabel', initialValue: '나중에'),
          buttonType: context.knobs.list(
              label: 'button type',
              options: [B2bButtonType.primary, B2bButtonType.tertiaryNegative],
              labelBuilder: (value) =>
                  value.toString().split('.').last.replaceAll(')', '')),
          imageUrl: context.knobs.string(label: 'imageUrl', initialValue: ''),
          imagePosition: context.knobs.list(
              label: 'imagePosition',
              options: [
                B2bDialogImagePosition.bottom,
                B2bDialogImagePosition.top,
              ],
              labelBuilder: (value) =>
                  value.toString().split('.').last.replaceAll(')', '')),
          onConfirm: () {},
          onCancel: () {},
        ),
      ],
    ),
  );
}
