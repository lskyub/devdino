import 'package:mix/mix.dart';

class B2bButtonType extends Variant {
  const B2bButtonType._(super.name);

  /// Primary
  static const primary = B2bButtonType._('b2b.button.type.primary');

  /// Primary - Light
  static const primaryLight = B2bButtonType._('b2b.button.type.primary.light');

  /// Primary - Outlined
  static const primaryOutlined =
      B2bButtonType._('b2b.button.type.primary.outlined');

  /// Secondary
  static const secondary = B2bButtonType._('b2b.button.type.secondary');

  /// Secondary - Round
  static const secondaryRound =
      B2bButtonType._('b2b.button.type.secondary.round');

  /// Tertiary - Negative
  static const tertiaryNegative =
      B2bButtonType._('b2b.button.type.tertiary.negative');

  /// Tertiary - Light Negative
  static const tertiaryNegativeLight =
      B2bButtonType._('b2b.button.type.tertiary.negative.light');

  /// Tertiary - Line Negative
  static const tertiaryNegativeOutlined =
      B2bButtonType._('b2b.button.type.tertiary.negative.outlined');

  /// Tertiary - Postive
  static const tertiaryPostive =
      B2bButtonType._('b2b.button.type.tertiary.postive');
}

class B2bButtonSize extends Variant {
  const B2bButtonSize._(super.name);
  static const large = B2bButtonSize._('b2b.button.size.large');
  static const medium = B2bButtonSize._('b2b.button.size.medium');
  static const small = B2bButtonSize._('b2b.button.size.small');
  static const xsmall = B2bButtonSize._('b2b.button.size.xsmall');
}

class B2bButtonState extends Variant {
  const B2bButtonState._(super.name);
  static const base = B2bButtonState._('b2b.button.state.base');
  // static const active = B2bButtonState._('b2b.button.state.active');
  static const pressed = B2bButtonState._('b2b.button.state.pressed');
  static const disabled = B2bButtonState._('b2b.button.state.disabled');
}

class DinoButtonType extends Variant {
  const DinoButtonType._(super.name);
  static const solid = DinoButtonType._('dino.button.type.solid');
  static const outline = DinoButtonType._('dino.button.type.outline');
  static const empty = DinoButtonType._('dino.button.type.outline.empty');
}

class DinoButtonState extends Variant {
  const DinoButtonState._(super.name);
  static const base = DinoButtonState._('dino.button.state.base');
  static const pressed = DinoButtonState._('dino.button.state.pressed');
  static const disabled = DinoButtonState._('dino.button.state.disabled');
}

class DinoButtonSize extends Variant {
  const DinoButtonSize._(super.name);
  static const full = DinoButtonSize._('dino.button.size.full');
  static const wrap = DinoButtonSize._('dino.button.size.wrap');
}
