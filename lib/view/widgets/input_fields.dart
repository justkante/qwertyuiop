import 'dart:io';

import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/keypad_done.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextInputField extends StatefulWidget {
  final TextInputType inputType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final String? header;
  final String hint;
  final bool readOnly;
  final bool obscureText;
  final bool autoCorrect;
  final Function()? onPressed;
  final Function(String)? onChanged;
  final int? maxLength;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon, suffixIcon;
  final TextCapitalization? textCapitalization;
  final TextStyle? headerStyle;
  final TextStyle? style;
  final TextStyle? hintStyle;
  const TextInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.inputType,
    this.textInputAction = TextInputAction.next,
    required this.validator,
    this.maxLength,
    this.autoCorrect = true,
    this.obscureText = false,
    this.readOnly = false,
    this.onPressed,
    this.header,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
    this.inputFormatters,
    this.onChanged,
    this.textCapitalization,
    this.headerStyle,
    this.style,
    this.hintStyle,
  });

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  FocusNode? _numberFieldFocusNode;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Only create custom focus node for number keyboards on iOS
    if (Platform.isIOS && _isNumberKeyboard(widget.inputType) && !widget.readOnly) {
      _numberFieldFocusNode = FocusNode();
      _numberFieldFocusNode!.addListener(() {
        if (_numberFieldFocusNode!.hasFocus) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      });
    }
  }

  bool _isNumberKeyboard(TextInputType inputType) {
    return inputType == TextInputType.number ||
        inputType == TextInputType.phone ||
        inputType == const TextInputType.numberWithOptions(decimal: true) ||
        inputType == const TextInputType.numberWithOptions(signed: true);
  }

  static const double _kDoneBarHeight = 100.0;

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        right: 0.0,
        left: 0.0,
        child: const KeyboardDoneWidget(),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _numberFieldFocusNode?.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.header != null) ...[
          Text(
            widget.header ?? "",
            style: widget.headerStyle ?? Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.subHeading,
                  fontWeight: FontWeight.w500,
                ),
          ),
          6.0.height,
        ],
        TextFormField(
          focusNode: _numberFieldFocusNode,
          autocorrect: widget.autoCorrect,
          controller: widget.controller,
          keyboardType: widget.inputType,
          textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
          textInputAction: widget.textInputAction,
          maxLength: widget.maxLength,
          cursorColor: AppColors.primary,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: widget.obscureText,
          obscuringCharacter: '●',
          validator: widget.validator,
          readOnly: widget.readOnly,
          onTap: widget.onPressed,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          textAlign: TextAlign.start,
          scrollPadding: _numberFieldFocusNode != null
              ? const EdgeInsets.only(bottom: _kDoneBarHeight)
              : const EdgeInsets.all(20.0),
          inputFormatters: widget.inputFormatters,
          style: widget.style ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.heading,
                overflow: TextOverflow.ellipsis,
              ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: widget.hintStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.body),
            suffixIcon: widget.suffixIcon,
            prefixIcon: widget.prefixIcon,
          ),
        )
      ],
    );
  }
}
