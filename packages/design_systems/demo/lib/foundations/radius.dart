import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// Import the widget from your app

@widgetbook.UseCase(
  name: 'FoundationsRadius',
  type: Container,
  path: '[foundations]/radius',
)
Widget buildCoolButtonUseCase(BuildContext context) {
  return TextButton(
    onPressed: () {},
    child: const Text('TEST'),
  );
}
