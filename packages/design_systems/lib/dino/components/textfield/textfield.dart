import 'package:design_systems/dino/dino.dart';
import 'package:design_systems/dino/components/textfield/textfield.style.dart';
import 'package:design_systems/dino/components/textfield/textfield.variant.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class B2bTextField extends StatefulWidget {
  final B2bTextFieldStatus status;
  final B2bTextFieldSize size;
  B2bTextFieldBoder boder;
  final Widget? leading;
  final Widget? trailing;
  final String? Function(String)? onChanged;
  String initialValue;
  String title;
  String hint;
  String errorText;
  bool isError;
  Color? defaultColor;
  Color? writeColor;
  Color? errorColor;

  B2bTextField({
    super.key,
    required this.status,
    required this.size,
    this.boder = B2bTextFieldBoder.box,
    this.leading,
    this.trailing,
    this.onChanged,
    this.initialValue = '',
    this.title = '',
    this.errorText = '',
    this.hint = '',
    required this.isError,
    this.defaultColor,
    this.writeColor,
    this.errorColor,
  });

  @override
  State<B2bTextField> createState() => _B2bTextFieldState();
}

class _B2bTextFieldState extends State<B2bTextField> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;
  String _errorText = '';
  bool _isFocused = false;

  B2bTextfieldStyle get $style => B2bTextfieldStyle(
      widget.size,
      widget.boder,
      (_errorText.isNotEmpty && widget.isError)
          ? B2bTextFieldStatus.error
          : _isFocused
              ? B2bTextFieldStatus.write
              : widget.status);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _errorText = widget.errorText;
    _focusNode.removeListener(listener);
    _focusNode.addListener(listener);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void listener() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty) ...{
          Box(
            style: $style.title(),
            child: StyledText(widget.title),
          ),
        },
        Box(
          style: $style.container(
            widget.defaultColor ?? $dinoToken.color.black.resolve(context),
            widget.writeColor ?? $dinoToken.color.brandBlingPink400.resolve(context),
            widget.errorColor ?? $dinoToken.color.brandBlingPink500.resolve(context),
          ),
          child: TextField(
            textAlignVertical: TextAlignVertical.top,
            keyboardType: B2bTextFieldSize.large != widget.size
                ? TextInputType.text
                : TextInputType.multiline,
            minLines: B2bTextFieldSize.large == widget.size ? 3 : 1,
            maxLines: B2bTextFieldSize.large == widget.size ? 3 : 1,
            focusNode: _focusNode,
            controller: _controller,
            style: $dinoToken.typography.bodyS.resolve(context).merge(
                  TextStyle(
                    color: $dinoToken.color.black.resolve(context),
                  ),
                ),
            onChanged: (value) => setState(
              () {
                var result = widget.onChanged?.call(value);
                _errorText = result ?? '';
              },
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: widget.boder == B2bTextFieldBoder.underline
                  ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.defaultColor ?? $dinoToken.color.black.resolve(context),
                        width: 0.7,
                      ),
                    )
                  : InputBorder.none,
              focusedBorder: widget.boder == B2bTextFieldBoder.underline
                  ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.writeColor ?? $dinoToken.color.brandBlingPink400.resolve(context),
                        width: 1.0,
                      ),
                    )
                  : InputBorder.none,
              contentPadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 8,
              ),
              hintText: widget.hint,
              hintStyle:
                  $dinoToken.typography.bodyS.resolve(context).merge(
                        TextStyle(
                          color: $dinoToken.color.blingGray600.resolve(context),
                        ),
                      ),
              prefixIcon: widget.leading == null
                  ? null
                  : Align(
                      alignment: B2bTextFieldSize.large == widget.size
                          ? Alignment.topCenter
                          : Alignment.center,
                      widthFactor: 1.0,
                      heightFactor:
                          B2bTextFieldSize.large == widget.size ? 3.2 : null,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 6),
                        child: widget.leading,
                      ),
                    ),
              prefixIconConstraints: const BoxConstraints(
                minHeight: 24,
                minWidth: 24,
              ),
              suffixIcon: widget.trailing == null
                  ? null
                  : Align(
                      alignment: B2bTextFieldSize.large == widget.size
                          ? Alignment.topCenter
                          : Alignment.center,
                      widthFactor: 1.0,
                      heightFactor:
                          B2bTextFieldSize.large == widget.size ? 3.2 : null,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 6, right: 16),
                          child: widget.trailing),
                    ),
              suffixIconConstraints: const BoxConstraints(
                minHeight: 24,
                minWidth: 24,
              ),
            ),
          ),
        ),
        if (widget.isError) ...{
          Box(
            style: $style.error(),
            child: StyledText(_errorText),
          ),
        },
      ],
    );
  }
}
