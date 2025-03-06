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
