import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CachedImageHandler extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  const CachedImageHandler({super.key, this.imageUrl, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    if ((imageUrl ?? AppImages.curtain).contains('.svg')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: SvgPicture.network(
          imageUrl ?? "",
          height: height ?? 30,
          width: width ?? 30,
          placeholderBuilder: (context) {
            return CircleAvatar(
              radius: (height ?? 56) / 2,
              backgroundColor: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(7.5),
                child: SvgPicture.asset(
                  AppImages.dummyAvatarSvg,
                  colorFilter: Colors.white.colorFilterMode(),
                  height: height ?? 30,
                  width: width ?? 30,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              radius: (height ?? 56) / 2,
              backgroundColor: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(7.5),
                child: SvgPicture.asset(
                  AppImages.dummyAvatarSvg,
                  colorFilter: Colors.white.colorFilterMode(),
                  height: height ?? 30,
                  width: width ?? 30,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          imageUrl ?? "",
          width: width ?? 56,
          height: height ?? 56,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircleAvatar(
              radius: (height ?? 56) / 2,
              backgroundColor: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(7.5),
                child: SvgPicture.asset(
                  AppImages.dummyAvatarSvg,
                  colorFilter: Colors.white.colorFilterMode(),
                  height: height ?? 56,
                  width: width ?? 56,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              radius: (height ?? 56) / 2,
              backgroundColor: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(7.5),
                child: SvgPicture.asset(
                  AppImages.dummyAvatarSvg,
                  colorFilter: Colors.white.colorFilterMode(),
                  height: height ?? 56,
                  width: width ?? 56,
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
