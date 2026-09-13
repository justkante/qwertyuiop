import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:flutter_svg/svg.dart';

enum ChatMenuOption {
  viewProfile,
  viewBooking,
  markAsCompleted,
  updateDeliverableStatus,
  requestExtension,
  viewExtensionRequest,
  reportAccount,
  reportDispute,
}

class ChatMenuData {
  final ChatMenuOption option;
  final String title;
  final String icon;
  final bool showIndicator;
  final VoidCallback onTap;

  ChatMenuData({
    required this.option,
    required this.title,
    required this.icon,
    required this.onTap,
    this.showIndicator = false,
  });
}

class ChatMenuPopup extends StatelessWidget {
  final List<ChatMenuData> menuItems;
  final double? width;
  final VoidCallback? onDismiss;

  const ChatMenuPopup({
    super.key,
    required this.menuItems,
    this.width,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 240.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...menuItems.asMap().entries.map((entry) {
            final item = entry.value;
            return ProfileMenuItem(
              data: item,
              onDismiss: onDismiss,
            );
          }),
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final ChatMenuData data;
  final VoidCallback? onDismiss;

  const ProfileMenuItem({
    super.key,
    required this.data,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // First dismiss the menu
              if (onDismiss != null) {
                onDismiss!();
              }
              // Then execute the original callback
              data.onTap();
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    data.icon,
                    width: 20.w,
                    height: 20.h,
                    colorFilter: AppColors.black2.colorFilterMode(),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 7,
                    child: Text(
                      data.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.heading,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Visibility(
                    visible: data.showIndicator,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.highlightRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ChatMenuController {
  static void showProfileMenu({
    required BuildContext context,
    required GlobalKey buttonKey,
    required List<ChatMenuData> menuItems,
  }) {
    final RenderBox renderBox = buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;

    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => ChatMenuOverlay(
        buttonPosition: buttonPosition,
        buttonSize: buttonSize,
        screenSize: mediaQuery.size,
        menuItems: menuItems,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  /// Creates default menu items for creator profile
  static List<ChatMenuData> createDefaultMenuItems({
    bool isCreator = false,
    bool showExtensionIndicator = false,
    VoidCallback? viewProfile,
    VoidCallback? viewBooking,
    VoidCallback? markBookingCompleted,
    VoidCallback? updateDeliverableStatus,
    VoidCallback? requestExtension,
    VoidCallback? viewExtensionRequest,
    VoidCallback? reportAccount,
    VoidCallback? reportDispute,
  }) {
    return [
      if (!isCreator) ...[
        ChatMenuData(
          option: ChatMenuOption.viewProfile,
          title: 'View Creator Profile',
          icon: AppImages.profileLight,
          onTap: viewProfile ?? () {},
        ),
      ],
      ChatMenuData(
        option: ChatMenuOption.viewBooking,
        title: 'View Booking',
        icon: AppImages.dateLight,
        onTap: viewBooking ?? () {},
      ),
      ChatMenuData(
        option: ChatMenuOption.markAsCompleted,
        title: isCreator ? 'Update Deliverable Status' : 'Mark Booking as Completed',
        icon: AppImages.dateLight,
        onTap: isCreator ? (updateDeliverableStatus ?? () {}) : (markBookingCompleted ?? () {}),
      ),
      ChatMenuData(
        showIndicator: !isCreator ? showExtensionIndicator : false,
        option: isCreator ? ChatMenuOption.requestExtension : ChatMenuOption.viewExtensionRequest,
        title: isCreator ? 'Request Extension' : 'View Extension Request',
        icon: isCreator ? AppImages.add : AppImages.eye,
        onTap: isCreator ? (requestExtension ?? () {}) : (viewExtensionRequest ?? () {}),
      ),
      ChatMenuData(
        option: ChatMenuOption.reportDispute,
        title: 'Report Dispute',
        icon: AppImages.report,
        onTap: reportDispute ?? () {},
      ),
      ChatMenuData(
        option: ChatMenuOption.reportAccount,
        title: 'Report Account',
        icon: AppImages.report,
        onTap: reportAccount ?? () {},
      ),
    ];
  }
}

class ChatMenuOverlay extends StatelessWidget {
  final Offset buttonPosition;
  final Size buttonSize;
  final Size screenSize;
  final List<ChatMenuData> menuItems;
  final VoidCallback onDismiss;

  const ChatMenuOverlay({
    super.key,
    required this.buttonPosition,
    required this.buttonSize,
    required this.screenSize,
    required this.menuItems,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate position for the popup
    final menuWidth = 300.w;
    const menuPadding = 12.0;

    // Position the menu to the left of the button
    double left = buttonPosition.dx - menuWidth + buttonSize.width;
    double top = buttonPosition.dy + buttonSize.height + 8;

    // Ensure the menu doesn't go off screen
    if (left < menuPadding) {
      left = menuPadding;
    }
    if (left + menuWidth > screenSize.width - menuPadding) {
      left = screenSize.width - menuWidth - menuPadding;
    }

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: ChatMenuPopup(
                menuItems: menuItems,
                width: menuWidth,
                onDismiss: onDismiss,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
