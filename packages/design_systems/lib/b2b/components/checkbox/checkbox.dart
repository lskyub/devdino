import 'package:design_systems/b2b/foundations/theme.dart';
import 'package:design_systems/src/assets.nitrogen.dart';
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';
import 'package:nitrogen_flutter_svg/nitrogen_flutter_svg.dart';

class B2bCheckBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onLabelClick;
  final String label;
  final Widget? trailing;

  const B2bCheckBox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.trailing,
    this.onLabelClick,
  });

  @override
  Widget build(BuildContext context) => HBox(
        children: [
          FlexBox(
            direction: Axis.horizontal,
            style: Style(
              $box.alignment.center(),
            ),
            children: [
              PressableBox(
                onPress: () => onChanged(!value),
                child: value
                    ? const $TAssetsIcons()
                        .checkboxOn
                        .call(width: 24, height: 24)
                    : const $TAssetsIcons()
                        .checkboxOff
                        .call(width: 24, height: 24),
              ),
              const SizedBox(width: 8),
              PressableBox(
                onPress: onLabelClick,
                child: HBox(
                  children: [
                    Box(
                      style: Style(
                        $box.padding.bottom(2),
                        $text.style.color.ref($b2bToken.color.gray700),
                        $text.style.fontSize(20),
                        $text.style.letterSpacing(-0.2),
                        value
                            ? $text.style.fontWeight.w700()
                            : $text.style.fontWeight.w500(),
                        $text.style.height(0),
                      ),
                      child: StyledText(label),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 4), trailing!],
            ],
          )
        ],
      );

  factory B2bCheckBox.chevron({
    required bool value,
    String label = '',
    bool expaned = true,
    required ValueChanged<bool> onChanged,
    required VoidCallback onLabelClick,
  }) =>
      B2bCheckBox(
        value: value,
        label: label,
        trailing: expaned
            ? TAssets.icons.arrowDown.call()
            : TAssets.icons.arrowUp.call(),
        onChanged: onChanged,
        onLabelClick: onLabelClick,
      );
}
