import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class QuickDetail extends StatelessWidget {
  final String icon, text;
  const QuickDetail({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(icon),
        4.0.width,
        Text(
          text,
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColors.btnText,
          ),
        ),
      ],
    );
  }
}
