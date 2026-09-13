import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CardAndTextWidget extends StatelessWidget {
  final String? text, illustration, illustrationWithoutBorder;
  const CardAndTextWidget({
    super.key,
    this.text,
    this.illustration,
    this.illustrationWithoutBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        illustrationWithoutBorder == null
            ? Container(
                padding: const EdgeInsets.all(28),
                decoration: const BoxDecoration(
                  color: AppColors.coral50,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(illustration ?? AppImages.calendarIllustration),
              )
            : SvgPicture.asset(illustrationWithoutBorder!),
        12.0.height,
        Text(
          text ?? 'You do not have any active bookings yet',
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
