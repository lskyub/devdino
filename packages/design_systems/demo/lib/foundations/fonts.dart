import 'package:design_systems/b2b/components/text/text.variant.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:design_systems/b2b/components/text/text.dart';

// Import the widget from your app

@widgetbook.UseCase(
  name: 'FoundationsFonts',
  type: Container,
  path: '[foundations]/fonts',
)
Widget buildTypographyUseCase(BuildContext context) {
  TableRow row(List<Widget> widgets) {
    final children = List<Widget>.from(widgets);
    for (var i = 0; i < children.length; i++) {
      children[i] = TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: children[i],
      );
    }
    return TableRow(
      children: children,
    );
  }

  List<TableRow> rowGroup(
      String name, String size, String lineHeight, B2bTextType type) {
    return [
      row([
        Text(name),
        Text(size),
        const Text('bold'),
        Text(lineHeight),
        B2bText.bold(
          type: type,
          text: context.knobs.string(label: 'text', initialValue: 'text'),
        ),
      ]),
      row([
        const Text(''),
        Text(size),
        const Text('medium'),
        Text(lineHeight),
        B2bText.medium(
          type: type,
          text: context.knobs.string(
            label: 'text',
            initialValue: 'text',
          ),
        ),
      ]),
      row([
        const Text(''),
        Text(size),
        const Text('regular'),
        Text(lineHeight),
        B2bText.regular(
          type: type,
          text: context.knobs.string(
            label: 'text',
            initialValue: 'text',
          ),
        ),
      ]),
    ];
  }

  Table table(List<TableRow> children) {
    return Table(
      border: const TableBorder(
          bottom: BorderSide(color: Color.fromARGB(255, 238, 238, 238))),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(4),
      },
      children: children,
    );
  }

  List<Widget> header(String title) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: B2bText.bold(type: B2bTextType.headerline2, text: title),
      ),
      table(
        [
          row(
            [
              const Text('name'),
              const Text('size'),
              const Text('weight'),
              const Text('line-height'),
              const Text('sample'),
            ],
          ),
        ],
      )
    ];
  }

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...header('Display'),
        table([
          ...rowGroup('Display 1', '72px', '120%', B2bTextType.display),
        ]),
        ...header('Headerline'),
        table([
          ...rowGroup('Headerline 1', '48px', '130%', B2bTextType.headerline1),
        ]),
        table([
          ...rowGroup('Headerline 2', '36px', '130%', B2bTextType.headerline2),
        ]),
        ...header('Title'),
        table([
          ...rowGroup('Title 1', '28px', '140%', B2bTextType.title1),
        ]),
        table([
          ...rowGroup('Title 2', '24px', '150%', B2bTextType.title2),
        ]),
        table([
          ...rowGroup('Title 3', '22px', '150%', B2bTextType.title3),
        ]),
        ...header('Body'),
        table([
          ...rowGroup('Body 1', '20px', '150%', B2bTextType.body1),
        ]),
        table([
          ...rowGroup('Body 2', '18px', '150%', B2bTextType.body2),
        ]),
        table([
          ...rowGroup('Body 3', '16px', '150%', B2bTextType.body3),
        ]),
        table([
          ...rowGroup('Body 4', '15px', '150%', B2bTextType.body4),
        ]),
        ...header('Caption'),
        table([
          ...rowGroup('Caption 1', '14px', '160%', B2bTextType.caption1),
        ]),
        table([
          ...rowGroup('Caption 2', '12px', '160%', B2bTextType.caption2),
        ]),
        const SizedBox(height: 16),
      ],
    ),
  );
}
