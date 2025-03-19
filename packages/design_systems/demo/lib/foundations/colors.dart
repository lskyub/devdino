// import 'package:design_systems/b2b/b2b.dart';
// import 'package:design_systems/b2b/components/text/text.dart';
// import 'package:design_systems/b2b/components/text/text.variant.dart';
// import 'package:flutter/material.dart';
// import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// // Import the widget from your app

// @widgetbook.UseCase(
//   name: 'FoundationsColors',
//   type: TextButton,
//   path: '[foundations]/colors',
// )
// Widget builFoundationsColorPaletteUseCase(BuildContext context) {
//   List<Widget> palette(List<Color> colors) {
//     return colors
//         .map(
//           (value) => Expanded(
//             child: Container(
//               height: 50,
//               color: value,
//             ),
//           ),
//         )
//         .toList();
//   }

//   List<Widget> label(List<String> labels) {
//     return labels
//         .map(
//           (label) => Expanded(
//             child: Align(
//               alignment: Alignment.center,
//               child: Text(label),
//             ),
//           ),
//         )
//         .toList();
//   }

//   List<Widget> group(
//       String category, List<Color> colors, List<String> labels, bool isBorder) {
//     return [
//       Text(category),
//       Container(
//         decoration: isBorder
//             ? BoxDecoration(
//                 border: Border.all(
//                   color: Colors.grey,
//                 ),
//               )
//             : null,
//         child: Row(
//           children: [
//             ...palette(colors),
//           ],
//         ),
//       ),
//       Row(
//         children: [
//           ...label(labels),
//         ],
//       ),
//     ];
//   }

//   return SingleChildScrollView(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ...group(
//             'Basic',
//             [
//               $b2bToken.color.white.resolve(context),
//               $b2bToken.color.black.resolve(context)
//             ],
//             ['100', '0'],
//             true),
//         ...group(
//             'Grayscale',
//             [
//               $b2bToken.color.blingGray100.resolve(context),
//               $b2bToken.color.blingGray200.resolve(context),
//               $b2bToken.color.blingGray300.resolve(context),
//               $b2bToken.color.blingGray400.resolve(context),
//               $b2bToken.color.blingGray500.resolve(context),
//               $b2bToken.color.blingGray600.resolve(context),
//               $b2bToken.color.blingGray700.resolve(context),
//             ],
//             [
//               '50',
//               '100',
//               '200',
//               '300',
//               '400',
//               '500',
//               '600',
//               '700',
//               '800',
//               '900'
//             ],
//             false),
//         ...group(
//             'Blue',
//             [],
//             [
//               '50',
//               '100',
//               '150',
//               '200',
//               '300',
//               '400',
//               '500',
//               '600',
//               '700',
//               '800',
//               '900'
//             ],
//             false),
//         ...group(
//             'Green',
//             [
//               $b2bToken.color.green100.resolve(context),
//               $b2bToken.color.green200.resolve(context),
//               $b2bToken.color.green300.resolve(context),
//               $b2bToken.color.green400.resolve(context),
//               $b2bToken.color.green500.resolve(context),
//               $b2bToken.color.green600.resolve(context),
//               $b2bToken.color.green700.resolve(context),
//             ],
//             [
//               '50',
//               '100',
//               '200',
//               '300',
//               '400',
//               '500',
//               '600',
//               '700',
//               '800',
//               '900'
//             ],
//             false),
//         ...group(
//             'Pink',
//             [
//               $b2bToken.color.pink100.resolve(context),
//               $b2bToken.color.pink200.resolve(context),
//               $b2bToken.color.pink300.resolve(context),
//               $b2bToken.color.pink400.resolve(context),
//               $b2bToken.color.pink500.resolve(context),
//               $b2bToken.color.pink600.resolve(context),
//               $b2bToken.color.pink700.resolve(context),
//             ],
//             [
//               '50',
//               '100',
//               '200',
//               '300',
//               '400',
//               '500',
//               '600',
//               '700',
//               '800',
//               '900'
//             ],
//             false),
//         ...group(
//             'Orange',
//             [],
//             [
//               '25',
//               '50',
//               '75',
//               '100',
//               '200',
//               '300',
//               '400',
//               '500',
//               '600',
//               '700',
//               '800',
//               '900'
//             ],
//             false),
//         ...group(
//             'Lightblue',
//             [
//               $b2bToken.color.lightblue300.resolve(context),
//               $b2bToken.color.lightblue400.resolve(context),
//               $b2bToken.color.lightblue500.resolve(context),
//             ],
//             [
//               '300',
//               '400',
//               '500',
//             ],
//             false),
//       ],
//     ),
//   );
// }

