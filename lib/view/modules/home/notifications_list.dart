import 'package:creatify_mobile/data/models/responses/notifications_dto.dart';
import 'package:creatify_mobile/view/modules/home/widgets/notifications_item.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NotificationsList extends StatefulWidget {
  final List<NotificationsItemDto> notificationList;
  const NotificationsList({super.key, required this.notificationList});

  @override
  State<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: widget.notificationList.isEmpty
          ? Column(
              children: [
                80.0.height,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.highlightCoral50,
                  ),
                  child: SvgPicture.asset(AppImages.bellIllustration),
                ),
                12.0.height,
                const Center(
                  child: Text('No Notifications'),
                ),
              ],
            )
          : Column(
              children: List.generate(
                widget.notificationList.length,
                (index) => NotificationItem(
                  notification: widget.notificationList[index],
                ),
              ),
            ),
    );
  }
}
