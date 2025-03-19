
import 'package:mix/mix.dart';

class B2bChipVariant extends Variant {
  const B2bChipVariant(super.name);

  static const B2bChipVariant base = B2bChipVariant(
    'b2b.chip.variant.base',
  );
  static const B2bChipVariant selected = B2bChipVariant(
    'b2b.chip.variant.selected',
  );
}

class B2bChipSize extends Variant {
  const B2bChipSize._(super.name);
  // static const large = B2bChipSize._('b2b.chip.size.large');
  static const medium = B2bChipSize._('b2b.chip.size.medium');
  static const small = B2bChipSize._('b2b.chip.size.small');
  // static const xsmall = B2bChipSize._('b2b.chip.size.xsmall');
}