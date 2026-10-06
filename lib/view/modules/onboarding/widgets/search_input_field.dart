import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';

class SearchTextInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onSubmitted;
  const SearchTextInputField({
    super.key,
    this.controller,
    this.hintText,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText ?? 'Search...',
          hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 13, color: AppColors.body),
          prefixIcon: const Icon(Icons.search, color: AppColors.body, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}
