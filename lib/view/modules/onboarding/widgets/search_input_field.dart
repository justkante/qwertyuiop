import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    return SizedBox(
      height: 45,
      child: SearchBar(
        controller: controller,
        onSubmitted: onSubmitted,
        backgroundColor: WidgetStateProperty.all(AppColors.grey50),
        elevation: WidgetStateProperty.all(0),
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SvgPicture.asset(
            width: 20,
            height: 20,
            AppImages.search,
            colorFilter: AppColors.icons.colorFilterMode(),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12),
        ),
        side: WidgetStateProperty.all(
          const BorderSide(
            color: AppColors.surface,
            width: 1,
          ),
        ),
        hintText: hintText ?? 'Search Name, Role...',
        hintStyle: WidgetStateProperty.all(
          context.textTheme.bodySmall?.copyWith(
            color: AppColors.body,
          ),
        ),
        textStyle: WidgetStateProperty.all(
          context.textTheme.bodySmall?.copyWith(
            color: AppColors.subHeading,
          ),
        ),
      ),
    );
  }
}
