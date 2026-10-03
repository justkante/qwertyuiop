import 'package:creatify_mobile/data/models/responses/recruiter_profile_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/report_account_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/creator_menu_popup.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/expandable_profile_image.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/most_recent_card.dart';
import 'package:creatify_mobile/view/modules/home/rating/rating_widgets.dart';
import 'package:creatify_mobile/view/modules/home/rating/star_rating.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/metrics_card.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FetchedRecruiterProfileView extends ConsumerStatefulWidget {
  const FetchedRecruiterProfileView({
    super.key,
    required this.creatorId,
    required this.creatorName,
  });

  final String creatorId, creatorName;

  @override
  ConsumerState<FetchedRecruiterProfileView> createState() => _FetchedRecruiterProfileViewState();
}

class _FetchedRecruiterProfileViewState extends ConsumerState<FetchedRecruiterProfileView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final GlobalKey _menuButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
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
    );

    CreatorMenuController.showProfileMenu(
      context: context,
      buttonKey: _menuButtonKey,
      menuItems: menuItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recruiterProfileAsync = ref.watch(fetchRecruiterProfileProvider((widget.creatorId, null)));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "${widget.creatorName.split(' ')[0]}'s Profile",
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF1B3131),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            key: _menuButtonKey,
            icon: const Icon(Icons.more_vert, color: AppColors.icons),
            onPressed: _showProfileMenu,
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.invalidate(fetchRecruiterProfileProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              recruiterProfileAsync.when(
                data: (data) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // MARK: Centered Profile Picture (Same 100px size as MyRecruiterProfileView)
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            ExpandableProfileImage(
                              imageUrl: data.profileImage,
                              initials: data.initials,
                              size: 100,
                              initialsFallback: Center(
                                child: InitialAvatar(
                                  initials: data.initials,
                                  size: 36,
                                  padding: const EdgeInsets.all(20),
                                ),
                              ),
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
                                data.name ?? widget.creatorName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B3131)),
                              ),
                              if (data.isPremium == true || (data.ratingsAndReviews?.averageRating != null && data.ratingsAndReviews!.averageRating! >= 4.5)) ...[
                                4.0.width,
                                const Icon(Icons.check_circle, color: Color(0xFF2196F3), size: 18),
                              ],
                            ],
                          ),
                          4.0.height,
                          Text('Recruiter Profile', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                          8.0.height,
                          StarRating(rating: data.ratingsAndReviews?.averageRating ?? 0.0, starCount: 5, starSize: 16),
                          4.0.height,
                          Text(
                            '${data.ratingsAndReviews?.averageRating ?? 0.0} (${data.ratingsAndReviews?.totalReviews ?? 0} reviews)',
                            style: const TextStyle(color: AppColors.body, fontSize: 11),
                          ),
                        ],
                      ),
                      16.0.height,

                      // Location & Type Chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSmallInfoChip(Icons.location_on_outlined, data.location ?? 'Lagos, Nigeria'),
                          12.0.width,
                          _buildSmallInfoChip(Icons.business_center_outlined, 'Agency'),
                        ],
                      ),
                      32.0.height,

                      // Profile Tabs (Overview, Company, Preferences)
                      _buildProfileTabs(),
                      24.0.height,
                      AnimatedBuilder(
                        animation: tabController,
                        builder: (context, _) {
                          if (tabController.index == 0) return _buildOverviewTab(data);
                          if (tabController.index == 1) return _buildCompanyTab(data);
                          return _buildPreferencesTab(data);
                        },
                      ),
                      120.0.height,
                    ],
                  );
                },
                error: (error, stacktrace) => Center(child: Text(error.toString())),
                loading: () => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      80.0.height,
                      const Text('Loading Recruiter Profile...'),
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

  Widget _buildSmallInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.body),
          4.0.width,
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.body)),
        ],
      ),
    );
  }

  Widget _buildProfileTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(30)),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
        labelColor: Colors.black,
        unselectedLabelColor: AppColors.body,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Company'),
          Tab(text: 'Preferences'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(RecruiterProfileDto data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recruiter Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131))),
        12.0.height,
        Row(
          children: [
            Expanded(child: MetricsCard(label: 'Bookings', value: '${data.analytics?.totalBookings ?? 0}', tooltipMessage: 'Total bookings made')),
            8.0.width,
            Expanded(child: MetricsCard(label: 'Repeat Rate', value: '${data.analytics?.repeatHireRate ?? 0}%', tooltipMessage: 'Repeat hire percentage')),
            8.0.width,
            Expanded(child: MetricsCard(label: 'Resp. Time', value: '${data.analytics?.averageResponseTime ?? 0}', tooltipMessage: 'Average response time')),
          ],
        ),
        24.0.height,

        const Text('Ratings & Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131))),
        16.0.height,
        Row(
          children: [
            Column(
              children: [
                Text('${data.ratingsAndReviews?.averageRating ?? 0.0}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B3131))),
                StarRating(rating: data.ratingsAndReviews?.averageRating ?? 0.0, starCount: 5, starSize: 12),
              ],
            ),
            24.0.width,
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
      ],
    );
  }

  Widget _buildCompanyTab(RecruiterProfileDto data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Company Bio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131))),
        8.0.height,
        Text(
          data.bio?.isNotEmpty == true ? data.bio! : 'No company bio added yet.',
          style: const TextStyle(color: AppColors.body, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildPreferencesTab(RecruiterProfileDto data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131))),
        8.0.height,
        const Text('Hires for creative, video, and design projects.', style: TextStyle(color: AppColors.body, fontSize: 13)),
      ],
    );
  }
}