// @widgetbook.UseCase(
//   name: 'FoundationsColors',
//   type: TextButton,
//   path: '[foundations]/colors',
// )
// Widget builFoundationsColorSystemUseCase(BuildContext context) {
//   List<Row> color(List<String> name, List<Color> color, List<bool> border) {
//     return name
//         .asMap()
//         .entries
//         .map(
//           (entry) => Column(
//             children: [
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   border: border[entry.key]
//                       ? Border.all(
//                           color: Colors.grey,
//                         )
//                       : null,
//                   borderRadius: BorderRadius.circular(10),
//                   color: color[entry.key],
//                 ),
//               ),
//               Text(entry.value),
//             ],
//           ),
//         )
//         .map(
//           (e) => Row(
//             children: [
//               e,
//               const SizedBox(
//                 width: 30,
//               ),
//             ],
//           ),
//         )
//         .toList();
//   }

//   List<Widget> group(String category, List<String> name, List<Color> colors,
//       List<bool> border) {
//     return [
//       if (category.isNotEmpty) ...{
//         const SizedBox(height: 30),
//         B2bText(
//             type: B2bTextType.body3,
//             weight: B2bTextWeight.bold,
//             text: category),
//       },
//       const SizedBox(height: 10),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [...color(name, colors, border)],
//       ),
//     ];
//   }

