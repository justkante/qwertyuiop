import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController? controller;
  final VoidCallback? onSend;
  final VoidCallback? onAttachment;
  final Function(String)? onChanged;
  final Function()? onTap;
  final bool isLoading;
  final bool readOnly;
  final String? hintText;

  const ChatInputField({
    super.key,
    this.controller,
    this.onSend,
    this.onAttachment,
    this.onChanged,
    this.onTap,
    this.isLoading = false,
    this.readOnly = false,
    this.hintText,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
    _hasText = widget.controller?.text.trim().isNotEmpty ?? false;
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller?.text.trim().isNotEmpty ?? false;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ChatTextField(
                readOnly: widget.readOnly,
                controller: widget.controller,
                onChanged: widget.onChanged,
                onTap: widget.onTap,
                hintText: widget.hintText,
                suffixIcon: GestureDetector(
                  onTap: widget.onAttachment,
                  child: SvgPicture.asset(
                    AppImages.add,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ),
          ),
        ),
        12.0.width,
        GestureDetector(
          onTap: widget.isLoading ? null : widget.onSend,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (_hasText && !widget.isLoading) ? AppColors.primary : AppColors.grey300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class ChatTextField extends StatefulWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function()? onTap;
  final String? hintText;
  final Widget? suffixIcon;
  final bool? autofocus;
  final bool readOnly;
  const ChatTextField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onTap,
    this.hintText,
    this.suffixIcon,
    this.autofocus = false,
    this.readOnly = false,
  });

  @override
  State<ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: TextFormField(
        autocorrect: true,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus ?? false,
        controller: widget.controller,
        scrollController: _scrollController,
        maxLines: null,
        minLines: 1,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.multiline,
        style: context.textTheme.bodySmall?.copyWith(
          color: AppColors.subHeading,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Type a message',
          hintStyle: context.textTheme.bodySmall?.copyWith(
            color: AppColors.body,
          ),
          suffixIcon: widget.suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.highlightBlue, width: 1),
          ),
          filled: true,
          fillColor: AppColors.grey50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: validateGeneric,
      ),
    );
  }
}
