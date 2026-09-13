import 'dart:developer';

import 'package:creatify_mobile/view/modules/bookings/share_profile_widget.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/creator_profile_tab.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/expandable_profile_image.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/most_recent_card.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/profile_quick_detail.dart';
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
    tabController = TabController(length: 2, vsync: this);
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

        context.push(
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
    // AppBottomSheet.showBottomSheet(
    //   context,
    //   widget: const UpgradeAccountSheet(),
    // );
    context.push(const ManageSubscriptionView());
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

        context.push(
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
    context.push(
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
        appBar: AppBar(
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
                      // MARK: Profile Image and Name
                      LayoutBuilder(builder: (context, contraints) {
                        final widthx = contraints.maxWidth;

                        return Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            ExpandableProfileImage(
                              imageUrl: data.profileImage,
                              initials: data.initials,
                              size: 80,
                              imageDecoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              initialsFallback: Center(
                                child: InitialAvatar(
                                  initials: data.initials,
                                  padding: const EdgeInsets.all(20),
                                  size: 28,
                                ),
                              ),
                              customImageBuilder: (context, onTap) => Center(
                                child: GestureDetector(
                                  onTap: onTap,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: Image.network(
                                        data.profileImage!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) =>
                                            loadingProgress == null
                                                ? child
                                                : Container(
                                                    width: 72,
                                                    height: 72,
                                                    color: Colors.grey.shade300,
                                                    child: const Center(
                                                      child: CircularProgressIndicator.adaptive(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation(
                                                            AppColors.primary),
                                                      ),
                                                    ),
                                                  ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Edit Icon
                            Positioned(
                              bottom: widthx * 0.00005,
                              right: widthx * 0.4,
                              child: InkWell(
                                onTap: _onEditProfileImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6.0),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.btnInactive,
                                  ),
                                  child: SvgPicture.asset(
                                    AppImages.edit,
                                    width: 12,
                                    height: 12,
                                    colorFilter: AppColors.primary.colorFilterMode(),
                                  ),
                                ),
                              ),
                            ),

                            // Premium / Upgrade Badge
                            Positioned(
                              top: data.isPremium == true ? -3.h : 0,
                              right: data.isPremium == true ? 110.w : 65.w,
                              child: InkWell(
                                onTap: data.isPremium == true
                                    ? null
                                    : () {
                                        AppBottomSheet.showBottomSheet(
                                          context,
                                          widget: const UpgradeAccountSheet(),
                                        );
                                      },
                                child: data.isPremium == true
                                    ? SvgPicture.asset(
                                        AppImages.premiumBadge,
                                        width: 36,
                                        height: 36,
                                      )
                                    : Container(
                                        margin: const EdgeInsets.only(left: 3),
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          color: AppColors.highlightCoral,
                                        ),
                                        child: Text(
                                          "Upgrade",
                                          style: context.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        );
                      }),
                      8.0.height,
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userData.name ?? 'John Doe',
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (data.isPremium == true) ...[
                              4.0.width,
                              SvgPicture.asset(
                                AppImages.blueTick,
                                width: 16,
                                height: 16,
                              ),
                            ],
                          ],
                        ),
                      ),
                      4.0.height,

                      Center(
                        child: Text(
                          'Creator Profile',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.highlightBlue,
                          ),
                        ),
                      ),
                      8.0.height,

                      // Rating
                      Center(
                        child: StarRating(
                          rating: data.ratingsAndReviews?.averageRating ?? 0.0,
                          starCount: 5,
                          starSize: 16,
                        ),
                      ),
                      12.0.height,

                      // Location, Work Mode and Availability
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QuickDetail(
                            icon: AppImages.locationOutline,
                            text: data.location ?? 'Unknown',
                          ),
                          14.0.width,
                          QuickDetail(
                            icon: AppImages.workOutline,
                            text: data.workMode?.toTitleCase() ?? 'Unknown',
                          ),
                          if (data.availableToTravel ?? false) ...[
                            14.0.width,
                            const QuickDetail(
                              icon: AppImages.busOutline,
                              text: 'Available to Travel',
                            ),
                          ],
                        ],
                      ),
                      24.0.height,

                      // MARK: Skills Section
                      data.categories?.isEmpty == true
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: AppColors.grey150,
                                ),
                                child: Text(
                                  'No Creator Niches Added',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Wrap(
                                spacing: 4,
                                alignment: WrapAlignment.center,
                                runSpacing: 6,
                                runAlignment: WrapAlignment.start,
                                children: data.categories
                                        ?.map((category) => category.name ?? '')
                                        .map(
                                          (skill) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              color: AppColors.grey150,
                                            ),
                                            child: Text(
                                              skill,
                                              style: context.textTheme.bodySmall?.copyWith(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList() ??
                                    [],
                              ),
                            ),
                      24.0.height,

                      // MARK: Metrics
                      Text(
                        "Creator Metrics",
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.subHeading,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      8.0.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Expanded(
                            flex: 3,
                            child: MetricsCard(
                              label: 'Jobs Completed',
                              tooltipMessage:
                                  'Total number of bookings successfully completed on Creatify',
                              value: data.analytics?.totalBookings?.toString() ?? '0',
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: MetricsCard(
                              label: 'Cancellation Rate',
                              tooltipMessage:
                                  'Percentage of bookings cancelled after being confirmed',
                              value: "${data.analytics?.cancellationRate?.toString() ?? '0'}%",
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: MetricsCard(
                              label: 'Acceptance Rate',
                              tooltipMessage:
                                  'How often creator accepts booking requests sent to them',
                              value: "${data.analytics?.completionRate?.toString() ?? '0'}%",
                            ),
                          ),
                        ],
                      ),
                      8.0.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Expanded(
                            flex: 3,
                            child: MetricsCard(
                              label: 'Repeat Hire Rate',
                              tooltipMessage:
                                  'Percentage of clients who have booked creator more than once',
                              value: "${data.analytics?.repeatHireRate?.toString() ?? '0'}%",
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: MetricsCard(
                              label: 'Average Response Time',
                              tooltipMessage:
                                  'How quickly creator usually responds to new messages and booking requests',
                              value: data.analytics?.averageResponseTime?.toString() ?? '0',
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: MetricsCard(
                              label: 'Joined',
                              tooltipMessage: 'How long the creator has been on Creatify',
                              value: data.analytics?.memberSince?.timeNoAgo() ?? '0',
                            ),
                          ),
                        ],
                      ),
                      24.0.height,

                      // MARK: Tabs
                      Center(child: CreatorProfileTabBar(tabController: tabController)),
                      16.0.height,

                      // Grid Views - Content based on selected tab
                      AnimatedBuilder(
                        animation: tabController,
                        builder: (context, child) {
                          final currentIndex = tabController.index;

                          switch (currentIndex) {
                            case 0:
                              // Portfolio
                              return data.portfolio?.isEmpty ?? true
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 40),
                                        child: Text(
                                          'No Media Uploaded',
                                          style: context.textTheme.bodyMedium,
                                        ),
                                      ),
                                    )
                                  : GridView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: data.portfolio?.length,
                                      itemBuilder: (context, index) {
                                        final item = data.portfolio?[index];
                                        return UploadedImageWithDelete(
                                          portfolioItem: item,
                                          expandMedia: true,
                                        );
                                      },
                                    );
                            case 1:
                              // Rates Card
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.grey300),
                                  color: AppColors.grey50,
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var category = data.categories?[index];
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          category?.name ?? '',
                                          style: context.textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.black2,
                                          ),
                                        ),
                                        const Divider(
                                          color: AppColors.black2,
                                          height: 3,
                                          thickness: 3,
                                        ),
                                        8.0.height,

                                        // Pricings List
                                        Column(
                                          children: data.categories?[index].services
                                                  ?.map(
                                                    (pricing) => Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            pricing.serviceName ?? '',
                                                            style: context.textTheme.bodyMedium
                                                                ?.copyWith(
                                                                    fontWeight: FontWeight.w500),
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            "${pricing.price.amountWithCurrency(data.primaryCurrency ?? '')}/${pricing.pricingType?.split('_').last.toTitleCase()}",
                                                            textAlign: TextAlign.end,
                                                            style: context.textTheme.bodyMedium
                                                                ?.copyWith(
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: FontFamily.inter,
                                                              color: AppColors.highlightCoral,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  .toList() ??
                                              [],
                                        ),
                                      ],
                                    );
                                  },
                                  separatorBuilder: (_, __) => 12.0.height,
                                  itemCount: data.categories?.length ?? 0,
                                ),
                              );
                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      ),
                      24.0.height,
                      // MARK: Reviews Section
                      Text(
                        "Ratings & Reviews",
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.subHeading,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      16.0.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Ratings Summary
                          RatingSummary(
                            rating: data.ratingsAndReviews?.averageRating ?? 0.0,
                            totalReviews: data.ratingsAndReviews?.totalReviews ?? 0,
                          ),
                          32.0.width,

                          // Ratings Metrics
                          Expanded(
                            child: RatingMetrics(
                              ratings: [
                                RatingData(
                                  stars: 5,
                                  count: data.ratingsAndReviews?.ratingBreakdown?.the5Star ?? 0,
                                ),
                                RatingData(
                                  stars: 4,
                                  count: data.ratingsAndReviews?.ratingBreakdown?.the4Star ?? 0,
                                ),
                                RatingData(
                                  stars: 3,
                                  count: data.ratingsAndReviews?.ratingBreakdown?.the3Star ?? 0,
                                ),
                                RatingData(
                                  stars: 2,
                                  count: data.ratingsAndReviews?.ratingBreakdown?.the2Star ?? 0,
                                ),
                                RatingData(
                                  stars: 1,
                                  count: data.ratingsAndReviews?.ratingBreakdown?.the1Star ?? 0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      18.0.height,
                      Text(
                        "Most Recent",
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.body,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      12.0.height,

                      // Most Recent Card List
                      Column(
                        children: data.ratingsAndReviews?.reviews?.isEmpty == true
                            ? [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'No Reviews Yet',
                                      style: context.textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ]
                            : data.ratingsAndReviews?.reviews
                                    ?.where((review) => review.review != null)
                                    .map(
                                      (review) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: MostRecentCard(
                                          reviewerName: review.reviewerName ?? 'Jane Doe',
                                          rating: review.rating ?? 0.0,
                                          reviewDate: review.createdAt != null
                                              ? review.createdAt!
                                                  .toLocal()
                                                  .toFormattedDateWithYear()
                                              : 'Unknown Date',
                                          reviewText: review.review ?? 'No review text',
                                        ),
                                      ),
                                    )
                                    .toList() ??
                                [],
                      ),
                      16.0.height,
                    ],
                  );
                },
                error: (error, stacktrace) => Center(child: Text(error.toString())),
                loading: () => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      105.0.height,
                      const Text('Loading Your Profile...'),
                      8.0.height,
                      const CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
