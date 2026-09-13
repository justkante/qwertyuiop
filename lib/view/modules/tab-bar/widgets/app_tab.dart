import 'dart:ui';
import 'package:creatify_mobile/view/modules/chats/vm/chat_providers.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/tour/guarded_showcase.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';
import 'package:creatify_mobile/view/utils/tour/tour_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppTabBar extends ConsumerStatefulWidget {
  const AppTabBar({super.key});

  @override
  ConsumerState<AppTabBar> createState() => _AppTabarState();
}

class _AppTabarState extends ConsumerState<AppTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 32.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 60.h,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TabItem(
                  title: 'Home',
                  image: AppImages.home,
                  activeImage: AppImages.homeBold,
                  index: 0,
                  showcaseKey: TourKeys.navHome,
                  showcaseDescription:
                      'Your dashboard — view your creator profile, find talents, and view your settings.',
                ),
                TabItem(
                  title: 'Search',
                  image: AppImages.search,
                  activeImage: AppImages.searchBold,
                  index: 1,
                  showcaseKey: TourKeys.navSearch,
                  showcaseDescription:
                      'Find and filter creators by categories, location, or budget.',
                ),
                TabItem(
                  title: 'Jobs',
                  image: AppImages.suitcaseLine,
                  activeImage: AppImages.suitcase,
                  index: 2,
                  showcaseKey: null,
                  showcaseDescription: 'Track your jobs as a creator.',
                ),
                TabItem(
                  title: 'Bookings',
                  image: AppImages.document,
                  activeImage: AppImages.documentBold,
                  index: 3,
                  showcaseKey: TourKeys.navBookings,
                  showcaseDescription:
                      'Track all your bookings — pending, active, and completed.',
                ),
                TabItem(
                  title: 'Messages',
                  image: AppImages.message,
                  activeImage: AppImages.messageBold,
                  index: 4,
                  showcaseKey: TourKeys.navMessages,
                  showcaseDescription: 'Chat with creators or recruiters about your bookings.',
                ),
                TabItem(
                  title: 'Wallet',
                  image: AppImages.wallet,
                  activeImage: AppImages.walletBold,
                  index: 5,
                  showcaseKey: TourKeys.navWallet,
                  showcaseDescription:
                      'View your balance, fund your wallet, or withdraw earnings.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabItem extends ConsumerStatefulWidget {
  final String title;
  final String image;
  final String activeImage;
  final int index;
  final GlobalKey? showcaseKey;
  final String? showcaseDescription;
  const TabItem({
    super.key,
    required this.title,
    required this.image,
    required this.activeImage,
    required this.index,
    this.showcaseKey,
    this.showcaseDescription,
  });

  @override
  ConsumerState<TabItem> createState() => _TabItemState();
}

class _TabItemState extends ConsumerState<TabItem> {
  @override
  Widget build(BuildContext context) {
    var isActive = widget.index == ref.watch(navBarController);

    // Check if this is the Messages tab and get unread count
    final hasUnread = widget.index == 4 // Updated index for Messages
        ? ref.watch(totalUnreadCountProvider).maybeWhen(
              data: (count) => count > 0,
              orElse: () => false,
            )
        : false;

    Widget button = InkWell(
      onTap: () {
        ref.read(navBarController.notifier).index = widget.index;
        ref.read(startTabTourProvider.notifier).state = widget.index;
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topRight,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              isActive ? widget.activeImage : widget.image,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                isActive ? Colors.white : Colors.white.withOpacity(0.5),
                BlendMode.srcIn,
              ),
            ),
          ),
          if (hasUnread)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.highlightRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.showcaseKey != null) {
      return GuardedShowcase(
        showcaseKey: widget.showcaseKey!,
        description: widget.showcaseDescription ?? '',
        targetBorderRadius: BorderRadius.circular(8),
        child: button,
      );
    }
    return button;
  }
}
