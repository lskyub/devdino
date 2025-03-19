// import 'package:design_systems/b2b/components/buttons/button.dart';
// import 'package:design_systems/b2b/components/buttons/button.variant.dart';
// import 'package:design_systems/b2b/components/chip/chip.dart';
// import 'package:design_systems/b2b/components/chip/chip.variant.dart';
// import 'package:design_systems/b2b/components/dialog/dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:widgetbook/widgetbook.dart';
// import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// @widgetbook.UseCase(
//   name: 'WidgetsButton',
//   type: B2bDialog,
//   path: '[widgets]/Button',
// )
// Widget buildButtonPrimaryUseCase(BuildContext context) {
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Text(
//         'Primary Button',
//         style: TextStyle(fontSize: 30),
//       ),
//       const SizedBox(height: 24),
//       const Text(
//         'Type = Primary, Light Primary, Outlined Primary',
//         style: TextStyle(fontSize: 20),
//       ),
//       const SizedBox(height: 10),
//       Row(
//         children: [
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.primary,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.primaryLight,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.primaryOutlined,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//         ],
//       ),
//       const SizedBox(height: 24),
//       const Text(
//         'Size = Large, Medium, Small',
//         style: TextStyle(fontSize: 20),
//       ),
//       const SizedBox(height: 10),
//       Row(
//         children: [
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.primary,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.primary,
//             size: B2bButtonSize.medium,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.primary,
//             size: B2bButtonSize.small,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//         ],
//       ),
//       const SizedBox(height: 24),
//       const Text(
//         'State = Disable, Enabled, Pressed',
//         style: TextStyle(fontSize: 20),
//       ),
//       const SizedBox(height: 10),
//       Row(
//         children: [
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.primary,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//             state: B2bButtonState.disabled,
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.primary,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.primary,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//             state: B2bButtonState.pressed,
//           ),
//         ],
//       )
//     ],
//   );
// }

// @widgetbook.UseCase(
//   name: 'WidgetsButton',
//   type: B2bDialog,
//   path: '[widgets]/Button',
// )
// Widget buildButtonSecondaryUseCase(BuildContext context) {
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Text(
//         'Secondary Button',
//         style: TextStyle(fontSize: 30),
//       ),
//       const SizedBox(height: 24),
//       const Text(
//         'Type = Secondary, Round',
//         style: TextStyle(fontSize: 20),
//       ),
//       const SizedBox(height: 10),
//       Row(
//         children: [
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.secondary,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bChip(
//               label:
//                   context.knobs.string(label: 'label', initialValue: 'Label'),
//               size: B2bChipSize.medium),
//         ],
//       ),
//       const SizedBox(height: 24),
//       const Text(
//         'Size = Large, Medium, Small',
//         style: TextStyle(fontSize: 20),
//       ),
//       const SizedBox(height: 10),
//       Row(
//         children: [
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.secondary,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.secondary,
//             size: B2bButtonSize.medium,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.secondary,
//             size: B2bButtonSize.small,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//         ],
//       ),
//       const SizedBox(height: 10),
//       Row(
//         children: [
//           const SizedBox(width: 10),
//           B2bChip(
//               label:
//                   context.knobs.string(label: 'label', initialValue: 'Label')),
//           const SizedBox(width: 10),
//           B2bChip(
//             label: context.knobs.string(label: 'label', initialValue: 'Label'),
//             size: B2bChipSize.small,
//           ),
//         ],
//       ),
//       const SizedBox(height: 24),
//       const Text(
//         'Icon = Right Icon on, Left Icon on, Icon off',
//         style: TextStyle(fontSize: 20),
//       ),
//       const SizedBox(height: 10),
//       Row(
//         children: [
//           const SizedBox(width: 10),
//           B2bChip.setting(
//               label:
//                   context.knobs.string(label: 'label', initialValue: 'Label')),
//           const SizedBox(width: 10),
//           B2bChip.arrowDown(
//               label:
//                   context.knobs.string(label: 'label', initialValue: 'Label')),
//           const SizedBox(width: 10),
//           B2bChip(
//               label:
//                   context.knobs.string(label: 'label', initialValue: 'Label')),
//         ],
//       ),
//       const SizedBox(height: 24),
//       const Text(
//         'State = Disable, Enabled, Pressed, Activer',
//         style: TextStyle(fontSize: 20),
//       ),
//       const SizedBox(height: 10),
//       Row(
//         children: [
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.secondary,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//             state: B2bButtonState.disabled,
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.secondary,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.secondary,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//             state: B2bButtonState.pressed,
//           ),
//           const SizedBox(width: 10),
//           B2bChip(
//             label: context.knobs.string(label: 'label', initialValue: 'Label'),
//             selected: true,
//           ),
//         ],
//       )
//     ],
//   );
// }

// @widgetbook.UseCase(
//   name: 'WidgetsButton',
//   type: B2bDialog,
//   path: '[widgets]/Button',
// )
// Widget buildButtonTertiaryUseCase(BuildContext context) {
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Text(
//         'Primary Button',
//         style: TextStyle(fontSize: 30),
//       ),
//       const SizedBox(height: 24),
//       const Text(
//         'Type = Negative, Negative Light, Negative Outlined, Postive',
//         style: TextStyle(fontSize: 20),
//       ),
//       const SizedBox(height: 10),
//       Row(
//         children: [
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.tertiaryNegative,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.tertiaryNegativeLight,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.tertiaryNegativeOutlined,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.tertiaryPostive,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//         ],
//       ),
//       const SizedBox(height: 24),
//       const Text(
//         'Size = Large, Medium, Small, Xsmall',
//         style: TextStyle(fontSize: 20),
//       ),
//       const SizedBox(height: 10),
//       Row(
//         children: [
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.tertiaryNegative,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.tertiaryNegative,
//             size: B2bButtonSize.medium,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.tertiaryNegative,
//             size: B2bButtonSize.small,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.tertiaryNegative,
//             size: B2bButtonSize.xsmall,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//         ],
//       ),
//       const SizedBox(height: 24),
//       const Text(
//         'State = Disable, Enabled, Pressed',
//         style: TextStyle(fontSize: 20),
//       ),
//       const SizedBox(height: 10),
//       Row(
//         children: [
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.tertiaryNegative,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//             state: B2bButtonState.disabled,
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.tertiaryNegative,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//           ),
//           const SizedBox(width: 10),
//           B2bButton(
//             type: B2bButtonType.tertiaryNegative,
//             size: B2bButtonSize.large,
//             title: context.knobs.string(label: 'label', initialValue: 'Label'),
//             state: B2bButtonState.pressed,
//           ),
//         ],
//       )
//     ],
//   );
// }
