import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/book_creator_view.dart';
import 'package:creatify_mobile/view/modules/bookings/share_profile_widget.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/report_account_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/creator_menu_popup.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/creator_profile_tab.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/expandable_profile_image.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/most_recent_card.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/profile_quick_detail.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/search-talents/login_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/favorite_creators_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/metrics_card.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/uploaded_image_with_cancel.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
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
import 'package:showcaseview/showcaseview.dart';
import 'package:creatify_mobile/core/services/tour_service.dart';
import 'package:creatify_mobile/view/utils/tour/guarded_showcase.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';

class CreatorProfileView extends ConsumerStatefulWidget {
  final CreatorProfileDto? profile;
  final bool isFavorite;

  const CreatorProfileView({
    super.key,
    this.profile,
    this.isFavorite = false,
  });

  @override
  ConsumerState<CreatorProfileView> createState() => _CreatorProfileViewState();
}

class _CreatorProfileViewState extends ConsumerState<CreatorProfileView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final GlobalKey _menuButtonKey = GlobalKey();
  late final ShowcaseView _showcaseView;
  bool _tourStarted = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _showcaseView = ShowcaseView.register(
      scope: 'creator-profile',
      onFinish: () => TourService.markScreenDone(TourService.creatorProfile),
    );
    _tourStarted = !TourService.shouldShowScreenTour(TourService.creatorProfile);
  }

  @override
  void dispose() {
    _showcaseView.unregister();
    super.dispose();
  }

  void _showProfileMenu() {
    final menuItems = CreatorMenuController.createDefaultMenuItems(
      reportAccount: () {
        final userData = ref.watch(userControllerProvider);

        if (userData.id == null) {
          AppBottomSheet.showBottomSheet(
            context,
            widget: const LoginSheet(),
          );
        } else {
          AppBottomSheet.showBottomSheet(
            context,
            widget: ReportCreatorAccountSheet(
              userId: widget.profile?.id,
            ),
          );
        }
      },
      shareProfile: () {
        AppDialog.showAppDialog(
          context,
          widget: ShareProfileWidget(
            profile: widget.profile,
          ),
        );
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
    // User Controller
    final userData = ref.watch(userControllerProvider);

    final makeFavorite = ref.watch(addToFavoriteCreatorsProvider).isLoading;
    final removeFavorite = ref.watch(removeFromFavoriteCreatorsProvider).isLoading;

    ref.listen(addToFavoriteCreatorsProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Added to Favorites', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(removeFromFavoriteCreatorsProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Removed from Favorites', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    if (!_tourStarted) {
      _tourStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showcaseView.startShowCase([
          TourKeys.creatorPortfolio,
          TourKeys.creatorServicesPricing,
          TourKeys.creatorReviews,
          TourKeys.creatorBookButton,
        ]);
      });
    }

    return AbsorbPointer(
      absorbing: makeFavorite || removeFavorite,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "${widget.profile?.name?.split(" ").first}'s Profile",
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.subHeading,
            ),
          ),
          actions: [
            IconButton(
              key: _menuButtonKey,
              icon: const Icon(Icons.more_vert, color: AppColors.icons),
              onPressed: _showProfileMenu,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpandableProfileImage(
                imageUrl: widget.profile?.profileImage,
                initials: widget.profile?.initials ?? '',
                size: 72,
                initialsFallback: Center(
                  child: InitialAvatar(
                    initials: widget.profile?.initials ?? '',
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
                      widget.profile?.name ?? "Akomolafe Kindness",
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.profile?.isPremium == true) ...[
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
                  rating: widget.profile?.ratingsAndReviews?.averageRating ?? 0.0,
                  starCount: 5,
                  starSize: 16,
                ),
              ),
              16.0.height,

              // Last Seen
              if (widget.profile?.lastSeenAt != null) ...[
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
                          "Last seen: ${widget.profile?.lastSeenAt}",
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
                    text: widget.profile?.location ?? 'Lagos',
                  ),
                  14.0.width,
                  QuickDetail(
                    icon: AppImages.workOutline,
                    text: widget.profile?.workMode?.toTitleCase() ?? 'Remote',
                  ),
                  if (widget.profile?.availableToTravel == true) ...[
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
              widget.profile?.categories?.isEmpty == true
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
                        children: widget.profile?.categories
                                ?.map((categories) => categories.name ?? '')
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
                      tooltipMessage: 'Total number of bookings successfully completed on Creatify',
                      value: widget.profile?.analytics?.totalBookings?.toString() ?? '0',
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: MetricsCard(
                      label: 'Cancellation Rate',
                      tooltipMessage: 'Percentage of bookings cancelled after being confirmed',
                      value: "${widget.profile?.analytics?.cancellationRate?.toString() ?? '0'}%",
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: MetricsCard(
                      label: 'Acceptance Rate',
                      tooltipMessage: 'How often creator accepts booking requests sent to them',
                      value: "${widget.profile?.analytics?.completionRate?.toString() ?? '0'}%",
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
                      value: "${widget.profile?.analytics?.repeatHireRate?.toString() ?? '0'}%",
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: MetricsCard(
                      label: 'Average Response Time',
                      tooltipMessage:
                          'How quickly creator usually responds to new messages and booking requests',
                      value: widget.profile?.analytics?.averageResponseTime?.toString() ?? '0',
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: MetricsCard(
                      label: 'Joined',
                      tooltipMessage: 'How long the creator has been on Creatify',
                      value: widget.profile?.analytics?.memberSince?.timeNoAgo() ?? '0',
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
                      return widget.profile?.portfolio?.isEmpty ?? true
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
                              itemCount: widget.profile?.portfolio?.length,
                              itemBuilder: (context, index) {
                                final item = widget.profile?.portfolio?[index];
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
                            var category = widget.profile?.categories?[index];
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
                                  children: widget.profile?.categories?[index].services
                                          ?.map(
                                            (pricing) => Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    pricing.serviceName ?? '',
                                                    style: context.textTheme.bodyMedium
                                                        ?.copyWith(fontWeight: FontWeight.w500),
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
                                                      style: context.textTheme.bodyMedium?.copyWith(
                                                        fontWeight: FontWeight.w500,
                                                        color: AppColors.highlightCoral,
                                                        fontFamily: FontFamily.inter,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              "/${pricing.pricingType?.split('_').last.toTitleCase()}",
                                                          style:
                                                              context.textTheme.bodySmall?.copyWith(
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
                          itemCount: widget.profile?.categories?.length ?? 0,
                        ),
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
              24.0.height,

              // MARK: Reviews Section
              GuardedShowcase(
                showcaseKey: TourKeys.creatorReviews,
                description: 'See verified reviews from past bookings.',
                targetBorderRadius: BorderRadius.circular(8),
                child: Text(
                  "Ratings & Reviews",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.subHeading,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              16.0.height,
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Ratings Summary
                  RatingSummary(
                    rating: widget.profile?.ratingsAndReviews?.averageRating ?? 0.0,
                    totalReviews: widget.profile?.ratingsAndReviews?.totalReviews ?? 0,
                  ),
                  32.0.width,

                  // Ratings Metrics
                  Expanded(
                    child: RatingMetrics(
                      ratings: [
                        RatingData(
                          stars: 5,
                          count: widget.profile?.ratingsAndReviews?.ratingBreakdown?.the5Star ?? 0,
                        ),
                        RatingData(
                          stars: 4,
                          count: widget.profile?.ratingsAndReviews?.ratingBreakdown?.the4Star ?? 0,
                        ),
                        RatingData(
                          stars: 3,
                          count: widget.profile?.ratingsAndReviews?.ratingBreakdown?.the3Star ?? 0,
                        ),
                        RatingData(
                          stars: 2,
                          count: widget.profile?.ratingsAndReviews?.ratingBreakdown?.the2Star ?? 0,
                        ),
                        RatingData(
                          stars: 1,
                          count: widget.profile?.ratingsAndReviews?.ratingBreakdown?.the1Star ?? 0,
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
                children: widget.profile?.ratingsAndReviews?.reviews?.isEmpty == true
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
                    : widget.profile?.ratingsAndReviews?.reviews
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
          ),
        ),

        // MARK: Bottom Buttons
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.surface, width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (!widget.isFavorite) ...[
                    Expanded(
                      child: MainButton(
                        text: 'Save Account',
                        textColor: AppColors.btnText,
                        color: AppColors.btnTertiary,
                        loadingColor: AppColors.subHeading,
                        isLoading: makeFavorite,
                        onPressed: () {
                          if (userData.id == null) {
                            AppBottomSheet.showBottomSheet(
                              context,
                              widget: const LoginSheet(),
                            );
                          } else {
                            ref.read(addToFavoriteCreatorsProvider.notifier).addToFavoriteCreators(
                                  widget.profile?.id ?? '',
                                );
                          }
                        },
                      ),
                    ),
                    12.0.width,
                  ],
                  Expanded(
                    child: GuardedShowcase(
                      showcaseKey: TourKeys.creatorBookButton,
                      description: 'Ready to hire? Tap here to book instantly or send an offer.',
                      targetBorderRadius: BorderRadius.circular(8),
                      child: MainButton(
                        text: 'Book',
                        onPressed: () {
                          if (userData.id == null) {
                            AppBottomSheet.showBottomSheet(
                              context,
                              widget: const LoginSheet(),
                            );
                          } else {
                            context.push(
                              BookCreatorView(
                                creatorProfile: widget.profile ?? CreatorProfileDto(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              12.0.height
            ],
          ),
        ),
      ),
    );
  }
}
