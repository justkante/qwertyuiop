import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/dash_rectangle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UploadMediaCard extends StatefulWidget {
  final String? icon, title, subtitle;
  final bool isLoading;
  final Function()? onTap;
  const UploadMediaCard({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
    this.onTap,
    this.isLoading = false,
  });

  @override
  State<UploadMediaCard> createState() => _UploadMediaCardState();
}

class _UploadMediaCardState extends State<UploadMediaCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: CustomPaint(
        painter: DashedRectanglePainter(
          borderRadius: 14,
          color: AppColors.spot500,
          strokeWidth: 1.0,
          dashWidth: 8.0,
        ),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppImages.solidAdd,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                      ),
                    ),
                    10.0.height,
                    Text(widget.title ?? 'Upload file', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B3131))),
                    4.0.height,
                    Text(widget.subtitle ?? 'Images, videos, or documents (Max 50MB)', style: const TextStyle(fontSize: 11, color: AppColors.body), textAlign: TextAlign.center),
                  ],
                ),
        ),
      ),
    );
  }
}
