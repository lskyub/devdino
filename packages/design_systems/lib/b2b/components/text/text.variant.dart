import 'package:mix/mix.dart';

class B2bTextType extends Variant{
  const B2bTextType._(super.name);

  static const display = B2bTextType._('b2b.text.type.display1');
  static const headerline1 = B2bTextType._('b2b.text.type.headerline1');
  static const headerline2 = B2bTextType._('b2b.text.type.headerline2');
  static const title1 = B2bTextType._('b2b.text.type.title1');
  static const title2 = B2bTextType._('b2b.text.type.title2');
  static const title3 = B2bTextType._('b2b.text.type.title3');
  static const body1 = B2bTextType._('b2b.text.type.body1');
  static const body2 = B2bTextType._('b2b.text.type.body2');
  static const body3 = B2bTextType._('b2b.text.type.body3');
  static const body4 = B2bTextType._('b2b.text.type.body4');
  static const caption1 = B2bTextType._('b2b.text.type.caption1');
  static const caption2 = B2bTextType._('b2b.text.type.caption2');
}

class B2bTextWeight extends Variant{
  const B2bTextWeight._(super.name);

  static const bold = B2bTextWeight._('b2b.text.weight.bold');
  static const medium = B2bTextWeight._('b2b.text.weight.medium');
  static const regular = B2bTextWeight._('b2b.text.weight.regular');
}