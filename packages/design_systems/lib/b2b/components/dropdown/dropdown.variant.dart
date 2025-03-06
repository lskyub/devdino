import 'package:mix/mix.dart';

class B2bDropdownStatus extends Variant {
  const B2bDropdownStatus._(super.name);

  static const values = [
    B2bDropdownStatus.defalut,
    B2bDropdownStatus.error,
    B2bDropdownStatus.disabled,
  ];

  static const defalut = B2bDropdownStatus._('b2b.dropdown.status.defalut');
  static const error = B2bDropdownStatus._('b2b.dropdown.status.error');
  static const disabled = B2bDropdownStatus._('b2b.dropdown.status.disabled');
}