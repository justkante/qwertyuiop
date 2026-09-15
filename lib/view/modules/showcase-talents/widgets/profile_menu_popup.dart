import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:flutter_svg/svg.dart';

enum ProfileMenuOption {
  editProfileImage,
  upgradeAccount,
  editAvailability,
  managePortfolio,
  paymentPayouts,
  updateWorkMode,
}

class ProfileMenuData {
  final ProfileMenuOption option;
  final String title;
  final String icon;
  final VoidCallback onTap;

  ProfileMenuData({
    required this.option,
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class ProfileMenuPopup extends StatelessWidget {
  final List<ProfileMenuData> menuItems;
  final double? width;
  final VoidCallback? onDismiss;

  const ProfileMenuPopup({
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
            color: Colors.black.withOpacity(0.1),
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
  final ProfileMenuData data;
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
                    colorFilter: AppColors.icons.colorFilterMode(),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      data.title,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.heading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileMenuController {
  static void showProfileMenu({
    required BuildContext context,
    required GlobalKey buttonKey,
    required List<ProfileMenuData> menuItems,
  }) {
    final RenderBox renderBox = buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;

    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => ProfileMenuOverlay(
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
  static List<ProfileMenuData> createDefaultMenuItems({
    VoidCallback? onEditProfileImage,
    VoidCallback? onUpgradeAccount,
    VoidCallback? onEditAvailability,
    VoidCallback? onManagePortfolio,
    VoidCallback? onPaymentPayouts,
    VoidCallback? onUpdateWorkMode,
    VoidCallback? onUpdateRatesCard,
    VoidCallback? onShareProfile,
  }) {
    return [
      ProfileMenuData(
        option: ProfileMenuOption.upgradeAccount,
        title: 'Edit Profile Image',
        icon: AppImages.profile,
        onTap: onEditProfileImage ?? () {},
      ),
      ProfileMenuData(
        option: ProfileMenuOption.upgradeAccount,
        title: 'Manage Subscriptions',
        icon: AppImages.starLine,
        onTap: onUpgradeAccount ?? () {},
      ),
      ProfileMenuData(
        option: ProfileMenuOption.paymentPayouts,
        title: 'Payment & Payouts',
        icon: AppImages.walletLine,
        onTap: onPaymentPayouts ?? () {},
      ),
      ProfileMenuData(
        option: ProfileMenuOption.paymentPayouts,
        title: 'My Rates Card',
        icon: AppImages.clipboard,
        onTap: onUpdateRatesCard ?? () {},
      ),
      ProfileMenuData(
        option: ProfileMenuOption.managePortfolio,
        title: 'Manage Portfolio',
        icon: AppImages.suitcaseLine,
        onTap: onManagePortfolio ?? () {},
      ),
      ProfileMenuData(
        option: ProfileMenuOption.editAvailability,
        title: 'Edit Availability',
        icon: AppImages.calendarLine,
        onTap: onEditAvailability ?? () {},
      ),
      ProfileMenuData(
        option: ProfileMenuOption.editAvailability,
        title: 'Share Profile',
        icon: AppImages.share,
        onTap: onShareProfile ?? () {},
      ),
      // ProfileMenuData(
      //   option: ProfileMenuOption.updateWorkMode,
      //   title: 'Update Work Mode',
      //   icon: AppImages.calendarLine,
      //   onTap: onUpdateWorkMode ?? () {},
      // ),
    ];
  }
}

class ProfileMenuOverlay extends StatelessWidget {
  final Offset buttonPosition;
  final Size buttonSize;
  final Size screenSize;
  final List<ProfileMenuData> menuItems;
  final VoidCallback onDismiss;

  const ProfileMenuOverlay({
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
    const menuWidth = 240.0;
    const menuPadding = 16.0;

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
              child: ProfileMenuPopup(
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
