import 'package:creatify_mobile/core/utils/constants.dart';
import 'package:creatify_mobile/view/modules/bookings/draft_bookings_view.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/home/ambassador_page_view.dart';
import 'package:creatify_mobile/view/modules/home/change_password_view.dart';
import 'package:creatify_mobile/view/modules/home/change_transx_pin_view.dart';
import 'package:creatify_mobile/view/modules/home/delete_account_sheet.dart';
import 'package:creatify_mobile/view/modules/home/edit_profile_view.dart';
import 'package:creatify_mobile/view/modules/home/enable_biometrics_sheet.dart';
import 'package:creatify_mobile/view/modules/home/favorites_view.dart';
import 'package:creatify_mobile/view/modules/home/logout_sheet.dart';
import 'package:creatify_mobile/view/modules/home/notifications_view.dart';
import 'package:creatify_mobile/view/modules/home/search_preferences_view.dart';
import 'package:creatify_mobile/view/modules/home/support_view.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/my_recruiter_profile_view.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:creatify_mobile/view/modules/webview/app_webview.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeDrawer extends ConsumerStatefulWidget {
  const HomeDrawer({super.key});

  @override
  ConsumerState<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends ConsumerState<HomeDrawer> {
  String _appVersion = 'Unknown';

  void versionCode() async {
    final info = await PackageInfo.fromPlatform();
    _appVersion = info.version;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    versionCode();
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final hasWalletPin = ref.watch(fetchWalletDetailsProvider).hasValue == true &&
        ref.watch(fetchWalletDetailsProvider).value?.hasPin == true;
    final hasUnreadNotifications = !ref.watch(fetchNotificationsProvider).hasError &&
        ref.watch(fetchNotificationsProvider).hasValue &&
        ((ref.watch(fetchNotificationsProvider).value?.unreadCount ?? 0) > 0);

    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.sizeOf(context).width * 0.7,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Profile Section
            InkWell(
              onTap: () {
                context.pop();
                context.push(const EditProfileView());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    InitialAvatar(initials: userData.getInitials),
                    8.0.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello ${userData.name?.split(' ').first},',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.subHeading,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Edit Profile',
                          style: context.textTheme.bodySmall,
                        )
                      ],
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      AppImages.chevronRight,
                      width: 16,
                      height: 16,
                      colorFilter: AppColors.icons.colorFilterMode(),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              height: 1,
              color: AppColors.surface,
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),

            // Menu Items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DrawerHeading(title: 'PROFILE'),
                    // Only show Ambassador Referrals to users with the 'ambassador' role
                    if (userData.roles != null && userData.roles!.contains('ambassador')) ...[
                      DrawerMenuItem(
                        icon: AppImages.wallet,
                        title: 'Ambassador Referrals',
                        onTap: () {
                          context.push(const AmbassadorReferralView());
                        },
                      ),
                    ],
                    if (userData.roles?.contains('recruiter') == true)
                      DrawerMenuItem(
                        icon: AppImages.profileOutline,
                        title: 'Recruiter Profile',
                        onTap: () {
                          context.push(const MyRecruiterProfileView());
                        },
                      ),
                    if (userData.roles?.contains('creator') == true ||
                        (userData.roles?.contains('recruiter') != true))
                      DrawerMenuItem(
                        icon: AppImages.profileOutline,
                        title: 'Creator Profile',
                        onTap: () {
                          context.push(const MyCreatorProfileView());
                        },
                      ),
                    DrawerMenuItem(
                      icon: AppImages.editOutline,
                      title: 'Draft Bookings',
                      onTap: () {
                        context.push(const DraftBookingsView());
                      },
                    ),
                    DrawerMenuItem(
                      icon: AppImages.document,
                      title: 'Search Preferences',
                      onTap: () {
                        context.push(const SearchPreferencesView());
                      },
                    ),
                    DrawerMenuItem(
                      icon: AppImages.favorite,
                      title: 'Favourites',
                      onTap: () {
                        context.push(const FavoritesView());
                      },
                    ),
                    DrawerMenuItem(
                      icon: AppImages.bell,
                      title: 'Notifications',
                      showRedDot: hasUnreadNotifications,
                      onTap: () {
                        context.push(const NotificationsView());
                      },
                    ),
                    if (hasWalletPin || userData.authStrategy == 'email') ...[
                      const DrawerHeading(title: 'SECURITY'),
                    ],
                    if (hasWalletPin) ...[
                      DrawerMenuItem(
                        icon: AppImages.pinLock,
                        title: 'Change Transaction PIN',
                        onTap: () {
                          context.push(const ChangeTransactionPinView());
                        },
                      ),
                    ],
                    if (userData.authStrategy == 'email') ...[
                      DrawerMenuItem(
                        icon: AppImages.obscureField,
                        title: 'Change Password',
                        onTap: () {
                          context.push(const ChangePasswordView());
                        },
                      ),
                      DrawerMenuItem(
                        icon: AppImages.passwordLock,
                        title: 'Biometrics',
                        onTap: () {
                          AppBottomSheet.showBottomSheet(
                            context,
                            widget: const EnableBiometricsSheet(),
                          );
                        },
                      ),
                    ],
                    const DrawerHeading(title: 'SUPPORT'),
                    DrawerMenuItem(
                      icon: AppImages.personSupport,
                      title: 'Contact Support',
                      onTap: () {
                        context.push(const SupportView());
                      },
                    ),
                    const DrawerHeading(title: 'LEGAL'),
                    DrawerMenuItem(
                      icon: AppImages.privacy,
                      title: 'Privacy Policy',
                      onTap: () {
                        context.push(
                          const WebviewScreen(
                            url: Constants.privacyPolicyUrl,
                            routeName: 'Privacy Policy',
                          ),
                        );
                      },
                    ),
                    DrawerMenuItem(
                      icon: AppImages.document,
                      title: 'Terms and conditions',
                      onTap: () {
                        context.push(
                          const WebviewScreen(
                            url: Constants.termsAndConditionsUrl,
                            routeName: 'Terms and Conditions',
                          ),
                        );
                      },
                    ),
                    8.0.height,
                    const DrawerHeading(title: 'ACCOUNT'),
                    DrawerMenuItem(
                      icon: AppImages.logout,
                      title: 'Log out',
                      color: Colors.red,
                      onTap: () {
                        AppBottomSheet.showBottomSheet(
                          context,
                          widget: const LogoutSheet(),
                        );
                      },
                    ),
                    10.0.height,
                    DrawerMenuItem(
                      icon: AppImages.trash,
                      title: 'Delete Account',
                      subtitle: 'Permanently remove all your data from Creatify',
                      color: Colors.red.withValues(alpha: 0.6),
                      onTap: () {
                        AppBottomSheet.showBottomSheet(
                          context,
                          widget: const DeleteAccountSheet(),
                        );
                      },
                    ),
                    24.0.height,
                    Center(child: Text("v $_appVersion")),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerMenuItem extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final bool showRedDot;
  final VoidCallback onTap;
  final Color? color;

  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.color,
    this.showRedDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pop();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  icon,
                  width: 20,
                  height: 20,
                  colorFilter: color?.colorFilterMode() ?? AppColors.icons.colorFilterMode(),
                ),
                if (showRedDot) ...[
                  Positioned(
                    child: SvgPicture.asset(
                      width: 8,
                      height: 8,
                      AppImages.indicator,
                      colorFilter: AppColors.highlightRed.colorFilterMode(),
                    ),
                  )
                ],
              ],
            ),
            16.0.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: color ?? Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    8.0.width,
                    Text(
                      subtitle!,
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DrawerHeading extends StatelessWidget {
  final String title;
  final Color? color;

  const DrawerHeading({
    super.key,
    required this.title,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Text(
        title,
        style: context.textTheme.bodyMedium?.copyWith(
          color: color ?? Colors.grey.shade400,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
