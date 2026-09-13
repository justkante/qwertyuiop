import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Content widget shown inside an [AppDialog] to ask the user whether they
/// want a guided tour of the app.
class TourDialogContent extends StatelessWidget {
  const TourDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 225.h,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.spot800,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
            ),
            Positioned(bottom: -20.h, child: Image.asset(AppImages.map, width: 270)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              16.0.height,
              Text(
                'Welcome to Creatify! 🎉',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.subHeading,
                ),
                textAlign: TextAlign.center,
              ),
              8.0.height,
              Text(
                'Would you like a quick tour to learn how everything works?',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.body,
                ),
                textAlign: TextAlign.center,
              ),
              24.0.height,
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: MainButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      text: 'Skip tour',
                      color: Colors.white,
                      textColor: AppColors.btnText,
                      borderColor: AppColors.grey300,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  Expanded(
                    child: MainButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      text: 'Show me around!',
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
              32.0.height,
            ],
          ),
        ),
      ],
    );
  }
}
