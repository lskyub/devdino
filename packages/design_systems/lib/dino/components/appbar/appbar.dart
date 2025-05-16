import 'package:flutter/material.dart';

class DinoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget leadingItem;
  final Widget? trailingItem1;
  final Widget? trailingItem2;
  final Widget? trailingItem3;
  final EdgeInsets? padding;

  const DinoAppBar({
    super.key,
    required this.leadingItem,
    this.trailingItem1,
    this.trailingItem2,
    this.trailingItem3,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
          children: [
            // Leading Item (로고 영역)
            Expanded(
              child: leadingItem,
            ),
            // Trailing Items
            if (trailingItem1 != null) trailingItem1!,
            if (trailingItem2 != null) trailingItem2!,
            if (trailingItem3 != null) trailingItem3!
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
