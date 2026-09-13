import 'dart:developer';

import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'dart:io';

// Attachment Preview Widget
class AttachmentPreview extends StatelessWidget {
  final File file;
  final String attachmentType;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const AttachmentPreview({
    super.key,
    required this.file,
    required this.attachmentType,
    required this.onSend,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Preview Attachment',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.black2,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.icons),
              onPressed: onCancel,
            ),
          ],
        ),
        16.0.height,

        // Preview based on type
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildPreview(context),
        ),

        24.0.height,

        // File info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _getFileIcon(),
                color: AppColors.primary,
                size: 24,
              ),
              10.0.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   file.path.split('/').last,
                    //   style: context.textTheme.bodyMedium?.copyWith(
                    //     fontWeight: FontWeight.w500,
                    //     color: AppColors.subHeading,
                    //   ),
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    Text(
                      _getFileSize(),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.subHeading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        24.0.height,

        // Action buttons
        Row(
          children: [
            Expanded(
              child: MainButton(
                color: AppColors.highlightRed50,
                textColor: AppColors.btnText,
                onPressed: onCancel,
                text: 'Cancel',
              ),
            ),
            16.0.width,
            Expanded(
              child: MainButton(
                onPressed: onSend,
                text: 'Send',
              ),
            ),
          ],
        ),
        16.0.height,
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    switch (attachmentType) {
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorPreview();
            },
          ),
        );
      case 'video':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.video_library,
                size: 64,
                color: AppColors.primary,
              ),
              16.0.height,
              Text(
                file.path.split('/').last,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.subHeading,
                ),
              ),
            ],
          ),
        );
      case 'audio':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.audio_file,
                size: 64,
                color: AppColors.primary,
              ),
              16.0.height,
              Text(
                file.path.split('/').last,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.subHeading,
                ),
              ),
            ],
          ),
        );
      default:
        log('Unknown attachment type: $attachmentType');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.insert_drive_file,
                size: 64,
                color: AppColors.primary,
              ),
              16.0.height,
              Text(
                file.path.split('/').last,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.subHeading,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildErrorPreview() {
    return const Center(
      child: Icon(
        Icons.broken_image,
        size: 64,
        color: AppColors.grey300,
      ),
    );
  }

  IconData _getFileIcon() {
    switch (attachmentType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_file;
      case 'audio':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileSize() {
    final bytes = file.lengthSync();
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
