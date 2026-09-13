import 'package:creatify_mobile/view/modules/bookings/share_profile_widget.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/report_account_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/creator_menu_popup.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/creator_profile_tab.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/expandable_profile_image.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/most_recent_card.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/profile_quick_detail.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/upgrade_account_successful_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/favorite_creators_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/make_subscription_payment_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/metrics_card.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/uploaded_image_with_cancel.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_dialog.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/modules/home/rating/rating_widgets.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FetchedCreatorProfileView extends ConsumerStatefulWidget {
  const FetchedCreatorProfileView({
    super.key,
    required this.creatorId,
    required this.creatorName,
  });

  final String creatorId, creatorName;

  @override
  ConsumerState<FetchedCreatorProfileView> createState() => _CreatorUpgradeProfileViewState();
}

class _CreatorUpgradeProfileViewState extends ConsumerState<FetchedCreatorProfileView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final GlobalKey _menuButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  void _showProfileMenu() {
    final menuItems = CreatorMenuController.createDefaultMenuItems(
      reportAccount: () {
        AppBottomSheet.showBottomSheet(
          context,
          widget: ReportCreatorAccountSheet(
            userId: widget.creatorId,
          ),
        );
      },
      shareProfile: () {
        ref.watch(fetchCreatorProfileProvider(widget.creatorId)).whenData((profile) {
          AppDialog.showAppDialog(
            context,
            widget: ShareProfileWidget(
              profile: profile,
            ),
          );
        });
      },
    );

    CreatorMenuController.showProfileMenu(
      context: context,
      buttonKey: _menuButtonKey,
      menuItems: menuItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final myCreatorProfile = ref.watch(fetchCreatorProfileProvider(widget.creatorId));
    final makeFavorite = ref.watch(addToFavoriteCreatorsProvider).isLoading;
    final hasProfile = myCreatorProfile.hasValue;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' ${widget.creatorName.split(' ')[0]}\'s Creator Profile',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.subHeading,
          ),
        ),
        actions: [
          IconButton(
            key: _menuButtonKey,
            icon: const Icon(Icons.more_vert, color: AppColors.icons),
            onPressed: () {
              _showProfileMenu();
            },
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
                    ExpandableProfileImage(
                      imageUrl: data.profileImage,
                      initials: data.initials,
                      size: 72,
                      initialsFallback: Center(
                        child: InitialAvatar(
                          initials: data.initials,
                          padding: const EdgeInsets.all(20),
                          size: 26,
                        ),
                      ),
                    ),
                    8.0.height,
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data.name ?? 'John Doe',
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
                    8.0.height,

                    // Rating
                    Center(
                      child: StarRating(
                        rating: data.ratingsAndReviews?.averageRating ?? 0.0,
                        starCount: 5,
                        starSize: 16,
                      ),
                    ),
                    16.0.height,

                    // Last Seen
                    if (data.lastSeenAt != null) ...[
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.highlightYellow50,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(AppImages.indicator, width: 6, height: 6),
                              6.0.width,
                              Text(
                                "Last seen: ${data.lastSeenAt}",
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: AppColors.highlightYellow,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      12.0.height,
                    ],

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
                            // Portfolio Videos
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
                                                        child: RichText(
                                                          textAlign: TextAlign.end,
                                                          text: TextSpan(
                                                            text: userData.primaryCurrency ==
                                                                    pricing.currency
                                                                ? pricing.price.amountWithCurrency(
                                                                    pricing.currency ?? '')
                                                                : "${pricing.convertedPrice?.display}",
                                                            style: context.textTheme.bodyMedium
                                                                ?.copyWith(
                                                              fontWeight: FontWeight.w500,
                                                              color: AppColors.highlightCoral,
                                                              fontFamily: FontFamily.inter,
                                                            ),
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    "/${pricing.pricingType?.split('_').last.toTitleCase()}",
                                                                style: context.textTheme.bodySmall
                                                                    ?.copyWith(
                                                                  color: AppColors.subHeading,
                                                                ),
                                                              ),
                                                            ],
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
                                            ? review.createdAt!.toLocal().toFormattedDateWithYear()
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
                    const Text('Loading Creator Profile...'),
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
      // MARK: Bottom Buttons
      bottomNavigationBar: Visibility(
        visible: hasProfile && !(myCreatorProfile.value?.isFavorited ?? false),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.surface, width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MainButton(
                text: 'Save Account',
                textColor: AppColors.btnText,
                color: AppColors.btnTertiary,
                loadingColor: AppColors.subHeading,
                isLoading: makeFavorite,
                onPressed: () {
                  ref
                      .read(addToFavoriteCreatorsProvider.notifier)
                      .addToFavoriteCreators(widget.creatorId);
                },
              ),
              12.0.height,
            ],
          ),
        ),
      ),
    );
  }
}
