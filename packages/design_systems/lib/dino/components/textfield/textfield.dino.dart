import 'package:design_systems/dino/components/text/text.dino.dart';
import 'package:design_systems/dino/components/textfield/textfield.variant.dart';
import 'package:design_systems/dino/foundations/theme.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class DinoTextField extends StatelessWidget {
  final TextEditingController controller;
  final DinoTextFieldBorder border;
  final DinoFieldStatus status;
  final bool enabled;
  final ColorToken? borderColor;
  final ColorToken? focusedBorderColor;
  final ColorToken? errorBorderColor;
  final ColorToken? disabledBorderColor;
  final ColorToken? enabledBorderColor;
  final ColorToken? fillColor;
  final double borderWidth;
  final double borderRadius;
  final double focusedBorderWidth;
  final double errorBorderWidth;
  final String hint;
  final String? errorText;
  final ColorToken? errorColor;
  final ColorToken? hintColor;
  final ColorToken? textColor;
  final ColorToken? disabledColor;
  final FontWeight? fontWeight;
  final FontWeight? errorFontWeight;
  final EdgeInsets? errorPadding;
  final double? hintFontSize;
  final double? textFontSize;
  final double? errorFontSize;
  final EdgeInsets? contentPadding;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  const DinoTextField(
      {super.key,
      required this.controller,
      this.border = DinoTextFieldBorder.box,
      this.status = DinoFieldStatus.none,
      this.enabled = true,
      this.borderColor,
      this.focusedBorderColor,
      this.errorBorderColor,
      this.disabledBorderColor,
      this.enabledBorderColor,
      this.fillColor,
      this.hint = '',
      this.errorText = '',
      this.borderWidth = 0.7,
      this.focusedBorderWidth = 1.4,
      this.errorBorderWidth = 1.4,
      this.borderRadius = 12,
      this.errorColor,
      this.hintColor,
      this.textColor,
      this.disabledColor,
      this.fontWeight,
      this.errorFontWeight,
      this.errorPadding,
      this.hintFontSize,
      this.textFontSize,
      this.errorFontSize,
      this.contentPadding,
      this.maxLines,
      this.minLines,
      this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            TextFormField(
              controller: controller,
              enabled: enabled,
              maxLines: maxLines ?? 1,
              minLines: minLines ?? 1,
              maxLength: maxLength,
              style: TextStyle(
                color: textColor?.resolve(context) ??
                    $dinoToken.color.blingGray900.resolve(context),
                fontSize: textFontSize ?? 16,
                fontWeight: fontWeight ?? FontWeight.w400,
              ),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: contentPadding ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                hintText: hint,
                hintStyle: TextStyle(
                  color: hintColor?.resolve(context) ??
                      $dinoToken.color.blingGray400.resolve(context),
                  fontSize: hintFontSize ?? 16,
                  fontWeight: fontWeight ?? FontWeight.w400,
                ),
                errorStyle: const TextStyle(fontSize: 0),
                border: border == DinoTextFieldBorder.none
                    ? InputBorder.none
                    : border == DinoTextFieldBorder.underline
                        ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: borderColor?.resolve(context) ??
                                  $dinoToken.color.blingGray400
                                      .resolve(context),
                              width: borderWidth,
                            ),
                            borderRadius: BorderRadius.circular(borderRadius),
                          )
                        : OutlineInputBorder(
                            borderSide: BorderSide(
                              color: borderColor?.resolve(context) ??
                                  $dinoToken.color.blingGray400
                                      .resolve(context),
                              width: borderWidth,
                            ),
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                enabledBorder: border == DinoTextFieldBorder.none
                    ? InputBorder.none
                    : border == DinoTextFieldBorder.underline
                        ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: borderColor?.resolve(context) ??
                                  $dinoToken.color.blingGray400
                                      .resolve(context),
                              width: borderWidth,
                            ),
                            borderRadius: BorderRadius.circular(borderRadius),
                          )
                        : OutlineInputBorder(
                            borderSide: BorderSide(
                              color: borderColor?.resolve(context) ??
                                  $dinoToken.color.blingGray400
                                      .resolve(context),
                              width: borderWidth,
                            ),
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                focusedBorder: border == DinoTextFieldBorder.none
                    ? InputBorder.none
                    : border == DinoTextFieldBorder.underline
                        ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: focusedBorderColor?.resolve(context) ??
                                  $dinoToken.color.primary.resolve(context),
                              width: focusedBorderWidth,
                            ),
                            borderRadius: BorderRadius.circular(borderRadius),
                          )
                        : OutlineInputBorder(
                            borderSide: BorderSide(
                              color: focusedBorderColor?.resolve(context) ??
                                  $dinoToken.color.primary.resolve(context),
                              width: focusedBorderWidth,
                            ),
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                errorText: status == DinoFieldStatus.error &&
                        errorText?.isNotEmpty == true
                    ? errorText
                    : null,
                errorBorder: border == DinoTextFieldBorder.none
                    ? InputBorder.none
                    : border == DinoTextFieldBorder.underline
                        ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: errorBorderColor?.resolve(context) ??
                                  $dinoToken.color.brandBlingPink500
                                      .resolve(context),
                              width: errorBorderWidth,
                            ),
                            borderRadius: BorderRadius.circular(borderRadius),
                          )
                        : OutlineInputBorder(
                            borderSide: BorderSide(
                              color: errorBorderColor?.resolve(context) ??
                                  $dinoToken.color.brandBlingPink500
                                      .resolve(context),
                              width: errorBorderWidth,
                            ),
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
              ),
            ),
            if (maxLength != null) ...[
              Positioned(
                right: 16,
                bottom: 16,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    return Row(
                      children: [
                        DinoText.custom(
                          text: '${controller.text.length}',
                          color: $dinoToken.color.blingGray900,
                          fontSize: 12.64,
                          fontWeight: FontWeight.w400,
                        ),
                        DinoText.custom(
                          text: '/$maxLength',
                          color: $dinoToken.color.blingGray400,
                          fontSize: 12.64,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ]
          ],
        ),
        if (status == DinoFieldStatus.error) ...[
          Padding(
            padding: errorPadding ?? EdgeInsets.zero,
            child: DinoText.custom(
              text: errorText ?? '',
              color: errorColor ?? $dinoToken.color.brandBlingPink500,
              fontWeight: errorFontWeight ?? FontWeight.w500,
              fontSize: errorFontSize ?? 12,
            ),
          ),
        ]
      ],
    );
  }
}
