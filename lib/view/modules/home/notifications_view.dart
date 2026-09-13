import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/delete_notification_vm.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/mark_notifications_read_vm.dart';
import 'package:creatify_mobile/view/modules/home/notifications_list.dart';
import 'package:creatify_mobile/view/modules/home/widgets/notifications_tab.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/linear_loading.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:creatify_mobile/core/services/tour_service.dart';
import 'package:creatify_mobile/view/utils/tour/guarded_showcase.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _tourStarted = false;
  late final ShowcaseView _showcaseView;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _showcaseView = ShowcaseView.register(
      scope: 'notifications',
      onFinish: () => TourService.markScreenDone(TourService.notifications),
    );
    _tourStarted = !TourService.shouldShowScreenTour(TourService.notifications);
  }

  @override
  void dispose() {
    _showcaseView.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(fetchNotificationsProvider);
    final markingAsRead = ref.watch(markNotificationsAsReadProvider).isLoading;
    final deletingNotification = ref.watch(deleteNotificationProvider).isLoading;

    ref.listen(markNotificationsAsReadProvider, (_, value) {
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(deleteNotificationProvider, (_, value) {
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    if (!_tourStarted) {
      _tourStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showcaseView.startShowCase([
        ]);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.subHeading,
          ),
        ),
      ),
      body: Column(
        children: [
          16.0.height,
          Center(
            child: GuardedShowcase(
              showcaseKey: TourKeys.notificationsAlerts,
              description: 'Get alerts on bookings, approvals, revisions, deadlines, and payouts.',
              targetBorderRadius: BorderRadius.circular(8),
              child: NotificationsTabBar(tabController: _tabController),
            ),
          ),
          if (markingAsRead || deletingNotification) ...[
            12.0.height,
            const LineLoadingIndicator(loading: true),
          ],
          16.0.height,

          Padding(
            padding: const EdgeInsets.only(right: 32),
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  ref.read(markNotificationsAsReadProvider.notifier).markNotificationAsRead();
                },
                child: Text(
                  'Mark all as read',
                  style: context.textTheme.bodySmall,
                ),
              ),
            ),
          ),
          8.0.height,
          notifications.when(
            data: (data) {
              return Expanded(
                child: RefreshIndicator.adaptive(
                  onRefresh: () async {
                    ref.invalidate(fetchNotificationsProvider);
                  },
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, child) {
                      final currentIndex = _tabController.index;

                      switch (currentIndex) {
                        case 0:
                          return NotificationsList(notificationList: data.data ?? []);
                        case 1:
                          final unreadNotifications = data.data
                              ?.where((notification) => notification.isRead == false)
                              .toList();
                          return NotificationsList(notificationList: unreadNotifications ?? []);
                        case 2:
                          final readNotifications = data.data
                              ?.where((notification) => notification.isRead == true)
                              .toList();
                          return NotificationsList(notificationList: readNotifications ?? []);
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              );
            },
            error: (error, stackTrace) => Column(
              children: [
                Center(
                  child: Text(
                    'Error loading notifications. ${kDebugMode ? error.toString() : ''}',
                    style: context.textTheme.bodyMedium?.copyWith(),
                  ),
                ),
                6.0.height,
                Center(
                  child: InkWell(
                    onTap: () {
                      ref.invalidate(fetchNotificationsProvider);
                    },
                    child: Text(
                      'Refresh',
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.highlightRed, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            loading: () => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  24.0.height,
                  const CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  8.0.height,
                  const Text('Loading Notifications...'),
                ],
              ),
            ),
          )
          // Expanded(
          //   child: TabBarView(
          //     controller: _tabController,
          //     physics: const NeverScrollableScrollPhysics(),
          //     children: const [
          //       NotificationsList(),
          //       Center(child: Text('Unread Notifications')),
          //       Center(child: Text('Read Notifications')),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
