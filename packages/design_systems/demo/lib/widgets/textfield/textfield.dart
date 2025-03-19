// import 'package:design_systems/b2b/components/textfield/textfield.dart';
// import 'package:design_systems/b2b/components/textfield/textfield.variant.dart';
// import 'package:design_systems/design_systems.dart';
// import 'package:flutter/material.dart';
// import 'package:widgetbook/widgetbook.dart';
// import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
// import 'package:nitrogen_flutter_svg/nitrogen_flutter_svg.dart';

// @widgetbook.UseCase(
//   name: 'WidgetsTextfield',
//   type: B2bTextField,
//   path: '[widgets]/Textfield',
// )
// Widget buildTextfieldUseCase(BuildContext context) {
//   return Container(
//     padding: const EdgeInsets.all(10),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         B2bTextField(
//           title: context.knobs.string(
//             label: 'Title',
//             initialValue: 'title',
//           ),
//           status: context.knobs.list(
//             label: 'Status',
//             options: B2bTextFieldStatus.values,
//             labelBuilder: (value) =>
//                 value.toString().split('.').last.replaceAll(')', ''),
//           ),
//           size: context.knobs.list(
//             label: 'Size',
//             options: B2bTextFieldSize.values,
//             labelBuilder: (value) =>
//                 value.toString().split('.').last.replaceAll(')', ''),
//           ),
//           onChanged: (p0) {
//             return null;
//           },
//           isError: context.knobs.boolean(label: 'Error Enable'),
//           errorText: context.knobs.string(
//             label: 'Error Text',
//             initialValue: '',
//           ),
//           hint: context.knobs.string(
//             label: 'Hint',
//             initialValue: 'hint',
//           ),
//           leading: context.knobs.boolean(label: 'Leading') ? TAssets.icons.checkboxOff.call(width: 24, height: 24) : null,
//           trailing: context.knobs.boolean(label: 'Trailing') ? TAssets.icons.checkboxOff.call(width: 24, height: 24) : null,
//         ),
//       ],
//     ),
//   );
// }
