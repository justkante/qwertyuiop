import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CachedMediaImageHandler extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  const CachedMediaImageHandler({super.key, this.imageUrl, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    if ((imageUrl ?? AppImages.curtain).contains(".svg")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SvgPicture.network(
          imageUrl ?? "",
          height: height,
          width: width,
          fit: BoxFit.cover,
          placeholderBuilder: (context) {
            return Container(
              height: 80,
              width: 80,
              color: AppColors.grey100,
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 100,
              color: AppColors.grey100,
              child: const Icon(Icons.image_not_supported),
            );
          },
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          fit: BoxFit.cover,
          imageUrl ?? "",
          width: width,
          height: height,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 80,
              width: 80,
              color: AppColors.grey100,
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 100,
              color: AppColors.grey100,
              child: const Icon(Icons.image_not_supported),
            );
          },
        ),
      );
    }
  }
}