//   return SingleChildScrollView(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ...group('Static', [
//           'Netural',
//           'Black'
//         ], [
//           $b2bToken.color.staticNetural.resolve(context),
//           $b2bToken.color.staticBlack.resolve(context)
//         ], [
//           true,
//           false
//         ]),
//         ...group('Primary', [
//           'Primary',
//           'Primary2'
//         ], [
//           $b2bToken.color.primary.resolve(context),
//           $b2bToken.color.primary2.resolve(context)
//         ], [
//           false,
//           false
//         ]),
//         ...group('Status', [
//           'Positive',
//           'Positive Light',
//           'Negative',
//           'Negative Light',
//           'Cauntionary',
//         ], [
//           $b2bToken.color.statusPositive.resolve(context),
//           $b2bToken.color.statusPositivelight.resolve(context),
//           $b2bToken.color.statusNegative.resolve(context),
//           $b2bToken.color.statusNegativelight.resolve(context),
//           $b2bToken.color.statusCauntionary.resolve(context),
//         ], [
//           false,
//           false,
//           false,
//           false,
//           false
//         ]),
//         const SizedBox(height: 30),
//         const B2bText(
//             type: B2bTextType.body1,
//             weight: B2bTextWeight.bold,
//             text: 'Button'),
//         ...group('Primary', [
//           'Enabled',
//           'Pressed',
//           'Border',
//           'Disabled',
//         ], [
//           $b2bToken.color.buttonPrimaryEnabled.resolve(context),
//           $b2bToken.color.buttonPrimaryPressed.resolve(context),
//           $b2bToken.color.buttonPrimaryBorder.resolve(context),
//           $b2bToken.color.buttonPrimaryDisabled.resolve(context),
//         ], [
//           false,
//           false,
//           false,
//           false
//         ]),
//         ...group('', [
//           'Enabled',
//           'Pressed',
//           'Border',
//           'Disabled',
//         ], [
//           $b2bToken.color.buttonPrimaryLightEnabled.resolve(context),
//           $b2bToken.color.buttonPrimaryLightPressed.resolve(context),
//           $b2bToken.color.buttonPrimaryLightBorder.resolve(context),
//           $b2bToken.color.buttonPrimaryLightDisabled.resolve(context),
//         ], [
//           false,
//           false,
//           false,
//           false
//         ]),
//         ...group('Secondary', [
//           'Netural',
//           'Pressed',
//           'Border',
//           'Disabled',
//         ], [
//           $b2bToken.color.buttonSecondaryNetural.resolve(context),
//           $b2bToken.color.buttonSecondaryPressed.resolve(context),
//           $b2bToken.color.buttonSecondaryBorder.resolve(context),
//           $b2bToken.color.buttonSecondaryDisabled.resolve(context),
//         ], [
//           true,
//           false,
//           false,
//           false
//         ]),
//         ...group('', [
//           'Active',
//         ], [
//           $b2bToken.color.buttonSecondaryActive.resolve(context),
//         ], [
//           false
//         ]),
//         const SizedBox(height: 30),
//         const B2bText(
//             type: B2bTextType.body1, weight: B2bTextWeight.bold, text: 'Label'),
//         ...group('', [
//           'Primary',
//         ], [
//           $b2bToken.color.labelPrimary.resolve(context),
//         ], [
//           false
//         ]),
//         ...group('', [
//           'Nomal',
//           'Strong',
//           'Disabled',
//         ], [
//           $b2bToken.color.labelNomal.resolve(context),
//           $b2bToken.color.labelStrong.resolve(context),
//           $b2bToken.color.labelDisabled.resolve(context),
//         ], [
//           false,
//           false,
//           false
//         ]),
//         ...group('', [
//           'Netural',
//           'Netural Disabled',
//         ], [
//           $b2bToken.color.labelNetural.resolve(context),
//           $b2bToken.color.labelNeturalDisabled.resolve(context),
//         ], [
//           true,
//           false
//         ]),
//         const SizedBox(height: 30),
//         const B2bText(
//             type: B2bTextType.body1,
//             weight: B2bTextWeight.bold,
//             text: 'Background'),
//         ...group('', [
//           'Light Primary',
//         ], [
//           $b2bToken.color.backgroundLightPrimary.resolve(context),
//         ], [
//           false
//         ]),
//         ...group('', [
//           'Netural 1',
//           'Netural 2',
//           'Netural 3',
//           'Netural 4',
//         ], [
//           $b2bToken.color.backgroundNetural1.resolve(context),
//           $b2bToken.color.backgroundNetural2.resolve(context),
//           $b2bToken.color.backgroundNetural3.resolve(context),
//           $b2bToken.color.backgroundNetural4.resolve(context),
//         ], [
//           false,
//           false,
//           false,
//           false
//         ]),
//         const SizedBox(height: 30),
//         const B2bText(
//             type: B2bTextType.body1,
//             weight: B2bTextWeight.bold,
//             text: 'Border'),
//         ...group('', [
//           'Nomal',
//           'Postive',
//           'Negative',
//         ], [
//           $b2bToken.color.borderNomal.resolve(context),
//           $b2bToken.color.borderPostive.resolve(context),
//           $b2bToken.color.borderNegative.resolve(context),
//         ], [
//           false,
//           false,
//           false,
//         ]),
//         const SizedBox(height: 30),
//         const B2bText(
//             type: B2bTextType.body1, weight: B2bTextWeight.bold, text: 'Icon'),
//         ...group('', [
//           'Primary',
//           'Netural',
//         ], [
//           $b2bToken.color.iconPrimary.resolve(context),
//           $b2bToken.color.iconNetural.resolve(context),
//         ], [
//           false,
//           true,
//         ]),
//         ...group('', [
//           'Nomal',
//           'Strong',
//           'Disabled',
//         ], [
//           $b2bToken.color.iconNomal.resolve(context),
//           $b2bToken.color.iconStrong.resolve(context),
//           $b2bToken.color.iconDisabled.resolve(context),
//         ], [
//           false,
//           false,
//           false,
//         ]),
//         const SizedBox(height: 30),
//         const B2bText(
//             type: B2bTextType.body1,
//             weight: B2bTextWeight.bold,
//             text: 'Divider'),
//         ...group('', [
//           'Divider-1',
//           'Divider-2',
//           'Divider-3',
//         ], [
//           $b2bToken.color.divider1.resolve(context),
//           $b2bToken.color.divider2.resolve(context),
//           $b2bToken.color.divider3.resolve(context),
//         ], [
//           false,
//           false,
//           false,
//         ]),
//         const SizedBox(height: 30),
//         const B2bText(
//             type: B2bTextType.body1,
//             weight: B2bTextWeight.bold,
//             text: 'Dimmed'),
//         ...group('', [
//           'opacity 60%',
//         ], [
//           $b2bToken.color.dimmed.resolve(context),
//         ], [
//           false,
//         ]),
//         const SizedBox(height: 30),
//       ],
//     ),
//   );
// }
