import 'package:design_systems/dino/components/buttons/button.dino.style.dart';
import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class DinoButton extends StatelessWidget {
  final DinoButtonType type;
  final VoidCallback? onTap;
  final String title;
  final DinoButtonState state;
  final double? radius;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? textSize;
  final double? height;
  final double? width;
  final int? textMaxLines;
  final double? iconSize;
  final ColorToken? textColor;
  final ColorToken? borderColor;
  final ColorToken? disabledTextColor;
  final ColorToken? disabledBorderColor;
  final ColorToken? pressedTextColor;
  final ColorToken? pressedBorderColor;
  final ColorToken? backgroundColor;
  final ColorToken? disabledBackgroundColor;
  final ColorToken? pressedBackgroundColor;
  final LinearGradient? gradient;
  final Widget? leading;
  final Widget? trailing;
  final DinoButtonSize size;
  final FontWeight? fontWeight;
  const DinoButton(
      {super.key,
      required this.type,
      this.leading,
      this.trailing,
      this.onTap,
      this.radius,
      this.horizontalPadding,
      this.verticalPadding,
      this.height,
      this.width,
      required this.title,
      this.state = DinoButtonState.base,
      this.size = DinoButtonSize.wrap,
      this.textSize,
      this.fontWeight,
      this.textMaxLines,
      this.iconSize,
      this.textColor,
      this.borderColor,
      this.disabledTextColor,
      this.disabledBorderColor,
      this.pressedTextColor,
      this.pressedBorderColor,
      this.backgroundColor,
      this.disabledBackgroundColor,
      this.pressedBackgroundColor,
      this.gradient});

  DinoButtonStyle get $style => DinoButtonStyle(type, size);

  @override
  Widget build(BuildContext context) {
    return PressableBox(
      enabled: state != DinoButtonState.disabled,
      onPress: onTap,
      child: HBox(
        style: $style.container(
          state: state,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
          setRadius: radius,
          textSize: textSize,
          height: height,
          width: width,
          fontWeight: fontWeight,
          textColor: textColor,
          borderColor: borderColor,
          disabledTextColor: disabledTextColor,
          disabledBorderColor: disabledBorderColor,
          pressedTextColor: pressedTextColor,
          pressedBorderColor: pressedBorderColor,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          pressedBackgroundColor: pressedBackgroundColor,
          gradient: gradient,
        ),
        children: [
          if (leading != null) leading!,
          StyledText(title),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  DinoButtonState enabled(bool enabled) {
    return enabled ? DinoButtonState.base : DinoButtonState.disabled;
  }

  factory DinoButton.custom({
    required String title,
    required DinoButtonType type,
    DinoButtonSize? size,
    Widget? leading,
    Widget? trailing,
    double? radius,
    double? horizontalPadding,
    double? verticalPadding,
    double? textSize,
    FontWeight? fontWeight,
    int? textMaxLines,
    double? iconSize,
    ColorToken? textColor,
    ColorToken? borderColor,
    ColorToken? disabledTextColor,
    ColorToken? disabledBorderColor,
    ColorToken? pressedTextColor,
    ColorToken? pressedBorderColor,
    ColorToken? backgroundColor,
    ColorToken? disabledBackgroundColor,
    ColorToken? pressedBackgroundColor,
    LinearGradient? gradient,
    VoidCallback? onTap,
    DinoButtonState state = DinoButtonState.base,
  }) {
    return DinoButton(
      title: title,
      onTap: onTap,
      type: type,
      state: state,
      size: size ?? DinoButtonSize.wrap,
      radius: radius,
      fontWeight: fontWeight,
      leading: leading,
      trailing: trailing,
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
      textSize: textSize,
      textMaxLines: textMaxLines,
      iconSize: iconSize,
      textColor: textColor,
      borderColor: borderColor,
      disabledTextColor: disabledTextColor,
      disabledBorderColor: disabledBorderColor,
      pressedTextColor: pressedTextColor,
      pressedBorderColor: pressedBorderColor,
      backgroundColor: backgroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      pressedBackgroundColor: pressedBackgroundColor,
      gradient: gradient,
    );
  }
}
