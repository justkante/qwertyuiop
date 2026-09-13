import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class QuickIcon extends StatelessWidget {
  final Function()? onTap;
  final String icon;
  final double? size, padding;
  final Color? color, bgColor, borderColor;

  const QuickIcon({
    super.key,
    this.onTap,
    required this.icon,
    this.color,
    this.bgColor,
    this.borderColor,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding ?? 14),
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.grey200,
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: SvgPicture.asset(
          icon,
          width: size ?? 10,
          colorFilter: color?.colorFilterMode() ?? AppColors.grey400.colorFilterMode(),
        ),
      ),
    );
  }
}
