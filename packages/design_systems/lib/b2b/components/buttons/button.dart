import 'package:design_systems/b2b/components/buttons/button.style.dart';
import 'package:design_systems/b2b/components/buttons/button.variant.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class B2bButton extends StatelessWidget {
  final B2bButtonType type;
  final B2bButtonSize size;
  final VoidCallback? onTap;
  final String title;
  final B2bButtonState state;
  final IconData? icon;
  const B2bButton(
      {super.key,
      required this.type,
      required this.size,
      this.icon,
      this.onTap,
      required this.title,
      this.state = B2bButtonState.base});

  B2bButtonStyle get $style => B2bButtonStyle(type, size);

  @override
  Widget build(BuildContext context) {
    return PressableBox(
      enabled: state != B2bButtonState.disabled,
      style: $style.container(state),
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
}
