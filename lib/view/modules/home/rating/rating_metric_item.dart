import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RatingMetricItem extends StatelessWidget {
  final int starCount;
  final int reviewCount;
  final double percentage;
  final Color? progressColor;

  const RatingMetricItem({
    super.key,
    required this.starCount,
    required this.reviewCount,
    required this.percentage,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Star count with star icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                starCount.toString(),
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.body,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              4.0.width,
              SvgPicture.asset(
                AppImages.star,
                width: 12,
                height: 12,
                colorFilter: const ColorFilter.mode(
                  AppColors.highlightYellow,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          12.0.width,

          // Progress bar
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: progressColor ?? AppColors.highlightYellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          12.0.width,

          // Review count
          SizedBox(
            width: 30,
            child: Text(
              reviewCount.toString(),
              textAlign: TextAlign.end,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.subHeading,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
