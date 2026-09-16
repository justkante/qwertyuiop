import 'package:creatify_mobile/data/models/responses/conversation_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/fetched_creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/bookings/fetched_recruiter_profile_view.dart';
import 'package:creatify_mobile/view/modules/chats/vm/chat_providers.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/cache_image_handler.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatAppBarTitle extends ConsumerWidget {
  final ConversationDto conversation;

  const ChatAppBarTitle({
    super.key,
    required this.conversation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real-time presence updates for the other user
    final otherUserId = conversation.otherUser?.id;
    final isOnline = otherUserId != null
        ? ref.watch(userPresenceProvider(otherUserId))
        : conversation.otherUser?.isOnline ?? false;

    // Watch last seen time for the other user
    final lastSeenAt = otherUserId != null
        ? ref.watch(userLastSeenProvider(otherUserId)) ??
            conversation.otherUser?.lastSeenAt?.toString()
        : conversation.otherUser?.lastSeenAt?.toString();

    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            conversation.otherUser?.avatar != null
                ? CachedImageHandler(
                    imageUrl: conversation.otherUser!.avatar,
                    height: 36,
                    width: 36,
                  )
                : InitialAvatar(
                    margin: EdgeInsets.zero,
                    backgroundColor: AppColors.spot200,
                    initials: conversation.otherUser?.name?.substring(0, 1).toUpperCase() ?? 'U',
                    size: 18,
                  ),
            if (isOnline)
              Positioned(
                right: 1,
                bottom: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.highlightGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        12.0.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  if (conversation.isCreator == true) {
                    NavigationService.instance.push(
                      FetchedCreatorProfileView(
                        creatorId: conversation.otherUser!.id ?? '',
                        creatorName: conversation.otherUser?.name ?? 'Unknown User',
                      ),
                    );
                  } else {
                    NavigationService.instance.push(
                      FetchedRecruiterProfileView(
                        creatorId: conversation.otherUser!.id ?? '',
                        creatorName: conversation.otherUser?.name ?? 'Unknown User',
                      ),
                    );
                  }
                },
                child: Text(
                  conversation.otherUser?.name ?? 'Unknown User',
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    color: AppColors.subHeading,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                isOnline ? 'Online' : formatLastSeen(lastSeenAt),
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: isOnline ? AppColors.highlightGreen : AppColors.caption,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
