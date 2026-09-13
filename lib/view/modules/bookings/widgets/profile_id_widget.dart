import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class ProfileIdWidget extends StatelessWidget {
  final String profileId;
  const ProfileIdWidget({
    super.key,
    required this.profileId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.grey150,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              profileId,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        8.0.width,
        InkWell(
          onTap: () {
            Clipboard.setData(
              ClipboardData(
                text: profileId,
              ),
            ).then((value) {
              if (!context.mounted) return;

              ToastDialog.showSuccess('Profile Link Copied', context);
            });
          },
          child: Row(
            children: [
              SvgPicture.asset(
                AppImages.copy,
                width: 16,
                height: 16,
              ),
              4.0.width,
              Text(
                "Copy",
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.highlightBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
