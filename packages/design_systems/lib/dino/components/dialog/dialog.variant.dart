import 'package:mix/mix.dart';

class B2bDialogType extends Variant {
  const B2bDialogType._(super.name);

  static const alert = B2bDialogType._('b2b.dialog.type.alert');
  static const confirm = B2bDialogType._('b2b.dialog.type.confirm');
  static const notice = B2bDialogType._('b2b.dialog.type.notice');
}

class B2bDialogImagePosition extends Variant{
  const B2bDialogImagePosition._(super.name);

  static const none = B2bDialogImagePosition._('b2b.dialog.image.position.none');
  static const top = B2bDialogImagePosition._('b2b.dialog.image.position.top');
  static const bottom = B2bDialogImagePosition._('b2b.dialog.image.position.bottom');
}

class B2bDialogButtonType extends Variant{
  const B2bDialogButtonType._(super.name);

  static const base = B2bDialogButtonType._('b2b.dialog.button.type.base');
  static const negative = B2bDialogButtonType._('b2b.dialog.button.type.negative');
}