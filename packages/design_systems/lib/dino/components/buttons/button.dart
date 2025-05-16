import 'package:design_systems/dino/components/buttons/button.style.dart';
import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class B2bButton extends StatelessWidget {
  final B2bButtonType type;
  final B2bButtonSize size;
  final VoidCallback? onTap;
  final String title;
  final B2bButtonState state;
  final IconData? icon;
  final double? radius;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? textSize;
  final double? iconSize;
  final double? textColor;
  final double? iconColor;
  final double? borderColor;
  final double? disabledTextColor;
  final double? disabledIconColor;
  final double? disabledBorderColor;
  final double? pressedTextColor;
  final double? pressedIconColor;
  final double? pressedBorderColor;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? pressedBackgroundColor;
  final Color? startColor;
  final Color? endColor;
  final Color? disabledStartColor;
  final Color? disabledEndColor;
  final Color? pressedStartColor;
  final Color? pressedEndColor;

  const B2bButton(
      {super.key,
      required this.type,
      required this.size,
      this.icon,
      this.onTap,
      this.radius,
      this.horizontalPadding,
      this.verticalPadding,
      required this.title,
      this.state = B2bButtonState.base,
      this.textSize,
      this.iconSize,
      this.textColor,
      this.iconColor,
      this.borderColor,
      this.disabledTextColor,
      this.disabledIconColor,
      this.disabledBorderColor,
      this.pressedTextColor,
      this.pressedIconColor,
      this.pressedBorderColor,
      this.backgroundColor,
      this.disabledBackgroundColor,
      this.pressedBackgroundColor,
      this.startColor,
      this.endColor,
      this.disabledStartColor,
      this.disabledEndColor,
      this.pressedStartColor,
      this.pressedEndColor});

  B2bButtonStyle get $style => B2bButtonStyle(type, size);

  @override
  Widget build(BuildContext context) {
    return PressableBox(
      enabled: state != B2bButtonState.disabled,
      style: $style.container(
        state,
        horizontalPadding: horizontalPadding,
        verticalPadding: verticalPadding,
        setRadius: radius,
        textSize: textSize,
        iconSize: iconSize,
        textColor: textColor,
        iconColor: iconColor,
        borderColor: borderColor,
        disabledTextColor: disabledTextColor,
        disabledIconColor: disabledIconColor,
        disabledBorderColor: disabledBorderColor,
        pressedTextColor: pressedTextColor,
        pressedIconColor: pressedIconColor,
        pressedBorderColor: pressedBorderColor,
        backgroundColor: backgroundColor,
        disabledBackgroundColor: disabledBackgroundColor,
        pressedBackgroundColor: pressedBackgroundColor,
        startColor: startColor,
        endColor: endColor,
        disabledStartColor: disabledStartColor,
        disabledEndColor: disabledEndColor,
        pressedStartColor: pressedStartColor,
        pressedEndColor: pressedEndColor,
      ),
      onPress: onTap,
      child: StyledText(title),
    );
  }

  B2bButtonState enabled(bool enabled) {
    return enabled ? B2bButtonState.base : B2bButtonState.disabled;
  }

  factory B2bButton.large({
    required String title,
    IconData? icon,
    VoidCallback? onTap,
    required B2bButtonType type,
    B2bButtonState state = B2bButtonState.base,
  }) {
    return B2bButton(
      title: title,
      icon: icon,
      onTap: onTap,
      type: type,
      size: B2bButtonSize.large,
      state: state,
    );
  }

  factory B2bButton.medium({
    required String title,
    IconData? icon,
    VoidCallback? onTap,
    required B2bButtonType type,
    B2bButtonState state = B2bButtonState.base,
  }) {
    return B2bButton(
      title: title,
      icon: icon,
      onTap: onTap,
      type: type,
      size: B2bButtonSize.medium,
      state: state,
    );
  }

  factory B2bButton.small({
    required String title,
    IconData? icon,
    VoidCallback? onTap,
    required B2bButtonType type,
    B2bButtonState state = B2bButtonState.base,
  }) {
    return B2bButton(
      title: title,
      icon: icon,
      onTap: onTap,
      type: type,
      size: B2bButtonSize.small,
      state: state,
    );
  }

  factory B2bButton.xsmall({
    required String title,
    IconData? icon,
    VoidCallback? onTap,
    required B2bButtonType type,
    B2bButtonState state = B2bButtonState.base,
  }) {
    return B2bButton(
      title: title,
      icon: icon,
      onTap: onTap,
      type: type,
      size: B2bButtonSize.xsmall,
      state: state,
    );
  }

  factory B2bButton.custom({
    required B2bButtonSize size,
    required String title,
    required B2bButtonType type,
    IconData? icon,
    double? radius,
    double? horizontalPadding,
    double? verticalPadding,
    double? textSize,
    double? iconSize,
    double? textColor,
    double? iconColor,
    double? borderColor,
    double? disabledTextColor,
    double? disabledIconColor,
    double? disabledBorderColor,
    double? pressedTextColor,
    double? pressedIconColor,
    double? pressedBorderColor,
    Color? backgroundColor,
    Color? disabledBackgroundColor,
    Color? pressedBackgroundColor,
    Color? startColor,
    Color? endColor,
    Color? disabledStartColor,
    Color? disabledEndColor,
    Color? pressedStartColor,
    Color? pressedEndColor,
    VoidCallback? onTap,
    B2bButtonState state = B2bButtonState.base,
  }) {
    return B2bButton(
      title: title,
      icon: icon,
      onTap: onTap,
      type: type,
      size: size,
      state: state,
      radius: radius,
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
      textSize: textSize,
      iconSize: iconSize,
      textColor: textColor,
      iconColor: iconColor,
      borderColor: borderColor,
      disabledTextColor: disabledTextColor,
      disabledIconColor: disabledIconColor,
      disabledBorderColor: disabledBorderColor,
      pressedTextColor: pressedTextColor,
      pressedIconColor: pressedIconColor,
      pressedBorderColor: pressedBorderColor,
      backgroundColor: backgroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      pressedBackgroundColor: pressedBackgroundColor,
      startColor: startColor,
      endColor: endColor,
      disabledStartColor: disabledStartColor,
      disabledEndColor: disabledEndColor,
      pressedStartColor: pressedStartColor,
      pressedEndColor: pressedEndColor,
    );
  }
}
