import 'package:creatify_mobile/view/modules/bookings/widgets/expandable_profile_image.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/image_preview.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/widgets/metrics_card.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/modules/home/rating/rating_widgets.dart';
import 'package:creatify_mobile/view/utils/file_and_image_picker.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/overlay_animation.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/manage_subscription_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/modules/home/support_view.dart';

class MyRecruiterProfileView extends ConsumerStatefulWidget {
  const MyRecruiterProfileView({super.key});

  @override
  ConsumerState<MyRecruiterProfileView> createState() => _MyRecruiterProfileViewState();
}

class _MyRecruiterProfileViewState extends ConsumerState<MyRecruiterProfileView> with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool openingGallery = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  void _onEditProfileImage() async {
    setState(() => openingGallery = true);
    await pickImageFromGallery().then((value) {
      setState(() => openingGallery = false);
      if (value != null && value.path.isNotEmpty) {
        if (!mounted) return;
        NavigationService.instance.push(ImagePreviewScreen(imageFile: value, fileName: 'Profile Image'));
      }
    }).catchError((error) => setState(() => openingGallery = false));
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final myRecruiterProfile = ref.watch(fetchRecruiterProfileProvider(userData.id ?? ''));

    return OverlayLoadingIndicator(
      isLoading: openingGallery,
      text: 'Opening Gallery...',
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
            IconButton(icon: const Icon(Icons.more_vert, color: AppColors.icons), onPressed: () {}),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              myRecruiterProfile.when(
                data: (data) {
                  return Column(
                    children: [
                      // Top Section: DP, Badge, Name
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                                child: ExpandableProfileImage(
                                  imageUrl: data.profileImage,
                                  initials: data.initials,
                                  size: 80,
                                  initialsFallback: Center(child: InitialAvatar(initials: data.initials, size: 28, padding: const EdgeInsets.all(20))),
                                ),
                              ),
                              GestureDetector(
                                onTap: _onEditProfileImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                                  child: const Icon(Icons.camera_alt_outlined, size: 16, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: _buildUpgradeBadge(),
                            ),
                          ),
                        ],
                      ),
                      12.0.height,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(userData.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          4.0.width,
                          const Icon(Icons.check_circle, color: Color(0xFF2196F3), size: 18),
                        ],
                      ),
                      Text('Recruiter Profile', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                      8.0.height,
                      StarRating(rating: data.ratingsAndReviews?.averageRating ?? 0.0, starCount: 5, starSize: 16),
                      Text('${data.ratingsAndReviews?.averageRating ?? 0.0} (0 reviews)', style: const TextStyle(color: AppColors.body, fontSize: 11)),
                      16.0.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSmallInfoChip(Icons.location_on_outlined, 'Lagos, Nigeria'),
                          12.0.width,
                          _buildSmallInfoChip(Icons.business_center_outlined, 'Company'),
                        ],
                      ),
                      24.0.height,
                      Row(
                        children: [
                          Expanded(child: MainButton(text: 'Edit Profile', color: const Color(0xFFE0F2F1), textColor: AppColors.primary, onPressed: () {})),
                          12.0.width,
                          Expanded(child: MainButton(text: 'View Public Profile', color: AppColors.grey50, textColor: const Color(0xFF1B3131), onPressed: () {})),
                        ],
                      ),
                      24.0.height,
                      _buildProfileTabs(),
                      24.0.height,
                      _buildOverviewTab(data),
                    ],
                  );
                },
                error: (error, _) => Center(child: Text(error.toString())),
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeBadge() {
    return GestureDetector(
      onTap: () => NavigationService.instance.push(const ManageSubscriptionView()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFFFFF1EF), borderRadius: BorderRadius.circular(12)),
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
      decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(30)),
      child: TabBar(
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
        labelColor: Colors.black,
        unselectedLabelColor: AppColors.body,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        dividerColor: Colors.transparent,
        tabs: const [Tab(text: 'Overview'), Tab(text: 'Company Info'), Tab(text: 'Preferences')],
      ),
    );
  }

  Widget _buildOverviewTab(dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [const Text('Recruiter Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), 4.0.width, const Icon(Icons.info_outline, size: 14, color: AppColors.body)]),
            Row(children: [const Text('Last 30 days', style: TextStyle(fontSize: 11, color: AppColors.body)), const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.body)]),
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
            _buildMetricItem('Total Bookings', '0', Icons.shopping_bag_outlined, const Color(0xFFE3F2FD), const Color(0xFF2196F3)),
            _buildMetricItem('Active Bookings', '0', Icons.access_time, const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
            _buildMetricItem('Repeat Hire Rate', '0%', Icons.refresh_outlined, const Color(0xFFF3E5F5), const Color(0xFF7B1FA2)),
            _buildMetricItem('Cancellation Rate', '0.0%', Icons.cancel_outlined, const Color(0xFFFFF1EF), const Color(0xFFFF6F61)),
            _buildMetricItem('Average Response', '0 hrs', Icons.flash_on_outlined, const Color(0xFFE0F2F1), const Color(0xFF00897B)),
            _buildMetricItem('Member Since', '1 week', Icons.calendar_today_outlined, const Color(0xFFFFFDE7), const Color(0xFFF9A825)),
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
                const Text('0.0', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B3131))),
                const StarRating(rating: 0, starCount: 5, starSize: 12),
                const Text('(0 Reviews)', style: TextStyle(color: AppColors.body, fontSize: 10)),
              ],
            ),
            32.0.width,
            const Expanded(child: RatingMetrics(ratings: [])),
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
      decoration: BoxDecoration(border: Border.all(color: AppColors.grey100), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 12))]),
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
      decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFFF3E5F5), shape: BoxShape.circle), child: const Icon(Icons.people_outline, color: Color(0xFF7B1FA2), size: 24)),
          12.0.height,
          const Text('No reviews yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Text('Complete bookings to receive reviews.', style: TextStyle(color: AppColors.body, fontSize: 11)),
        ],
      ),
    );
  }
}
