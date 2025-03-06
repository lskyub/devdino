import 'package:design_systems/b2b/components/toast/toast.dart';
import 'package:design_systems/b2b/components/toast/toast.variant.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'WidgetsToast',
  type: B2bToast,
  path: '[widgets]/Toast',
)
Widget buildToastUseCase(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      B2bToast(
          status: context.knobs.list(
            label: 'Status',
            options: B2bToastStatus.values,
            labelBuilder: (value) =>
                value.toString().split('.').last.replaceAll(')', ''),
          ),
          message:
              context.knobs.string(label: 'message', initialValue: 'Message')),
    ],
  );
}
 