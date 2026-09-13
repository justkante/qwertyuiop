import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';

class ChatErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const ChatErrorWidget({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.highlightRed,
          ),
          16.0.height,
          Text(
            'Failed to load messages',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.subHeading,
            ),
          ),
          8.0.height,
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.highlightRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
