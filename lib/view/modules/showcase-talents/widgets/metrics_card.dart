import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';

class MetricsCard extends StatelessWidget {
  final String? value, label, tooltipMessage;
  const MetricsCard({
    super.key,
    this.value,
    this.label,
    this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.grey100,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label ?? 'Label',
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: AppColors.subHeading,
                  ),
                ),
              ),
              5.0.width,
              Tooltip(
                preferBelow: false,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: AppColors.highlightCoral,
                  borderRadius: BorderRadius.circular(6),
                ),
                richMessage: TextSpan(
                  text: "$label:\n",
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: tooltipMessage,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
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
          ),
          Text(
            value ?? '0',
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: 23,
              color: AppColors.black2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
