import 'package:design_systems/b2b/components/chip/chip.style.dart';
import 'package:design_systems/b2b/components/chip/chip.variant.dart';
import 'package:design_systems/src/assets.nitrogen.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import 'package:nitrogen_flutter_svg/nitrogen_flutter_svg.dart';

class B2bChip extends StatelessWidget {
  final B2bChipSize size;
  final Widget? leading;
  final Widget? trailing;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const B2bChip({
    super.key,
    this.size = B2bChipSize.medium,
    this.leading,
    this.trailing,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  B2bChipStyle get $style =>
      B2bChipStyle(selected ? B2bChipVariant.selected : B2bChipVariant.base, size);

  @override
  Widget build(BuildContext context) {
    return PressableBox(
      onPress: onTap,
      style: $style.container(),
      child: HBox(
        style: $style.children(),
        children: [
          if (leading != null) leading!,
          Box(
            style: $style.label(),
            child: StyledText(label),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  factory B2bChip.setting({
    String label = '',
    VoidCallback? onTap,
    bool selected = false,
  }) {
    return B2bChip(
      leading: TAssets.icons.filter.call(width: 20, height: 20),
      label: label,
      selected: selected,
      onTap: onTap,
    );
  }

  factory B2bChip.arrowDown({
    String label = '',
    VoidCallback? onTap,
    bool selected = false,
  }) {
    return B2bChip(
      trailing: TAssets.icons.arrowDown.call(
        width: 20,
        height: 20,
        colorFilter: selected
            ? const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              )
            : null,
      ),
      selected: selected,
      label: label,
      onTap: onTap,
    );
  }
}
