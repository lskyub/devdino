import 'package:design_systems/b2b/components/dropdown/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'WidgetsDropdown',
  type: B2bDropdown,
  path: '[widgets]/ropdown',
)
Widget buildDropdownUseCase(BuildContext context) {
  var label = context.knobs.string(label: 'Lable', initialValue: 'Label');
  var length = context.knobs.string(label: 'List Size', initialValue: '1');
  length = length.isEmpty ? '1' : length;
  List<String> items = ['$label 0'];
  try {
    items = List.generate(int.parse(length), (index) => '$label $index');
  } catch (e) {}
  var visible = 3;
  try {
    visible = int.parse(
        context.knobs.string(label: 'Max Visible Count', initialValue: '3'));
  } catch (e) {}
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 16),
        child: B2bDropdown(
          defaultValue: label,
          dropdownList: items,
          isEnabled:
              context.knobs.boolean(label: 'Enabled', initialValue: true),
          isError: context.knobs.boolean(label: 'Error', initialValue: true),
          errorText:
              context.knobs.string(label: 'Error Text', initialValue: ''),
          visibleCount: visible,
        ),
      ),
    ],
  );
}
