import 'dart:io';

import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/keypad_done.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';

/// A reusable TextFormField specifically for number inputs with iOS done button support
class NumberInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? header;
  final String? headerInfo;
  final double? headerSize;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;
  final InputDecoration? decoration;
  final TextInputType keyboardType;
  final bool allowDecimal;

  const NumberInputField({
    super.key,
    required this.controller,
    this.header,
    this.headerInfo,
    this.headerSize = 12,
    this.hintText,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.inputFormatters,
    this.style,
    this.decoration,
    this.keyboardType = TextInputType.number,
    this.allowDecimal = false,
  });

  @override
  State<NumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  FocusNode? _numberFieldFocusNode;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Only create custom focus node for number keyboards on iOS
    if (Platform.isIOS) {
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
          Row(
            children: [
              Text(
                widget.header ?? "",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: widget.headerSize,
                      color: AppColors.subHeading,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              if (widget.headerInfo != null) ...[
                3.0.width,
                Tooltip(
                  preferBelow: false,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: AppColors.highlightCoral,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  message: widget.headerInfo,
                  textStyle: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.white,
                  ),
                  showDuration: 2000.ms,
                  triggerMode: TooltipTriggerMode.tap,
                  child: SvgPicture.asset(
                    AppImages.info,
                    height: 12,
                    width: 12,
                  ),
                ),
              ],
            ],
          ),
          6.0.height,
        ],
        TextFormField(
          focusNode: _numberFieldFocusNode,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          style: widget.style,
          scrollPadding: const EdgeInsets.only(bottom: _kDoneBarHeight),
          decoration: widget.decoration ??
              InputDecoration(
                hintText: widget.hintText ?? '0',
              ),
        ),
      ],
    );
  }
}
