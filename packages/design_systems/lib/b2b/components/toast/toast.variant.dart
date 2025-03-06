import 'package:mix/mix.dart';

class B2bToastStatus extends Variant {
  const B2bToastStatus._(super.name);

  static const values = [
    B2bToastStatus.success,
    B2bToastStatus.fail,
    B2bToastStatus.system,
  ];

  static const success = B2bToastStatus._('b2b.toast.status.success');
  static const fail = B2bToastStatus._('b2b.toast.status.fail');
  static const system = B2bToastStatus._('b2b.toast.status.system');
}
