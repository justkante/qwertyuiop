import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:flutter/material.dart';

class EmptyMessagesWidget extends StatelessWidget {
  const EmptyMessagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No messages yet\nStart the conversation!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.caption,
          fontSize: 14,
        ),
      ),
    );
  }
}
