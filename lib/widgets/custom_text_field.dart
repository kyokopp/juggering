import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.focusNode,
    this.nextFocusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  String? _errorText;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    widget.controller.addListener(_onTextChanged);
    widget.focusNode?.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode?.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_hasInteracted && mounted) {
      setState(() {
        _errorText = widget.validator?.call(widget.controller.text);
      });
    }
  }

  void _onFocusChanged() {
    if (!widget.focusNode!.hasFocus && mounted) {
      setState(() {
        _hasInteracted = true;
        _errorText = widget.validator?.call(widget.controller.text);
      });
    }
  }

  void _togglePasswordVisibility() {
    HapticFeedback.lightImpact();
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null && _errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          placeholder: widget.placeholder,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError
                  ? CupertinoColors.systemRed.withValues(alpha: 0.6)
                  : CupertinoColors.systemGrey2.withValues(alpha: 0.3),
              width: hasError ? 1.5 : 0.5,
            ),
          ),
          style: const TextStyle(color: CupertinoColors.white, fontSize: 16),
          placeholderStyle: TextStyle(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.7),
            fontSize: 16,
          ),
          cursorColor: CupertinoColors.systemRed,
          suffix: widget.isPassword
              ? CupertinoButton(
            padding: const EdgeInsets.only(right: 8),
            onPressed: _togglePasswordVisibility, minimumSize: Size(0, 0),
            child: Icon(
              _obscureText
                  ? CupertinoIcons.eye_slash_fill
                  : CupertinoIcons.eye_fill,
              color: CupertinoColors.systemGrey,
              size: 20,
            ),
          )
              : null,
          onSubmitted: (_) {
            if (widget.nextFocusNode != null) {
              FocusScope.of(context).requestFocus(widget.nextFocusNode);
            } else {
              widget.onSubmitted?.call();
            }
          },
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_circle_fill,
                  color: CupertinoColors.systemRed,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: const TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}