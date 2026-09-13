import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
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
          borderRadius: 10,
          color: AppColors.spot500,
          strokeWidth: 1.0,
          dashWidth: 10.0,
        ),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
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
                : SvgPicture.asset(AppImages.solidAdd),
          ),
        ),
      ),
    );
  }
}

// class UploadedMediaCard extends StatelessWidget {
//   final String? icon, title;
//   final bool? isLoading;
//   final Function()? onTap;
//   const UploadedMediaCard({
//     super.key,
//     this.icon,
//     this.title,
//     this.isLoading,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: AppColors.kGrey100,
//       ),
//       child: Row(
//         children: [
//           SvgPicture.asset(icon ?? AppImages.video),
//           12.0.width,
//           Expanded(
//             flex: 4,
//             child: Text(
//               title ?? 'introduction.mp4',
//               style: context.textTheme.bodyMedium?.copyWith(color: AppColors.black),
//             ),
//           ),
//           const Spacer(),
//           if (onTap != null) ...[
//             isLoading ?? false
//                 ? LoadingAnimationWidget.discreteCircle(
//                     color: AppColors.kGrey600,
//                     secondRingColor: AppColors.richBlue,
//                     thirdRingColor: AppColors.roseCoral,
//                     size: 20,
//                   )
//                 : InkWell(
//                     onTap: onTap,
//                     child: SvgPicture.asset(
//                       AppImages.trash,
//                       colorFilter: AppColors.kGrey600.colorFilterMode(),
//                     ),
//                   )
//           ],
//         ],
//       ),
//     );
//   }
// }
