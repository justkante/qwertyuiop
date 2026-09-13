import 'dart:typed_data';

import 'package:creatify_mobile/data/models/responses/portfolio_dto.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/widgets/media_viewer/expanded_media_viewer.dart';
import 'package:creatify_mobile/view/widgets/quick_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UploadedImageWithDelete extends StatelessWidget {
  final PortfolioItem? portfolioItem;
  final Function()? onDelete;
  final bool expandMedia;
  const UploadedImageWithDelete({
    super.key,
    this.portfolioItem,
    this.onDelete,
    this.expandMedia = false,
  });

  void _showExpandedMedia(BuildContext context) {
    if (!expandMedia || portfolioItem == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      useSafeArea: false,
      builder: (context) => ExpandedMediaViewer(
        portfolioItem: portfolioItem!,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: expandMedia ? () => _showExpandedMedia(context) : null,
          child: switch (portfolioItem?.mediaType) {
            MediaType.image => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  portfolioItem?.filePath ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                      ? child
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                        ),
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            MediaType.video => FutureBuilder<Uint8List?>(
                future: VideoThumbnail.thumbnailData(
                  video: portfolioItem?.filePath ?? '',
                  imageFormat: ImageFormat.JPEG,
                  quality: 75,
                ),
                builder: (context, snapshot) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData)
                          Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        else if (snapshot.hasError)
                          Container(
                            color: AppColors.black2,
                            child: const Center(
                              child: Icon(
                                Icons.videocam_off,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          )
                        else
                          Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                              ),
                            ),
                          ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 34.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            MediaType.document => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    SvgPicture.asset(
                      AppImages.pdf,
                      height: 40.h,
                      width: 40.w,
                    ),
                    const Spacer(),
                    Text(
                      portfolioItem?.fileName ?? 'document.pdf',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: AppColors.subHeading,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            MediaType.audio => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    SvgPicture.asset(
                      AppImages.audioDoc,
                      height: 40.h,
                      width: 40.w,
                    ),
                    const Spacer(),
                    Text(
                      portfolioItem?.fileName ?? 'document.pdf',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: AppColors.subHeading,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            _ => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey,
                ),
                child: Center(
                  child: Icon(
                    Icons.insert_drive_file,
                    color: Colors.white,
                    size: 50.w,
                  ),
                ),
              ),
          },
        ),
        Visibility(
          visible: onDelete != null,
          child: Positioned(
            top: -9,
            right: -12.w,
            child: InkWell(
              onTap: onDelete,
              child: const QuickIcon(
                icon: AppImages.cancel,
                color: Colors.red,
                bgColor: Colors.white,
                size: 18,
                padding: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
