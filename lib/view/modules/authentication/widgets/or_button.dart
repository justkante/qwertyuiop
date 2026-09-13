import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class OrButton extends StatelessWidget {
  const OrButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 4,
            color: AppColors.grey200,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'or',
            style: context.textTheme.bodyMedium?.copyWith(),
          ),
        ),
        Expanded(
          child: Container(
            height: 4,
            color: AppColors.grey200,
          ),
        ),
      ],
    );
  }
}
