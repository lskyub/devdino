import 'package:mix/mix.dart';

class B2BTagStatus extends Variant {
  const B2BTagStatus._(super.name);

  static const vip = B2BTagStatus._('b2b.tag.vip');
  static const first = B2BTagStatus._('b2b.tag.first');
  static const complete = B2BTagStatus._('b2b.tag.complete');
  static const noshow = B2BTagStatus._('b2b.tag.noshow');
  static const cancel = B2BTagStatus._('b2b.tag.cancel');
  static const payPositive = B2BTagStatus._('b2b.tag.payPositive');
  static const payNegative = B2BTagStatus._('b2b.tag.payNegative');
}

class B2BTagType extends Variant {
  const B2BTagType._(super.name);

  static const pill = B2BTagType._('b2b.tag.type.pill');
  static const base = B2BTagType._('b2b.tag.type.base');
}
