import 'package:mix/mix.dart';

class B2bTextFieldStatus extends Variant {
  const B2bTextFieldStatus._(super.name);

  static const values = [
    B2bTextFieldStatus.before,
    B2bTextFieldStatus.write,
    B2bTextFieldStatus.error,
    B2bTextFieldStatus.after,
  ];

  static const before = B2bTextFieldStatus._('b2b.textfield.status.before');
  static const write = B2bTextFieldStatus._('b2b.textfield.status.write');
  static const error = B2bTextFieldStatus._('b2b.textfield.status.error');
  static const after = B2bTextFieldStatus._('b2b.textfield.status.after');
}

class B2bTextFieldSize extends Variant {
  const B2bTextFieldSize._(super.name);

  static const values = [
    B2bTextFieldSize.small,
    B2bTextFieldSize.medium,
    B2bTextFieldSize.large,
  ];
  
  static const small = B2bTextFieldSize._('b2b.textfield.size.small');
  static const medium = B2bTextFieldSize._('b2b.textfield.size.medium');
  static const large = B2bTextFieldSize._('b2b.textfield.size.large');
}

class B2bTextFieldBoder extends Variant {
  const B2bTextFieldBoder._(super.name);

  static const values = [
  ];

  static const none = B2bTextFieldBoder._('b2b.textfield.border.none');
  static const underline = B2bTextFieldBoder._('b2b.textfield.border.underline');
  static const box = B2bTextFieldBoder._('b2b.textfield.border.box');
}

class DinoTextFieldBorder extends Variant {
  const DinoTextFieldBorder._(super.name);

  static const values = [
    DinoTextFieldBorder.none,
    DinoTextFieldBorder.underline,
    DinoTextFieldBorder.box,
  ];

  static const none = DinoTextFieldBorder._('dino.textfield.border.none');
  static const underline = DinoTextFieldBorder._('dino.textfield.border.underline');
  static const box = DinoTextFieldBorder._('dino.textfield.border.box');
}

class DinoFieldStatus extends Variant {
  const DinoFieldStatus._(super.name);

  static const values = [
    DinoFieldStatus.none,
    DinoFieldStatus.disabled,
    DinoFieldStatus.error,
  ];

  static const none = DinoFieldStatus._('dino.textfield.status.none');
  static const disabled = DinoFieldStatus._('dino.textfield.status.disabled');
  static const error = DinoFieldStatus._('dino.textfield.status.error');
}