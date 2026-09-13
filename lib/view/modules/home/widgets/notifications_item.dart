import 'package:creatify_mobile/data/models/responses/notifications_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/delete_notification_vm.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/mark_notifications_read_vm.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/quick_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NotificationItem extends ConsumerWidget {
  final NotificationsItemDto notification;
  const NotificationItem({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: (notification.isRead == false) ? 0.5 : 0.3,
        children: [
          if ((notification.isRead == false)) ...[
            SlidableAction(
              onPressed: (context) {
                ref.read(markNotificationsAsReadProvider.notifier).markNotificationAsRead(
                      notificationId: notification.id ?? '',
                    );
              },
              backgroundColor: AppColors.highlightBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              icon: Icons.notifications,
              label: 'Mark as Read',
            ),
          ],
          SlidableAction(
            onPressed: (context) {
              ref.read(deleteNotificationProvider.notifier).deleteNotification(
                    notificationId: notification.id ?? '',
                  );
            },
            backgroundColor: AppColors.highlightRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppImages.indicator,
              colorFilter: notification.isRead == false
                  ? AppColors.highlightRed.colorFilterMode()
                  : Colors.transparent.colorFilterMode(),
              width: 8,
              height: 8,
            ),
            4.0.width,
            const QuickIcon(
              icon: AppImages.suitcase,
              padding: 10,
              size: 21,
              color: AppColors.highlightBlue,
              bgColor: AppColors.highlightBlue50,
            ),
          ],
        ),
        title: Text(
          notification.title ?? '',
          style: context.textTheme.bodyLarge?.copyWith(
            fontSize: 15,
            color: AppColors.subHeading,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          notification.description ?? '',
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: 10,
          ),
        ),
        trailing: Text(
          notification.createdAt?.timeAgo() ?? '',
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
