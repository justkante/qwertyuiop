import 'dart:developer';

import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/share_profile_widget.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/creator_profile_tab.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/expandable_profile_image.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/most_recent_card.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/image_preview.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/manage_subscription_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/adjust_portfolio_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/edit_availability_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/payment_payout_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/update_rates_card_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/update_work_mode_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/upgrade_account_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/upgrade_account_successful_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/make_subscription_payment_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/metrics_card.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/uploaded_image_with_cancel.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/profile_menu_popup.dart';
import 'package:creatify_mobile/view/modules/webview/app_webview.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_dialog.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/modules/home/rating/rating_widgets.dart';
import 'package:creatify_mobile/view/utils/file_and_image_picker.dart';
import 'package:creatify_mobile/view/widgets/overlay_animation.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:creatify_mobile/core/services/tour_service.dart';
import 'package:creatify_mobile/view/utils/tour/guarded_showcase.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';

class MyCreatorProfileView extends ConsumerStatefulWidget {
  const MyCreatorProfileView({super.key});

  @override
  ConsumerState<MyCreatorProfileView> createState() => _CreatorUpgradeProfileViewState();
}

class _CreatorUpgradeProfileViewState extends ConsumerState<MyCreatorProfileView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final GlobalKey _menuButtonKey = GlobalKey();

  bool openingGallery = false;
  bool dashboardLoading = false;
  bool _tourStarted = false;
  late final ShowcaseView _showcaseView;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    _showcaseView = ShowcaseView.register(
      scope: 'my-creator-profile',
      onFinish: () => TourService.markScreenDone(TourService.myCreatorProfile),
    );
    _tourStarted = !TourService.shouldShowScreenTour(TourService.myCreatorProfile);
  }

  @override
  void dispose() {
    _showcaseView.unregister();
    super.dispose();
  }

  void _showProfileMenu() {
    final menuItems = ProfileMenuController.createDefaultMenuItems(
      onEditProfileImage: _onEditProfileImage,
      onUpgradeAccount: _onUpgradeAccount,
      onEditAvailability: _onEditAvailability,
      onManagePortfolio: _onManagePortfolio,
      onPaymentPayouts: _onPaymentPayouts,
      onUpdateRatesCard: _onUpdateRatesCard,
      onUpdateWorkMode: _onUpdateWorkMode,
      onShareProfile: _onShareProfile,
    );

    ProfileMenuController.showProfileMenu(
      context: context,
      buttonKey: _menuButtonKey,
      menuItems: menuItems,
    );
  }

  void _onEditProfileImage() async {
    setState(() => openingGallery = true);

    await pickImageFromGallery().then((value) {
      log('here');
      setState(() => openingGallery = false);

      if (value != null && value.path.isNotEmpty) {
        if (!mounted) return;

        NavigationService.instance.push(
          ImagePreviewScreen(
            imageFile: value,
            fileName: 'Profile Image',
          ),
        );
      }
    }).catchError((error) {
      setState(() => openingGallery = false);
    });
  }

  void _onUpgradeAccount() {
    NavigationService.instance.push(const ManageSubscriptionView());
  }

  void _onEditAvailability() {
    AppBottomSheet.showBottomSheet(
      context,
      widget: const EditAvailabilitySheet(),
    );
  }

  void _onManagePortfolio() {
    AppBottomSheet.showBottomSheet(
      context,
      widget: const AdjustPortfolioSheet(),
    );
  }

  void _onPaymentPayouts() {
    final userData = ref.watch(userControllerProvider);

    if (userData.countryCode == 'NG') {
      AppBottomSheet.showBottomSheet(
        context,
        widget: const PaymentAndPayoutSheet(),
      );
    } else {
      setState(() => dashboardLoading = true);
      ref.invalidate(getCreatorDashboardProvider);
      ref.read(getCreatorDashboardProvider.future).then((value) {
        if (!mounted) return;
        setState(() => dashboardLoading = false);

        NavigationService.instance.push(
          WebviewScreen(
            url: value.url ?? '',
            routeName: "Payments and Payouts",
          ),
        );
      }).catchError((error) {
        if (!mounted) return;
        ToastDialog.showError(error.toString(), context);
        setState(() => dashboardLoading = false);
      });
    }
  }

  void _onUpdateRatesCard() {
    NavigationService.instance.push(
      UpdateRatesCardSheet(
        exisitingNiches: ref
            .read(fetchCreatorProfileProvider(ref.read(userControllerProvider).id ?? ''))
            .maybeWhen(
              data: (data) => data.categories ?? [],
              orElse: () => [],
            ),
      ),
    );
  }

  void _onUpdateWorkMode() {
    AppBottomSheet.showBottomSheet(
      context,
      widget: const UpdateWorkModeSheet(),
    );
  }

  void _onShareProfile() {
    ref
        .watch(fetchCreatorProfileProvider(ref.watch(userControllerProvider).id ?? ''))
        .whenData((profile) {
      AppDialog.showAppDialog(
        context,
        widget: ShareProfileWidget(
          profile: profile,
          self: true,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final myCreatorProfile = ref.watch(fetchCreatorProfileProvider(userData.id ?? ''));

    ref.listen(verifySubscriptionPaymentProvider, (_, value) {
      if (value is AsyncData) {
        AppBottomSheet.showBottomSheet(
          context,
          widget: const UpgradeAccountSuccessfulSheet(),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    if (!_tourStarted) {
      _tourStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showcaseView.startShowCase([
          TourKeys.myCreatorMenu,
        ]);
      });
    }

    return OverlayLoadingIndicator(
      isLoading: openingGallery || dashboardLoading,
      text: openingGallery ? 'Opening Gallery...' : 'Loading Payout Dashboard...',
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            GuardedShowcase(
              showcaseKey: TourKeys.myCreatorMenu,
              description:
                  'Tap here to edit your profile, manage your subscription and also share your profile with friends.',
              targetBorderRadius: BorderRadius.circular(8),
              child: IconButton(
                key: _menuButtonKey,
                icon: const Icon(Icons.more_vert, color: AppColors.icons),
                onPressed: () {
                  _showProfileMenu();
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              myCreatorProfile.when(
                data: (data) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MARK: Profile Image, Badge and Upgrade
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 2),
                                ),
                                child: ExpandableProfileImage(
                                  imageUrl: data.profileImage,
                                  initials: data.initials,
                                  size: 80,
                                  initialsFallback: Center(
                                    child: InitialAvatar(
                                      initials: data.initials,
                                      padding: const EdgeInsets.all(20),
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _onEditProfileImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                  ),
                                  child: const Icon(Icons.camera_alt_outlined, size: 16, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: _buildUpgradeBadge(data),
                            ),
                          ),
                        ],
                      ),
                      12.0.height,

                      // Name and verification
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  userData.name ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                if (data.isPremium == true) ...[
                                  4.0.width,
                                  const Icon(Icons.check_circle, color: Color(0xFF2196F3), size: 18),
                                ],
                              ],
                            ),
                            Text(
                              'Creator Profile',
                              style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            8.0.height,
                            StarRating(
                              rating: data.ratingsAndReviews?.averageRating ?? 0.0,
                              starCount: 5,
                              starSize: 16,
                            ),
                            Text(
                              '${data.ratingsAndReviews?.averageRating ?? 0.0} (${data.ratingsAndReviews?.totalReviews ?? 0} reviews)',
                              style: const TextStyle(color: AppColors.body, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      16.0.height,

                      // Location and Niche
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSmallInfoChip(Icons.location_on_outlined, data.location ?? 'Unknown'),
                          12.0.width,
                          _buildSmallInfoChip(Icons.work_outline, data.workMode?.toTitleCase() ?? 'Freelance'),
                        ],
                      ),
                      16.0.height,

                      Center(
                        child: GestureDetector(
                          onTap: _onUpdateRatesCard,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.grey50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  data.categories?.isEmpty == true ? 'No Creator Niches Added' : data.categories!.map((e) => e.name).join(', '),
                                  style: const TextStyle(fontSize: 12, color: AppColors.body, fontWeight: FontWeight.w500),
                                ),
                                8.0.width,
                                const Icon(Icons.edit_outlined, size: 14, color: AppColors.body),
                              ],
                            ),
                          ),
                        ),
                      ),
                      24.0.height,

                      // MARK: Tabs
                      _buildProfileTabs(),
                      24.0.height,

                      // Dynamic Content
                      _buildTabContent(data, userData),

                    ],
                  );
                },
                error: (error, stacktrace) => Center(child: Text(error.toString())),
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeBadge(CreatorProfileDto data) {
    if (data.isPremium == true) {
      return SvgPicture.asset(AppImages.premiumBadge, height: 32);
    }
    return GestureDetector(
      onTap: _onUpgradeAccount,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1EF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Icon(Icons.workspace_premium_outlined, color: Color(0xFFFF6F61), size: 14),
             4.0.width,
             const Text('Upgrade', style: TextStyle(color: Color(0xFFFF6F61), fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.body),
        4.0.width,
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.body)),
      ],
    );
  }

  Widget _buildProfileTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        labelColor: Colors.black,
        unselectedLabelColor: AppColors.body,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Portfolio'),
          Tab(text: 'Rates Card'),
        ],
      ),
    );
  }

  Widget _buildTabContent(CreatorProfileDto data, dynamic userData) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        if (tabController.index == 0) return _buildOverviewTab(data);
        if (tabController.index == 1) return _buildPortfolioTab(data);
        return _buildRatesCardTab(data);
      },
    );
  }

  Widget _buildOverviewTab(CreatorProfileDto data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Creator Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                4.0.width,
                const Icon(Icons.info_outline, size: 14, color: AppColors.body),
              ],
            ),
            Row(
              children: [
                const Text('Last 30 days', style: TextStyle(fontSize: 11, color: AppColors.body)),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.body),
              ],
            ),
          ],
        ),
        16.0.height,
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildMetricItem('Jobs Completed', data.analytics?.totalBookings?.toString() ?? '0', Icons.check_circle_outline, const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
            _buildMetricItem('Acceptance Rate', '${data.analytics?.completionRate ?? 0}%', Icons.check_circle_outline, const Color(0xFFE3F2FD), const Color(0xFF2196F3)),
            _buildMetricItem('Cancellation Rate', '${data.analytics?.cancellationRate ?? 0}%', Icons.cancel_outlined, const Color(0xFFFFF1EF), const Color(0xFFFF6F61)),
            _buildMetricItem('Repeat Hire Rate', '${data.analytics?.repeatHireRate ?? 0}%', Icons.refresh_outlined, const Color(0xFFF3E5F5), const Color(0xFF7B1FA2)),
            _buildMetricItem('Average Response', '${data.analytics?.averageResponseTime ?? 0} hrs', Icons.access_time, const Color(0xFFE0F2F1), const Color(0xFF00897B)),
            _buildMetricItem('Member Since', data.analytics?.memberSince?.timeNoAgo() ?? '1 week', Icons.calendar_today_outlined, const Color(0xFFFFFDE7), const Color(0xFFF9A825)),
          ],
        ),
        32.0.height,
        const Text('Ratings & Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        16.0.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.ratingsAndReviews?.averageRating ?? 0.0}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B3131)),
                ),
                StarRating(rating: data.ratingsAndReviews?.averageRating ?? 0.0, starCount: 5, starSize: 12),
                Text('(${data.ratingsAndReviews?.totalReviews ?? 0} Reviews)', style: const TextStyle(color: AppColors.body, fontSize: 10)),
              ],
            ),
            32.0.width,
            Expanded(
              child: RatingMetrics(
                ratings: [
                  RatingData(stars: 5, count: data.ratingsAndReviews?.ratingBreakdown?.the5Star ?? 0),
                  RatingData(stars: 4, count: data.ratingsAndReviews?.ratingBreakdown?.the4Star ?? 0),
                  RatingData(stars: 3, count: data.ratingsAndReviews?.ratingBreakdown?.the3Star ?? 0),
                  RatingData(stars: 2, count: data.ratingsAndReviews?.ratingBreakdown?.the2Star ?? 0),
                  RatingData(stars: 1, count: data.ratingsAndReviews?.ratingBreakdown?.the1Star ?? 0),
                ],
              ),
            ),
          ],
        ),
        24.0.height,
        _buildNoReviewsState(),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 12),
              ),
            ],
          ),
          4.0.height,
          Text(label, style: const TextStyle(fontSize: 8, color: AppColors.body)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B3131))),
        ],
      ),
    );
  }

  Widget _buildNoReviewsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFE3F2FD), shape: BoxShape.circle),
            child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF2196F3), size: 24),
          ),
          12.0.height,
          const Text('No reviews yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Text('Complete a job to receive reviews.', style: TextStyle(color: AppColors.body, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab(CreatorProfileDto data) {
     return data.portfolio?.isEmpty ?? true
        ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Text('No Media Uploaded', style: context.textTheme.bodyMedium)))
        : GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: data.portfolio?.length,
            itemBuilder: (context, index) => UploadedImageWithDelete(portfolioItem: data.portfolio![index], expandMedia: true),
          );
  }

  Widget _buildRatesCardTab(CreatorProfileDto data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey300), color: AppColors.grey50),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.categories?.length ?? 0,
        separatorBuilder: (_, __) => 12.0.height,
        itemBuilder: (context, index) {
          var category = data.categories?[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B3131))),
              const Divider(color: Color(0xFF1B3131), thickness: 2),
              8.0.height,
              ...category?.services?.map((pricing) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(pricing.serviceName ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text("${pricing.price.amountWithCurrency(data.primaryCurrency ?? '')}/${pricing.pricingType?.split('_').last.toTitleCase()}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6F61), fontFamily: 'Inter')),
                ],
              )) ?? [],
            ],
          );
        },
      ),
    );
  }
}
