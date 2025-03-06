import 'package:design_systems/b2b/b2b.dart';
import 'package:design_systems/b2b/components/textfield/textfield.style.dart';
import 'package:design_systems/b2b/components/textfield/textfield.variant.dart';
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

class B2bTextField extends StatefulWidget {
  final B2bTextFieldStatus status;
  final B2bTextFieldSize size;
  final Widget? leading;
  final Widget? trailing;
  final String? Function(String)? onChanged;
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
    this.leading,
    this.trailing,
    this.onChanged,
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
  final TextEditingController _controller = TextEditingController();
  String _errorText = '';
  bool _isFocused = false;

  B2bTextfieldStyle get $style => B2bTextfieldStyle(
      widget.size,
      (_errorText.isNotEmpty && widget.isError)
          ? B2bTextFieldStatus.error
          : _isFocused
              ? B2bTextFieldStatus.write
              : widget.status);

  @override
  void initState() {
    super.initState();
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
            widget.defaultColor ?? $b2bToken.color.gray300.resolve(context),
            widget.writeColor ?? $b2bToken.color.pink400.resolve(context),
            widget.errorColor ?? $b2bToken.color.pink500.resolve(context),
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
            style: $b2bToken.textStyle.body2regular.resolve(context).merge(
                  TextStyle(
                    color: $b2bToken.color.labelNomal.resolve(context),
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
              contentPadding: const EdgeInsets.all(16),
              hintText: widget.hint,
              hintStyle:
                  $b2bToken.textStyle.body2regular.resolve(context).merge(
                        TextStyle(
                          color: $b2bToken.color.labelDisabled.resolve(context),
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
