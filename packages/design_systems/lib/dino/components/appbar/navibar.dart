import 'package:flutter/material.dart';

class DinoNaviBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final Widget? title;
  final Widget? trailingItem1;
  final Widget? trailingItem2;
  final Widget? trailingItem3;
  final EdgeInsets? padding;

  const DinoNaviBar({
    super.key,
    this.onBackPressed,
    this.title,
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
            // Back Button
            if (onBackPressed != null)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: onBackPressed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            // Title
            if (title != null) ...[
              Expanded(child: title!),
            ] else
              const Spacer(),
            // Trailing Items
            if (trailingItem1 != null) trailingItem1!,
            if (trailingItem2 != null) trailingItem2!,
            if (trailingItem3 != null) trailingItem3!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
