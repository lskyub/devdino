import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/toast/toast.style.dart';
import 'package:design_systems/b2b/components/toast/toast.variant.dart';
import 'package:design_systems/design_systems.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import 'package:nitrogen_flutter_svg/nitrogen_flutter_svg.dart';

class B2bToast extends StatelessWidget {
  final B2bToastStatus status;
  final String message;
  const B2bToast({
    super.key,
    required this.status,
    required this.message,
  });

  B2bToastStyle get $style => B2bToastStyle(status);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return FlexBox(
      direction: Axis.horizontal,
      style: $style.container(width),
      children: [
        if (status == B2bToastStatus.success) ...{
          Box(
            style: $style.circular().merge(
                  Style($box.color.ref($b2bToken.color.statusPositive)),
                ),
            child: TAssets.icons.toastCheck.call(),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: $b2bToken.space.s4.resolve(context),
            ),
          ),
        },
        if (status == B2bToastStatus.fail) ...{
          Box(
            style: $style.circular().merge(
                  Style($box.color.ref($b2bToken.color.statusNegative)),
                ),
            child: TAssets.icons.toastClose.call(),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: $b2bToken.space.s4.resolve(context),
            ),
          ),
        },
        StyledText(
          message,
          style: $style.message(),
        ),
      ],
    );
  }
}
