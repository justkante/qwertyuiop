import 'package:creatify_mobile/data/models/responses/conversation_dto.dart';
import 'package:creatify_mobile/view/modules/chats/vm/chat_providers.dart';
import 'package:creatify_mobile/view/modules/chats/chat_conversation_view.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/cache_image_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    final unreadCount = conversation.unreadCount ?? 0;
    final hasUnreadMessages = unreadCount > 0 &&
        (conversation.lastMessage?.senderId == conversation.otherUser?.id);

    final otherUserId = conversation.otherUser?.id;
    final isOnline = otherUserId != null
        ? ref.watch(userPresenceProvider(otherUserId))
        : conversation.otherUser?.isOnline ?? false;

    // Watch for typing indicator
    final typingUsers = ref.watch(typingUsersProvider(conversation.id ?? ''));
    final isOtherUserTyping = typingUsers.contains(conversation.otherUser?.id);

    final lastMessageText = isOtherUserTyping ? 'typing...' : _getLastMessageText();
    final timeText = _formatTime();

    return InkWell(
      onTap: () {
        context.push(ChatConversationView(conversation: conversation));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                conversation.otherUser?.avatar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: CachedImageHandler(
                          imageUrl: conversation.otherUser!.avatar!,
                          height: 56,
                          width: 56,
                        ),
                      )
                    : InitialAvatar(
                        margin: EdgeInsets.zero,
                        backgroundColor: AppColors.grey100,
                        initials: conversation.otherUser?.name?.substring(0, 1).toUpperCase() ?? 'U',
                        size: 28,
                      ),
                if (isOnline)
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
              ],
            ),
            16.0.width,

            // Message Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                conversation.otherUser?.name ?? 'Unknown User',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1B3131),
                                ),
                              ),
                            ),
                            if (conversation.otherUser?.isPremium == true) ...[
                              4.0.width,
                              SvgPicture.asset(
                                AppImages.blueTick,
                                width: 16,
                                height: 16,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        timeText,
                        style: TextStyle(
                          fontSize: 11,
                          color: hasUnreadMessages ? const Color(0xFF1B3131) : AppColors.body,
                          fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  4.0.height,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessageText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnreadMessages ? const Color(0xFF1B3131) : AppColors.body,
                            fontWeight: hasUnreadMessages ? FontWeight.w500 : FontWeight.normal,
                            fontStyle: isOtherUserTyping ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ),
                      if (hasUnreadMessages) ...[
                        12.0.width,
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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

  String _getLastMessageText() {
    if (conversation.lastMessage == null) return 'Start a conversation';
    final msg = conversation.lastMessage!;
    if (msg.type == 'text') return msg.message ?? '';
    return '📎 Attachment';
  }

  String _formatTime() {
    if (conversation.lastMessageAt == null) return '';
    try {
      final DateTime dt = conversation.lastMessageAt is String
          ? DateTime.parse(conversation.lastMessageAt)
          : conversation.lastMessageAt;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDay = DateTime(dt.year, dt.month, dt.day);

      if (msgDay == today) return DateFormat('HH:mm').format(dt.toLocal());
      if (msgDay == today.subtract(const Duration(days: 1))) return 'Yesterday';
      if (now.difference(dt).inDays < 7) return DateFormat('EEE').format(dt);
      return DateFormat('dd/MM/yy').format(dt);
    } catch (e) {
      return '';
    }
  }
}
