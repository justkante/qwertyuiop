import 'dart:developer';

import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/share_profile_widget.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/expandable_profile_image.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/image_preview.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/manage_subscription_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/adjust_portfolio_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/edit_availability_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/payment_payout_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/update_rates_card_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/update_work_mode_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/upgrade_account_successful_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/make_subscription_payment_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/uploaded_image_with_cancel.dart';
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
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:creatify_mobile/core/services/tour_service.dart';
import 'package:creatify_mobile/view/utils/tour/guarded_showcase.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';
import 'package:creatify_mobile/view/modules/home/edit_profile_view.dart';
import 'package:creatify_mobile/view/modules/bookings/creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/most_recent_card.dart';
import 'onboarding_sheet.dart';

class MyCreatorProfileView extends ConsumerStatefulWidget {
  const MyCreatorProfileView({super.key});

  @override
  ConsumerState<MyCreatorProfileView> createState() => _CreatorUpgradeProfileViewState();
}

class _CreatorUpgradeProfileViewState extends ConsumerState<MyCreatorProfileView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  bool openingGallery = false;
  bool dashboardLoading = false;
  bool _tourStarted = false;
  late final ShowcaseView _showcaseView;
  String selectedTimeframeValue = 'last_month';

  String get selectedTimeframeDisplay {
    switch (selectedTimeframeValue) {
      case 'day':
        return 'Current day';
      case 'last_day':
        return 'Last day';
      case 'last_week':
        return 'Last week';
      case 'last_month':
        return 'Last 30 days';
      default:
        return 'Last 30 days';
    }
  }

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

  void _onEditProfileImage() async {
    setState(() => openingGallery = true);

    await pickImageFromGallery().then((value) {
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
            .read(fetchCreatorProfileProvider((ref.read(userControllerProvider).id ?? '', null)))
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
        .watch(fetchCreatorProfileProvider((ref.watch(userControllerProvider).id ?? '', null)))
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
    final myCreatorProfile = ref.watch(fetchCreatorProfileProvider((userData.id ?? '', selectedTimeframeValue)));
    final onboardingStatus = ref.watch(getOnboardingStatusProvider);

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
            IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.icons),
              onPressed: _onShareProfile,
            ),
          ],
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: () async {
            ref.invalidate(fetchCreatorProfileProvider);
            ref.invalidate(getOnboardingStatusProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Centered alignment
              children: [
                myCreatorProfile.when(
                  data: (data) {
                    final isOnboarded = onboardingStatus.value?.isOnboarded ?? false;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // MARK: Centered Profile Picture with Upgrade Badge at Top Right
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 1.5),
                                ),
                                child: ExpandableProfileImage(
                                  imageUrl: data.profileImage,
                                  initials: data.initials,
                                  size: 56,
                                  initialsFallback: Center(
                                    child: InitialAvatar(
                                      initials: data.initials,
                                      padding: const EdgeInsets.all(12),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: GestureDetector(
                                  onTap: _onEditProfileImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                    ),
                                    child: const Icon(Icons.camera_alt_outlined, size: 10, color: AppColors.primary),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -5,
                                right: -60,
                                child: _buildUpgradeBadge(data),
                              ),
                            ],
                          ),
                        ),
                        24.0.height,

                        // Name and verification
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  userData.name ?? 'User',
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
                              style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            8.0.height,
                            if (isOnboarded) ...[
                              StarRating(
                                rating: data.ratingsAndReviews?.averageRating ?? 0.0,
                                starCount: 5,
                                starSize: 16,
                              ),
                              Text(
                                '${data.ratingsAndReviews?.averageRating ?? 0.0} (${data.ratingsAndReviews?.totalReviews ?? 0} reviews)',
                                style: const TextStyle(color: AppColors.body, fontSize: 11),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFFFFF1EF), borderRadius: BorderRadius.circular(20)),
                                child: const Text('Inactive Profile', style: TextStyle(color: Color(0xFFFF6F61), fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        24.0.height,

                        if (!isOnboarded) ...[
                           _buildOnboardingChecklist(),
                           40.0.height,
                        ] else ...[
                          // Location and Niche
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSmallInfoChip(Icons.location_on_outlined, data.location ?? 'Global'),
                              12.0.width,
                              _buildSmallInfoChip(Icons.work_outline, data.workMode?.toTitleCase() ?? 'Remote'),
                            ],
                          ),
                          16.0.height,

                          GestureDetector(
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
                                    data.categories?.isEmpty == true ? 'No Niches Added' : data.categories!.map((e) => e.name).join(', '),
                                    style: const TextStyle(fontSize: 12, color: AppColors.body, fontWeight: FontWeight.w500),
                                  ),
                                  8.0.width,
                                  const Icon(Icons.edit_outlined, size: 14, color: AppColors.body),
                                ],
                              ),
                            ),
                          ),
                          24.0.height,

                          Row(
                            children: [
                              Expanded(child: MainButton(text: 'Edit Profile', color: const Color(0xFFE0F2F1), textColor: AppColors.primary, onPressed: () {
                                 NavigationService.instance.push(const EditProfileView());
                              })),
                              12.0.width,
                              Expanded(child: MainButton(text: 'View Public', color: AppColors.grey50, textColor: const Color(0xFF1B3131), onPressed: () {
                                 NavigationService.instance.push(CreatorProfileView(profile: data));
                              })),
                            ],
                          ),
                          24.0.height,

                          // MARK: Tabs
                          _buildProfileTabs(),
                          24.0.height,

                          // Dynamic Content
                          _buildTabContent(data, userData),
                        ],
                        180.0.height, // Scrolling Padding
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
      ),
    );
  }

  Widget _buildOnboardingChecklist() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        children: [
          const Text('Complete Onboarding', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text('Finish these steps to make your profile live.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.body, fontSize: 12)),
          24.0.height,
          MainButton(
            text: 'Finish Setup Now',
            onPressed: () {
              AppBottomSheet.showBottomSheet(context, widget: const OnboardingSheet());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeBadge(CreatorProfileDto data) {
    return GestureDetector(
      onTap: _onUpgradeAccount,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: data.isPremium == true ? const Color(0xFFE0F2F1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (data.isPremium == true)
              SvgPicture.asset(AppImages.premiumBadge, height: 16)
            else
              const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 16),
            4.0.width,
            Text(
              data.isPremium == true ? 'Premium' : 'Upgrade',
              style: TextStyle(
                color: data.isPremium == true ? AppColors.primary : const Color(0xFF1B3131),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            const Text('Creator Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            PopupMenuButton<String>(
              onSelected: (val) {
                 setState(() {
                    selectedTimeframeValue = val;
                 });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Text(selectedTimeframeDisplay, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.body)),
                    4.0.width,
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.body),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'day', child: Text('Current day')),
                const PopupMenuItem(value: 'last_day', child: Text('Last day')),
                const PopupMenuItem(value: 'last_week', child: Text('Last week')),
                const PopupMenuItem(value: 'last_month', child: Text('Last 30 days')),
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
          childAspectRatio: 1.1,
          children: [
            _buildMetricItem('Jobs Done', data.analytics?.totalBookings?.toString() ?? '0', Icons.check_circle_outline, const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
            _buildMetricItem('Success Rate', '${data.analytics?.completionRate ?? 0}%', Icons.trending_up, const Color(0xFFE3F2FD), const Color(0xFF2196F3)),
            _buildMetricItem('Resp. Time', '${data.analytics?.averageResponseTime ?? 0}h', Icons.bolt, const Color(0xFFFFFDE7), const Color(0xFFF9A825)),
          ],
        ),
        32.0.height,
        const Text('Ratings & Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        16.0.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  '${data.ratingsAndReviews?.averageRating ?? 0.0}',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1B3131)),
                ),
                StarRating(rating: data.ratingsAndReviews?.averageRating ?? 0.0, starCount: 5, starSize: 14),
              ],
            ),
            40.0.width,
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
        const Text("Most Recent", style: TextStyle(fontSize: 12, color: AppColors.body, fontWeight: FontWeight.w500)),
        12.0.height,
        Column(
          children: data.ratingsAndReviews?.reviews?.isEmpty == true
              ? [const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('No Reviews Yet')))]
              : data.ratingsAndReviews!.reviews!.take(3).map((review) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: MostRecentCard(
                    reviewerName: review.reviewerName ?? 'User',
                    rating: review.rating ?? 0.0,
                    reviewDate: review.createdAt?.toLocal().toFormattedDateWithYear() ?? 'Unknown',
                    reviewText: review.review ?? '',
                  ),
                )).toList(),
        ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          6.0.height,
          Text(label, style: const TextStyle(fontSize: 8, color: AppColors.body, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B3131))),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab(CreatorProfileDto data) {
     return data.portfolio?.isEmpty ?? true
        ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text('No media uploaded yet.')))
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
    if (data.categories?.isEmpty ?? true) return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text('Rates card not set up.')));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.grey200), color: AppColors.grey50),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.categories!.length,
        separatorBuilder: (_, __) => 16.0.height,
        itemBuilder: (context, index) {
          var category = data.categories![index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B3131), fontSize: 14)),
              const Divider(color: AppColors.grey200),
              8.0.height,
              ...category.services?.map((pricing) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(pricing.serviceName ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    Text("${pricing.price.amountWithCurrency(data.primaryCurrency ?? 'NGN')}/${pricing.pricingType?.split('_').last.toTitleCase()}",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6F61), fontSize: 13)),
                  ],
                ),
              )) ?? [],
            ],
          );
        },
      ),
    );
  }
}
