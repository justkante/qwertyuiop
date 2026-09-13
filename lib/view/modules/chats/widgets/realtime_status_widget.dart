import 'package:creatify_mobile/view/modules/chats/vm/chat_providers.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';

class RealtimeStatusWidget extends StatelessWidget {
  final bool isOnline;
  final int unreadCount;
  final bool hasNewMessages;
  final String? lastSeen;

  const RealtimeStatusWidget({
    super.key,
    required this.isOnline,
    this.unreadCount = 0,
    this.hasNewMessages = false,
    this.lastSeen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Online/offline indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.highlightGreen : AppColors.grey400,
                shape: BoxShape.circle,
              ),
            ),
            6.0.width,
            Text(
              isOnline ? 'Online' : formatLastSeen(lastSeen),
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: isOnline ? AppColors.highlightGreen : AppColors.caption,
              ),
            ),
          ],
        ),

        // New message indicator
        if (hasNewMessages) ...[
          4.0.height,
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              6.0.width,
              Text(
                'New message',
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],

        // Unread count badge
        if (unreadCount > 0) ...[
          4.0.height,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.highlightRed,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class MessageStatusIndicator extends StatelessWidget {
  final bool isSent;
  final bool isDelivered;
  final bool isRead;
  final bool isFailed;

  const MessageStatusIndicator({
    super.key,
    required this.isSent,
    this.isDelivered = false,
    this.isRead = false,
    this.isFailed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFailed) {
      return const Icon(
        Icons.error_outline,
        size: 14,
        color: AppColors.highlightRed,
      );
    }

    if (isRead) {
      return const Icon(
        Icons.done_all,
        size: 14,
        color: Colors.blue,
      );
    }

    if (isDelivered) {
      return const Icon(
        Icons.done_all,
        size: 14,
        color: AppColors.grey400,
      );
    }

    if (isSent) {
      return const Icon(
        Icons.done,
        size: 14,
        color: AppColors.grey400,
      );
    }

    return const SizedBox(
      width: 14,
      height: 14,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.grey400),
      ),
    );
  }
}
