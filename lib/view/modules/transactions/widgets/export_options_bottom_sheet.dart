import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';

class ExportOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onExportPdf;
  final VoidCallback onExportPng;

  const ExportOptionsBottomSheet({
    super.key,
    required this.onExportPdf,
    required this.onExportPng,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          20.0.height,

          // Title
          Text(
            'Export Receipt',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.subHeading,
            ),
          ),
          8.0.height,

          Text(
            'Choose your preferred format',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.subHeading,
            ),
          ),
          16.0.height,

          // Export as PDF option
          _buildExportOption(
            context: context,
            icon: Icons.picture_as_pdf_outlined,
            title: 'Export as PDF',
            description: 'Save receipt as PDF document',
            onTap: () {
              Navigator.pop(context);
              onExportPdf();
            },
          ),
          16.0.height,

          // Export as PNG option
          _buildExportOption(
            context: context,
            icon: Icons.image_outlined,
            title: 'Export as PNG',
            description: 'Save receipt as image',
            onTap: () {
              Navigator.pop(context);
              onExportPng();
            },
          ),
          12.0.height,
        ],
      ),
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            16.0.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.subHeading,
                    ),
                  ),
                  4.0.height,
                  Text(
                    description,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.subHeading.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.subHeading.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
