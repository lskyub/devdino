import 'package:design_systems/b2b/b2b.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class B2bBottomSheet extends StatelessWidget {
  final String title;
  final Widget? content;
  final Widget? footer;
  final VoidCallback onClosePressed;
  const B2bBottomSheet({
    super.key,
    required this.title,
    this.content,
    this.footer,
    required this.onClosePressed,
  });

  @override
  Widget build(BuildContext context) {
    return FlexBox(
      direction: Axis.vertical,
      style: Style(
        $box.width.infinity(),
        $box.borderRadius.top(16),
        $box.color.white(),
      ),
      children: [
        // 헤더
        ZBox(
          children: [
            Box(
              style: Style(
                $box.width.infinity(),
                $box.height(68),
                $box.border.bottom(
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignInside,
                  color: ColorRef($b2bToken.color.gray200),
                ),
                $box.alignment.center(),
                $text.textAlign.center(),
                $text.style(
                  fontSize: 24,
                  color: ColorRef($b2bToken.color.gray700),
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: StyledText(title),
            ),
            Box(
              style: Style(
                $box.height(68),
                $box.alignment.centerRight(),
              ),
              child: PressableBox(
                onPress: onClosePressed,
                style: Style(
                  $box.height(24),
                  $box.width(24),
                  $box.alignment.centerRight(),
                  $box.margin.right(24),
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF454A52),
                ),
              ),
            ),
          ],
        ),
        // 콘텐트
        Box(
          style: Style(
            $with.expanded(),
          ),
          child: content,
        ),
        // 푸터
        if (footer != null)
          Box(
            style: Style(
              $box.width.infinity(),
              $box.alignment.center(),
              $box.padding.horizontal(50),
              $box.padding.vertical(20),
              $box.color.white(),
              $box.shadow(
                color: const Color(0x19131517),
                blurRadius: 16,
                offset: const Offset(0, -4),
                spreadRadius: 0,
              ),
            ),
            child: footer,
          ),
      ],
    );
  }
}
