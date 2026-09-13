import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyChatsWidget extends StatelessWidget {
  const EmptyChatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SvgPicture.asset(
                AppImages.noMessages,
              ),
            ),
            24.0.height,
            Text(
              'No chats yet',
              style: context.textTheme.displayMedium?.copyWith(
                fontSize: 18,
                color: AppColors.subHeading,
              ),
            ),
            8.0.height,
            Text(
              'Messaging is only available for confirmed bookings - book or get booked to start chatting',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.caption,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
