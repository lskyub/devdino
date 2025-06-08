import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/foundations/theme.dart';
import 'package:design_systems/dino/foundations/token.typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class SettingItem extends ConsumerWidget {
  final String path;
  final String title;
  final VoidCallback onTap;
  const SettingItem({super.key, required this.path, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              path,
            ),
            const SizedBox(width: 16),
            DinoText.custom(
              text: title,
              fontSize: DinoTextSizeToken.text400,
              fontWeight: FontWeight.w500,
              color: $dinoToken.color.blingGray800,
            ),
          ],
        ),
      ),
    );
  }
}
