// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:demo/foundations/colors.dart' as _i2;
import 'package:demo/foundations/radius.dart' as _i3;
import 'package:demo/foundations/spaces.dart' as _i4;
import 'package:demo/widgets/bottomsheet/bottomsheet.dart' as _i5;
import 'package:demo/widgets/checkbox/checkbox.dart' as _i6;
import 'package:demo/widgets/chip/chip.dart' as _i7;
import 'package:demo/widgets/dialog/dialog.dart' as _i8;
import 'package:demo/widgets/button/button.dart' as _i9;
import 'package:demo/widgets/textfield/textfield.dart' as _i10;
import 'package:demo/foundations/fonts.dart' as _i11;
import 'package:demo/widgets/toast/toast.dart' as _i12;
import 'package:demo/widgets/dropdown/dropdown.dart' as _i13;
import 'package:widgetbook/widgetbook.dart' as _i1;

final directories = <_i1.WidgetbookNode>[
  _i1.WidgetbookCategory(
    name: 'foundations',
    children: [
      _i1.WidgetbookFolder(
        name: 'fonts',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'Typography',
            useCase: _i1.WidgetbookUseCase(
              name: 'FoundationsTypography',
              builder: _i11.buildTypographyUseCase,
            ),
          )
        ],
      ),
      _i1.WidgetbookFolder(
        name: 'colors',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'Color Palette',
            useCase: _i1.WidgetbookUseCase(
              name: 'FoundationsColors',
              builder: _i2.builFoundationsColorPaletteUseCase,
            ),
          ),
          _i1.WidgetbookLeafComponent(
            name: 'Color System',
            useCase: _i1.WidgetbookUseCase(
              name: 'FoundationsColors',
              builder: _i2.builFoundationsColorSystemUseCase,
            ),
          )
        ],
      ),
      _i1.WidgetbookFolder(
        name: 'radius',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'Container',
            useCase: _i1.WidgetbookUseCase(
              name: 'FoundationsRadius',
              builder: _i3.buildCoolButtonUseCase,
            ),
          )
        ],
      ),
      _i1.WidgetbookFolder(
        name: 'spaces',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'TextButton',
            useCase: _i1.WidgetbookUseCase(
              name: 'FoundationsSpaces',
              builder: _i4.buildCoolButtonUseCase,
            ),
          )
        ],
      ),
    ],
  ),
  _i1.WidgetbookCategory(
    name: 'widgets',
    children: [
      _i1.WidgetbookFolder(
        name: 'BottomSheet',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'B2bBottomSheet',
            useCase: _i1.WidgetbookUseCase(
              name: 'WidgetsBottomSheet',
              builder: _i5.buildCoolButtonUseCase,
            ),
          )
        ],
      ),
      _i1.WidgetbookFolder(
        name: 'CheckBox',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'B2bCheckBox',
            useCase: _i1.WidgetbookUseCase(
              name: 'WidgetsCheckBox',
              builder: _i6.buildCheckboxUseCase,
            ),
          )
        ],
      ),
      _i1.WidgetbookFolder(
        name: 'Chip',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'B2bChip',
            useCase: _i1.WidgetbookUseCase(
              name: 'WidgetsChip',
              builder: _i7.buildChipUseCase,
            ),
          )
        ],
      ),
      _i1.WidgetbookFolder(
        name: 'Dialog',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'B2bDialog',
            useCase: _i1.WidgetbookUseCase(
                name: 'WidgetsDialog', builder: _i8.buildDialogUseCase),
          ),
        ],
      ),
      _i1.WidgetbookFolder(
        name: 'Button',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'B2bPrimaryButton',
            useCase: _i1.WidgetbookUseCase(
                name: 'B2bButton Primary',
                builder: _i9.buildButtonPrimaryUseCase),
          ),
          _i1.WidgetbookLeafComponent(
            name: 'B2bSecondaryButton',
            useCase: _i1.WidgetbookUseCase(
                name: 'B2bButton Secondary',
                builder: _i9.buildButtonSecondaryUseCase),
          ),
          _i1.WidgetbookLeafComponent(
            name: 'B2bTertiaryButton',
            useCase: _i1.WidgetbookUseCase(
                name: 'B2bButton Tertiary',
                builder: _i9.buildButtonTertiaryUseCase),
          ),
        ],
      ),
      _i1.WidgetbookFolder(
        name: 'Textfield',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'B2bTextfield',
            useCase: _i1.WidgetbookUseCase(
                name: 'WidgetsTextfield', builder: _i10.buildTextfieldUseCase),
          ),
        ],
      ),
      _i1.WidgetbookFolder(
        name: 'Toast',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'B2bToast',
            useCase: _i1.WidgetbookUseCase(
                name: 'WidgetsToast', builder: _i12.buildToastUseCase),
          ),
        ],
      ),
      _i1.WidgetbookFolder(
        name: 'Dropdown',
        children: [
          _i1.WidgetbookLeafComponent(
            name: 'B2bDropdown',
            useCase: _i1.WidgetbookUseCase(
                name: 'WidgetsDropdown', builder: _i13.buildDropdownUseCase),
          ),
        ],
      ),
    ],
  ),
];
