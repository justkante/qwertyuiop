import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/view/modules/jobs/vm/job_controller.dart';
import 'package:creatify_mobile/view/modules/bookings/received_bookings_view.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/rate_recruiter_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/home/enable_biometrics_sheet.dart';
import 'package:creatify_mobile/view/modules/home/favorites_view.dart';
import 'package:creatify_mobile/view/modules/home/home_drawer.dart';
import 'package:creatify_mobile/view/modules/home/notifications_view.dart';
import 'package:creatify_mobile/view/modules/home/referral_page_view.dart';
import 'package:creatify_mobile/view/modules/home/set_country_sheet.dart';
import 'package:creatify_mobile/view/modules/home/vm/presence_vm.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/home/widgets/home_components.dart';
import 'package:creatify_mobile/view/modules/jobs/jobs_main_view.dart' as jobs_view;
import 'package:creatify_mobile/view/modules/showcase-talents/my_creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/my_recruiter_profile_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/onboarding_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/filter_creators_vm.dart' as filter_vm;
import 'package:creatify_mobile/view/modules/showcase-talents/vm/start_onboarding_vm.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart' as custom_nav;
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/get_transactions_vm.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_dialog.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/tour/tour_dialog.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({
    super.key,
    this.showOnboardingSheet = false,
  });

  final bool showOnboardingSheet;

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _initSequence() async {
    ref.read(presenceProvider.notifier).setPresence(true);

    if (!SharedPrefManager.hasSeenTourDialog) {
      SharedPrefManager.hasSeenTourDialog = true;
      final accepted = await AppDialog.showAppDialog(
        context,
        barrierDismissible: false,
        removeInsetPadding: true,
        widget: const TourDialogContent(),
      );
      if (accepted == true) {
        SharedPrefManager.tourAccepted = true;
        return;
      }
    }

    if (!mounted) return;
    if (SharedPrefManager.countryUpdatedAt.isEmpty) {
      AppBottomSheet.showBottomSheet(context, widget: const SetCountrySheet());
    }

    ref.read(fetchPendingReviewsProvider.future).then((review) {
      if (review.isNotEmpty && mounted) {
        AppBottomSheet.showBottomSheet(
          context,
          isDismissible: false,
          enableDrag: false,
          widget: RateRecruiterSheet(
            bookingId: review.first.bookingId ?? '',
            recruiterName: review.first.recruiter?.name ?? '',
            jobDescription: review.first.jobDescription ?? '',
          ),
        );
      }
    });

    if (widget.showOnboardingSheet) {
      _openOnboarding();
    } else if (!SharedPrefManager.shownBiometricsSheet && ref.read(userControllerProvider).authStrategy == 'email') {
      AppBottomSheet.showBottomSheet(context, widget: const EnableBiometricsSheet());
      SharedPrefManager.shownBiometricsSheet = true;
    }
  }

  void _openOnboarding() {
    ref.invalidate(getOnboardingStatusProvider);
    ref.watch(getOnboardingStatusProvider.future).then((status) {
      if (mounted && status.isOnboarded != true) {
        ref.read(startOnboardingProvider.notifier).startOnboarding();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSequence();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final onboardingStatus = ref.watch(getOnboardingStatusProvider);
    final myCreatorProfile = ref.watch(fetchCreatorProfileProvider(userData.id ?? ''));
    final jobState = ref.watch(jobControllerProvider);
    final transactions = ref.watch(getTransactionsProvider);
    final bookings = ref.watch(fetchReceivedBookingsProvider);
    final sentBookings = ref.watch(fetchSentBookingsProvider);

    final hasUnreadNotifications = ref.watch(fetchNotificationsProvider).hasValue &&
        ((ref.watch(fetchNotificationsProvider).value?.unreadCount ?? 0) > 0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F9F9),
      drawer: const HomeDrawer(),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () async {
            ref.invalidate(userControllerProvider);
            ref.invalidate(getOnboardingStatusProvider);
            ref.invalidate(jobControllerProvider);
            ref.invalidate(getTransactionsProvider);
            ref.invalidate(fetchReceivedBookingsProvider);
            ref.invalidate(fetchSentBookingsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          InkWell(
                            onTap: () => _scaffoldKey.currentState?.openDrawer(),
                            child: InitialAvatar(initials: userData.getInitials, size: 22),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: Color(0xFF00BFA5), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        'Creatify',
                        style: TextStyle(color: Color(0xFF009688), fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          IconButton(
                            onPressed: () => NavigationService.instance.push(const NotificationsView()),
                            icon: const Icon(Icons.notifications_none_outlined, color: Colors.black, size: 28),
                          ),
                          if (hasUnreadNotifications)
                            Positioned(right: 12, top: 12, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Good morning, ${userData.name?.split(' ').first}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B3131)),
                          ),
                          4.0.width,
                          const Text('👋', style: TextStyle(fontSize: 22)),
                        ],
                      ),
                      Text('Ready to get discovered today?', style: TextStyle(fontSize: 14, color: AppColors.body)),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(16)),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Search jobs, recruiters or roles',
                              hintStyle: TextStyle(color: AppColors.body, fontSize: 13),
                              icon: Icon(Icons.search, color: AppColors.body, size: 22),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      12.0.width,
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.tune, color: Colors.black, size: 22),
                      ),
                    ],
                  ),
                ),
              ),

              // Large Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF80CBC4), Color(0xFFE0F2F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF00BFA5), borderRadius: BorderRadius.circular(8)),
                                child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              12.0.height,
                              const Text(
                                'Apply directly to\ncreative jobs',
                                style: TextStyle(color: Color(0xFF1B3131), fontWeight: FontWeight.bold, fontSize: 24, height: 1.2),
                              ),
                              8.0.height,
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: const Text(
                                  'Find opportunities, connect with brands, and do what you love.',
                                  style: TextStyle(color: Color(0xFF1B3131), fontSize: 11),
                                ),
                              ),
                              20.0.height,
                              ElevatedButton(
                                onPressed: () => ref.read(custom_nav.navBarController.notifier).index = 2,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00796B),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Browse jobs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    Icon(Icons.chevron_right, color: Colors.white, size: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: -10,
                          bottom: 0,
                          child: Image.network(
                            'https://creatify-assets.s3.amazonaws.com/home-banner-woman.png', // Placeholder URL
                            height: 180,
                            errorBuilder: (_, __, ___) => SvgPicture.asset(AppImages.suitcase, width: 120, color: Colors.white.withOpacity(0.2)),
                          ),
                        ),
                        // Sticker
                        Positioned(
                          right: 20,
                          top: 20,
                          child: Transform.rotate(
                            angle: 0.1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)]),
                              child: const Text('Create\nWork\nGrow', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, height: 1.1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Metrics Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      _buildMiniMetric('Applications', '4', const Color(0xFFE0F2F1), const Color(0xFF00BFA5), Icons.assignment_outlined, () => NavigationService.instance.push(jobs_view.JobsMainView(initialIndex: 1))),
                      12.0.width,
                      _buildMiniMetric('Profile views', '18', const Color(0xFFFFFDE7), const Color(0xFFF9A825), Icons.remove_red_eye_outlined, () {}),
                      12.0.width,
                      _buildMiniMetric('Bookings', '2', const Color(0xFFFCEBEC), const Color(0xFFFF6F61), Icons.calendar_today_outlined, () => ref.read(custom_nav.navBarController.notifier).index = 3),
                    ],
                  ),
                ),
              ),

              // Profile Strength
              if (userData.roles?.contains('creator') == true)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: ProfileStrengthWidget(
                      user: userData,
                      onboardingStatus: onboardingStatus.value,
                      creatorProfile: myCreatorProfile.value,
                    ),
                  ),
                ),

              // Recommended for you
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    children: [
                      SectionHeader(title: 'Recommended for you', onSeeAll: () => ref.read(custom_nav.navBarController.notifier).index = 2),
                      16.0.height,
                      SizedBox(
                        height: 250,
                        child: jobState.jobs.isEmpty
                          ? const Center(child: Text('No recommendations found'))
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: jobState.jobs.length > 5 ? 5 : jobState.jobs.length,
                              separatorBuilder: (_, __) => 16.0.width,
                              itemBuilder: (context, index) => _buildRecommendationCard(jobState.jobs[index]),
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Quick actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B3131))),
                      16.0.height,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickActionCard('Update\nportfolio', Icons.image_outlined, const Color(0xFFE9F4FE), const Color(0xFF2196F3), () {}),
                            12.0.width,
                            _buildQuickActionCard('Set\navailability', Icons.calendar_month_outlined, const Color(0xFFFFFDE7), const Color(0xFFF9A825), () {}),
                            12.0.width,
                            _buildQuickActionCard('View\napplications', Icons.assignment_outlined, const Color(0xFFFCEBEC), const Color(0xFFFF6F61), () {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Activity
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  child: Column(
                    children: [
                      SectionHeader(title: 'Recent activity', onSeeAll: () {}),
                      16.0.height,
                      _buildRecentActivityItem('Your application was sent', 'Birthday Photographer · Lagos', '2h ago', Icons.image_outlined, const Color(0xFFE0F2F1), const Color(0xFF00BFA5)),
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

  Widget _buildMiniMetric(String label, String value, Color bgColor, Color iconColor, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey100)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 14)),
              8.0.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontSize: 9, color: AppColors.body)),
                      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B3131))),
                    ],
                  )),
                  const Icon(Icons.chevron_right, size: 14, color: AppColors.body),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(dynamic job) {
    return Container(
      width: 240,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.grey100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network('https://picsum.photos/seed/${job.id}/400/250', height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
              const Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border, color: Colors.white)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B3131))),
                8.0.height,
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: AppColors.body),
                    4.0.width,
                    Text(job.location ?? '', style: const TextStyle(fontSize: 10, color: AppColors.body)),
                    const Spacer(),
                    const Icon(Icons.account_balance_wallet_outlined, size: 12, color: Color(0xFF00BFA5)),
                    4.0.width,
                    Text(num.parse(job.price.toString()).amountWithCurrency(job.currency ?? 'NGN'), style: const TextStyle(fontSize: 10, color: Color(0xFF00BFA5), fontWeight: FontWeight.bold)),
                  ],
                ),
                12.0.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.body),
                        4.0.width,
                        const Text('12/07/26 - 14/07/26', style: TextStyle(fontSize: 10, color: AppColors.body)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF00796B), shape: BoxShape.circle),
                      child: const Icon(Icons.chevron_right, color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgColor.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 18)),
            12.0.width,
            Expanded(child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B3131), height: 1.2))),
            const Icon(Icons.chevron_right, size: 16, color: Color(0xFF1B3131)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityItem(String title, String subtitle, String time, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.grey100)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 20)),
          16.0.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B3131))),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.body)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(fontSize: 10, color: AppColors.body)),
              const Icon(Icons.chevron_right, size: 16, color: AppColors.body),
            ],
          ),
        ],
      ),
    );
  }
}
