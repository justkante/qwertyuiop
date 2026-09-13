import 'package:creatify_mobile/data/models/responses/conversation_dto.dart';
import 'package:creatify_mobile/view/modules/chats/vm/chat_providers.dart';
import 'package:creatify_mobile/view/modules/chats/chat_conversation_view.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/cache_image_handler.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ChatCard extends ConsumerWidget {
  final ConversationDto conversation;

  const ChatCard({
    super.key,
    required this.conversation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = SharedPrefManager.userId;
    final hasUnreadMessages = ((conversation.unreadCount ?? 0) > 0) &&
        (conversation.lastMessage?.senderId == conversation.otherUser?.id);

    // Check if last message was sent by current user
    final isLastMessageFromUser = conversation.lastMessage?.senderId == currentUserId;

    final otherUserId = conversation.otherUser?.id;
    final isOnline = otherUserId != null
        ? ref.watch(userPresenceProvider(otherUserId))
        : conversation.otherUser?.isOnline ?? false;

    // Watch for typing indicator in this conversation
    final typingUsers = ref.watch(typingUsersProvider(conversation.id ?? ''));
    final isOtherUserTyping = typingUsers.contains(conversation.otherUser?.id);

    final lastMessageText = isOtherUserTyping ? 'typing...' : _getLastMessageText();
    final timeText = _formatTime();
    final userInitials = conversation.otherUser?.name?.substring(0, 1).toUpperCase() ?? 'U';

    return InkWell(
      onTap: () {
        context.push(ChatConversationView(conversation: conversation));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                conversation.otherUser?.avatar != null
                    ? CachedImageHandler(
                        imageUrl: conversation.otherUser!.avatar!,
                        height: 36,
                        width: 36,
                      )
                    : InitialAvatar(
                        margin: EdgeInsets.zero,
                        backgroundColor: AppColors.spot200,
                        initials: userInitials,
                        size: 20,
                      ),
                if (isOnline)
                  Positioned(
                    right: 1,
                    bottom: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.highlightGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            12.0.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUser?.name ?? 'Unknown User',
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                            color: AppColors.subHeading,
                            fontWeight: hasUnreadMessages ? FontWeight.w600 : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeText.isNotEmpty)
                        Text(
                          timeText,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: hasUnreadMessages ? AppColors.primary : AppColors.caption,
                            fontWeight: hasUnreadMessages ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  1.0.height,

                  // Last Message and Unread Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (isLastMessageFromUser && !isOtherUserTyping) ...[
                              Icon(
                                Icons.check,
                                size: 14,
                                color: isOtherUserTyping
                                    ? AppColors.primary
                                    : (hasUnreadMessages
                                        ? AppColors.subHeading
                                        : AppColors.caption),
                              ),
                              4.0.width,
                            ],
                            Expanded(
                              child: Text(
                                lastMessageText,
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontSize: 13,
                                  color: isOtherUserTyping
                                      ? AppColors.primary
                                      : (hasUnreadMessages
                                          ? AppColors.subHeading
                                          : AppColors.caption),
                                  fontWeight: isOtherUserTyping
                                      ? FontWeight.w500
                                      : (hasUnreadMessages ? FontWeight.w500 : FontWeight.normal),
                                  fontStyle:
                                      isOtherUserTyping ? FontStyle.italic : FontStyle.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasUnreadMessages) ...[
                        8.0.width,
                        _buildUnreadBadge(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnreadBadge() {
    final count = conversation.unreadCount ?? 0;
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.highlightRed,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getLastMessageText() {
    if (conversation.lastMessage == null) {
      return 'Start a conversation';
    }

    if (conversation.lastMessage?.type == 'text') {
      return conversation.lastMessage?.message ?? 'New message';
    } else {
      final messageText = conversation.lastMessage?.message;
      if (messageText == null || messageText.isEmpty) {
        return '📎 Attachment';
      } else {
        return '📎 $messageText';
      }
    }
  }

  String _formatTime() {
    if (conversation.lastMessageAt == null) {
      return '';
    }

    try {
      DateTime lastMessageTime;

      if (conversation.lastMessageAt is String) {
        lastMessageTime = DateTime.parse(conversation.lastMessageAt);
      } else if (conversation.lastMessageAt is DateTime) {
        lastMessageTime = conversation.lastMessageAt;
      } else {
        return '';
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDay = DateTime(lastMessageTime.year, lastMessageTime.month, lastMessageTime.day);

      if (messageDay == today) {
        // Today - show time
        return DateFormat('hh:mm a').format(lastMessageTime.toLocal());
      } else if (messageDay == today.subtract(const Duration(days: 1))) {
        // Yesterday
        return 'Yesterday';
      } else if (now.difference(lastMessageTime).inDays < 7) {
        // This week - show day name
        return DateFormat('EEEE').format(lastMessageTime);
      } else {
        // Older - show date
        return DateFormat('dd/MM/yy').format(lastMessageTime);
      }
    } catch (e) {
      return '';
    }
  }
}
