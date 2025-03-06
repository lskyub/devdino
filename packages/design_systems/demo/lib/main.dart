import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// This file does not exist yet,
// it will be generated in the next step
import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MixTheme(
      data: b2bTheme,
      child: Widgetbook.material(
        // The [directories] variable does not exist yet,
        // it will be generated in the next step
        directories: directories,
        themeMode: ThemeMode.light,
      ),
    );
  }
}
