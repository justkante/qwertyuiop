import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/quick_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TalentCard extends StatelessWidget {
  final String icon, illustration, title, subtitle;
  final Color bgColor, iconBgColor, iconColor;
  final bool isLoading;
  final Function()? onTap;
  const TalentCard({
    super.key,
    required this.icon,
    required this.illustration,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconBgColor,
    required this.iconColor,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 20, 0, 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuickIcon(
                      padding: 8,
                      icon: icon,
                      size: 20,
                      color: iconColor,
                      bgColor: iconBgColor,
                    ),
                    12.0.height,
                    Text(
                      title,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SvgPicture.asset(
                  illustration,
                  height: 90,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                ),
                32.0.height,
                const Spacer(),
                isLoading
                    ? CircularProgressIndicator.adaptive(
                        constraints: BoxConstraints.tight(const Size(16, 16)),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 2,
                      )
                    : const QuickIcon(
                        padding: 4,
                        icon: AppImages.chevronRight,
                        size: 16,
                        color: AppColors.black2,
                        bgColor: Colors.white,
                      ),
                12.0.width,
              ],
            )
          ],
        ),
      ),
    );
  }
}
