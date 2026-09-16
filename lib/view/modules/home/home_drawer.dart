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
import 'package:creatify_mobile/view/modules/showcase-talents/my_creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart' as creator_providers;
import 'package:creatify_mobile/view/modules/showcase-talents/vm/start_onboarding_vm.dart' as onboarding_providers;
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart' as tab_providers;
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
    // Refresh user data when drawer is initialized to ensure roles/status are up to date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userControllerProvider.notifier).refreshUser();
    });
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
      width: MediaQuery.sizeOf(context).width * 0.8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branding Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Creatify',
                    style: context.textTheme.displayMedium?.copyWith(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Create. Connect. Collaborate.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.body,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: InkWell(
                onTap: () {
                  context.pop();
                  NavigationService.instance.push(const EditProfileView());
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      InitialAvatar(
                        initials: userData.getInitials,
                        size: 20,
                        padding: const EdgeInsets.all(12),
                      ),
                      12.0.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello ${userData.name?.split(' ').first},',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.black2,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Edit Profile',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.body,
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.body, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Menu Items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DrawerHeading(title: 'WORKSPACE'),
                    if (userData.roles?.contains('recruiter') == true)
                      DrawerMenuItem(
                        icon: AppImages.profileOutline,
                        title: 'Recruiter Profile',
                        onTap: () {
                          NavigationService.instance.push(const MyRecruiterProfileView());
                        },
                      ),
                    DrawerMenuItem(
                      icon: AppImages.profileOutline,
                      title: (userData.roles?.contains('creator') == true)
                          ? 'Creator Profile'
                          : 'Become a Creator',
                      onTap: () {
                        if (userData.roles?.contains('creator') == true) {
                          NavigationService.instance.push(const MyCreatorProfileView());
                        } else {
                          // Trigger onboarding/upgrade flow
                          ref.read(tab_providers.navBarController.notifier).index = 0; // Go home
                          ref.invalidate(creator_providers.getOnboardingStatusProvider);
                          ref.read(creator_providers.getOnboardingStatusProvider.future).then((status) {
                            if (status.isOnboarded != true) {
                              ref.read(onboarding_providers.startOnboardingProvider.notifier).startOnboarding();
                            } else {
                              NavigationService.instance.push(const MyCreatorProfileView());
                            }
                          });
                        }
                      },
                    ),
                    DrawerMenuItem(
                      icon: AppImages.editOutline,
                      title: 'Draft Bookings',
                      onTap: () {
                        NavigationService.instance.push(const DraftBookingsView());
                      },
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Divider(color: AppColors.grey100, height: 1),
                    ),

                    const DrawerHeading(title: 'DISCOVERY'),
                    DrawerMenuItem(
                      icon: AppImages.document,
                      title: 'Search Preferences',
                      onTap: () {
                        NavigationService.instance.push(const SearchPreferencesView());
                      },
                    ),
                    DrawerMenuItem(
                      icon: AppImages.favorite,
                      title: 'Favourites',
                      onTap: () {
                        NavigationService.instance.push(const FavoritesView());
                      },
                    ),
                    DrawerMenuItem(
                      icon: AppImages.bell,
                      title: 'Notifications',
                      showRedDot: hasUnreadNotifications,
                      onTap: () {
                        NavigationService.instance.push(const NotificationsView());
                      },
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Divider(color: AppColors.grey100, height: 1),
                    ),

                    const DrawerHeading(title: 'SETTINGS'),
                    if (userData.authStrategy == 'email')
                      DrawerMenuItem(
                        icon: AppImages.padlock,
                        title: 'Change Password',
                        onTap: () {
                          NavigationService.instance.push(const ChangePasswordView());
                        },
                      ),
                    DrawerMenuItem(
                      icon: AppImages.touchId,
                      title: 'Biometrics',
                      onTap: () {
                        AppBottomSheet.showBottomSheet(
                          context,
                          widget: const EnableBiometricsSheet(),
                        );
                      },
                    ),
                    DrawerMenuItem(
                      icon: AppImages.premium,
                      title: 'Manage Subscription',
                      iconColor: AppColors.primary,
                      onTap: () {
                        NavigationService.instance.push(ManageSubscriptionView());
                      },
                    ),

                    const DrawerHeading(title: 'SUPPORT'),
                    DrawerMenuItem(
                      icon: AppImages.personSupport,
                      title: 'Contact Support',
                      onTap: () {
                        NavigationService.instance.push(const SupportView());
                      },
                    ),
                    DrawerMenuItem(
                      icon: AppImages.info,
                      title: 'Help Centre',
                      onTap: () {
                        // NavigationService.instance.push(const HelpCentreView());
                      },
                    ),

                    const DrawerHeading(title: 'LEGAL'),
                    DrawerMenuItem(
                      icon: AppImages.secure,
                      title: 'Privacy Policy',
                      onTap: () {
                        NavigationService.instance.push(
                          const WebviewScreen(
                            url: Constants.privacyPolicyUrl,
                            routeName: 'Privacy Policy',
                          ),
                        );
                      },
                    ),
                    DrawerMenuItem(
                      icon: AppImages.document,
                      title: 'Terms & Conditions',
                      onTap: () {
                        NavigationService.instance.push(
                          const WebviewScreen(
                            url: Constants.termsAndConditionsUrl,
                            routeName: 'Terms & Conditions',
                          ),
                        );
                      },
                    ),

                    16.0.height,
                    // Account Section with red background
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1EF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DrawerHeading(title: 'ACCOUNT', color: AppColors.highlightCoral),
                            DrawerMenuItem(
                              icon: AppImages.logout,
                              title: 'Log out',
                              subtitle: 'Sign out from your account',
                              color: AppColors.highlightRed,
                              onTap: () {
                                AppBottomSheet.showBottomSheet(
                                  context,
                                  widget: const LogoutSheet(),
                                );
                              },
                            ),
                            DrawerMenuItem(
                              icon: AppImages.trash,
                              title: 'Delete Account',
                              subtitle: 'Permanently remove all your data from Creatify',
                              color: AppColors.highlightRed,
                              onTap: () {
                                AppBottomSheet.showBottomSheet(
                                  context,
                                  widget: const DeleteAccountSheet(),
                                );
                              },
                            ),
                            8.0.height,
                          ],
                        ),
                      ),
                    ),

                    24.0.height,
                    Center(
                      child: Text(
                        "v $_appVersion",
                        style: context.textTheme.bodySmall?.copyWith(color: AppColors.body),
                      ),
                    ),
                    24.0.height,
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
  final Color? iconColor;

  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.color,
    this.iconColor,
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.topRight,
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  icon,
                  width: 22,
                  height: 22,
                  colorFilter: (iconColor ?? color ?? AppColors.icons).colorFilterMode(),
                ),
                if (showRedDot) ...[
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.highlightRed,
                        shape: BoxShape.circle,
                      ),
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
                      color: color ?? AppColors.black2,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.body,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.body, size: 18),
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
