import 'package:creatify_mobile/view/modules/bookings/widgets/expandable_profile_image.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/most_recent_card.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/image_preview.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/update-sheets/upgrade_account_successful_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/make_subscription_payment_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/metrics_card.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/modules/home/rating/rating_widgets.dart';
import 'package:creatify_mobile/view/utils/file_and_image_picker.dart';
import 'package:creatify_mobile/view/widgets/overlay_animation.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyRecruiterProfileView extends ConsumerStatefulWidget {
  const MyRecruiterProfileView({super.key});

  @override
  ConsumerState<MyRecruiterProfileView> createState() => _CreatorUpgradeProfileViewState();
}

class _CreatorUpgradeProfileViewState extends ConsumerState<MyRecruiterProfileView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  //final GlobalKey _menuButtonKey = GlobalKey();

  bool openingGallery = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  // void _showProfileMenu() {
  //   final menuItems = ProfileMenuController.createDefaultMenuItems(
  //     onEditProfileImage: _onEditProfileImage,
  //   );

  //   ProfileMenuController.showProfileMenu(
  //     context: context,
  //     buttonKey: _menuButtonKey,
  //     menuItems: menuItems,
  //   );
  // }

  void _onEditProfileImage() async {
    setState(() => openingGallery = true);

    await pickImageFromGallery().then((value) {
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

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final myRecruiterProfile = ref.watch(fetchRecruiterProfileProvider(userData.id ?? ''));

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

    return OverlayLoadingIndicator(
      isLoading: openingGallery,
      text: 'Opening Gallery...',
      child: Scaffold(
        appBar: AppBar(
            // title: Text(
            //   'My Recruiter Profile',
            //   style: context.textTheme.bodyLarge?.copyWith(
            //     fontWeight: FontWeight.w500,
            //     color: AppColors.subHeading,
            //   ),
            // ),
            // actions: [
            //   IconButton(
            //     key: _menuButtonKey,
            //     icon: const Icon(Icons.more_vert, color: AppColors.icons),
            //     onPressed: () {
            //       //_showProfileMenu();
            //     },
            //   ),
            // ],
            ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              myRecruiterProfile.when(
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
                          ],
                        );
                      }),
                      8.0.height,
                      Center(
                        child: Text(
                          userData.name ?? 'John Doe',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      4.0.height,

                      Center(
                        child: Text(
                          'Recruiter Profile',
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
                      24.0.height,

                      // MARK: Metrics
                      Text(
                        "Recruiter Metrics",
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
                              label: 'Total Bookings',
                              tooltipMessage:
                                  'Total number of bookings this recruiter has made on Creatify',
                              value: data.analytics?.totalBookings?.toString() ?? '0',
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: MetricsCard(
                              label: 'Repeat Hire Rate',
                              tooltipMessage:
                                  'Percentage of creators this recruiter has hired more than once',
                              value: "${data.analytics?.repeatHireRate?.toString()}%",
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: MetricsCard(
                              label: 'Joined',
                              tooltipMessage: 'How long the recruiter has been on Creatify',
                              value: data.analytics?.memberSince?.timeNoAgo() ?? '0',
                            ),
                          ),
                        ],
                      ),
                      12.0.height,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Expanded(
                            flex: 3,
                            child: MetricsCard(
                              label: 'Active Bookings',
                              tooltipMessage:
                                  'Number of bookings currently in progress with creators',
                              value: data.analytics?.activeBookings?.toString() ?? '0',
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: MetricsCard(
                              label: 'Cancellation Rate',
                              tooltipMessage:
                                  'Percentage of bookings this recruiter has cancelled after confirming a booking',
                              value: "${data.analytics?.cancellationRate?.toString()}%",
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: MetricsCard(
                              label: 'Average Response Time',
                              tooltipMessage:
                                  'Average time this recruiter takes to respond to messages and booking requests',
                              value: data.analytics?.averageResponseTime?.toString() ?? '0',
                            ),
                          ),
                        ],
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
                      const Text('Loading your Recruiter Profile...'),
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
