import 'package:design_systems/dino/components/buttons/button.dart';
import 'package:design_systems/dino/components/buttons/button.variant.dart';
import 'package:design_systems/dino/components/dialog/dialog.style.dart';
import 'package:design_systems/dino/components/dialog/dialog.variant.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class B2bDialog extends StatelessWidget {
  final String title;
  final String subTitle;
  final String confirmLabel;
  final String? cancelLabel;
  final EdgeInsets? padding;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final B2bDialogType type;
  final String? imageUrl;
  final B2bDialogImagePosition imagePosition;
  final B2bButtonType buttonType;

  const B2bDialog({
    super.key,
    this.type = B2bDialogType.alert,
    this.title = '',
    this.subTitle = '',
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel,
    this.onCancel,
    this.imageUrl,
    this.padding,
    this.imagePosition = B2bDialogImagePosition.bottom,
    this.buttonType = B2bButtonType.primary,
  });

  B2bDialogStyle get $style => B2bDialogStyle(type, imagePosition);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return FlexBox(
      direction: Axis.vertical,
      style: Style(
        $flex.mainAxisAlignment.center(), // spaceBetween에서 center로 변경
        $flex.crossAxisAlignment.center(), // 가로축 중앙 정렬 추가
        $box.alignment.center(),
      ),
      children: [
        VBox(
          style: $style.container(size),
          children: [
            if (imageUrl?.isNotEmpty == true &&
                B2bDialogImagePosition.top == imagePosition) ...{
              Box(
                style: Style(
                  $box.padding.top(16),
                  $image.fit.fill(),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: StyledImage(
                    image: NetworkImage(imageUrl!),
                  ),
                ),
              ),
            },
            if (title.isNotEmpty) ...{
              Box(
                style: $style.title(),
                child: StyledText(title.replaceAll('\\n', '\n')),
              )
            },
            if (subTitle.isNotEmpty) ...{
              Box(
                style: $style.subTitle(),
                child: StyledText(subTitle.replaceAll('\\n', '\n')),
              )
            },
            if (imageUrl?.isNotEmpty == true &&
                B2bDialogImagePosition.bottom == imagePosition) ...{
              Box(
                style: Style(
                  $box.padding.top(24),
                  $image.fit.fill(),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: StyledImage(
                    image: NetworkImage(imageUrl!),
                  ),
                ),
              ),
            },
            HBox(
              style: Style(
                $box.padding.top(24),
              ),
              children: [
                if (type == B2bDialogType.confirm) ...{
                  Expanded(
                    child: B2bButton(
                      type: B2bButtonType.secondary,
                      size: B2bButtonSize.large,
                      title: cancelLabel ?? '취소',
                      onTap: onCancel,
                    ),
                  ),
                  const SizedBox(width: 12),
                },
                Expanded(
                  child: B2bButton(
                    type: buttonType,
                    size: B2bButtonSize.large,
                    title: confirmLabel,
                    onTap: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
