import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/data/models/responses/recommended_creators_dto.dart';
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
import 'package:creatify_mobile/view/modules/jobs/widgets/job_post_card.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/creator_card.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/get_transactions_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/widgets/transaction_item.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_dialog.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/tour/tour_dialog.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
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

  int _recommendedToggle = 0; // 0 for Creators, 1 for Jobs
  int _listingToggle = 0; // 0 for Active Listings, 1 for Quick Actions

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
    final recommendedCreatorsAsync = ref.watch(filter_vm.getRecommendedCreatorsProvider);
    final transactions = ref.watch(getTransactionsProvider);
    final bookings = ref.watch(fetchReceivedBookingsProvider);

    final hasUnreadNotifications = ref.watch(fetchNotificationsProvider).hasValue &&
        ((ref.watch(fetchNotificationsProvider).value?.unreadCount ?? 0) > 0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F9F9),
      drawer: const HomeDrawer(),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () async {
            await ref.read(userControllerProvider.notifier).refreshUser();
            ref.invalidate(getOnboardingStatusProvider);
            ref.invalidate(jobControllerProvider);
            ref.invalidate(filter_vm.getRecommendedCreatorsProvider);
            ref.invalidate(getTransactionsProvider);
            ref.invalidate(fetchReceivedBookingsProvider);
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
                            decoration: BoxDecoration(
                                color: const Color(0xFF00BFA5),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2)),
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
                            'Good morning, ${userData.name?.split(' ').first ?? 'User'}',
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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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

              // MARK: Post Job & Find Talent Banners (One Line) - Under Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSmallActionBanner(
                          'Post a job advert',
                          'Reach thousands\nof creative talent',
                          const Color(0xFFE0F2F1),
                          const Color(0xFF00BFA5),
                          Icons.add_circle_outline,
                          () {
                            ref.read(jobTabIndexProvider.notifier).state = 2; // My Listings tab
                            ref.read(custom_nav.navBarController.notifier).index = 2; // Jobs tab
                          },
                        ),
                      ),
                      12.0.width,
                      Expanded(
                        child: _buildSmallActionBanner(
                          'Find talent',
                          'Browse and connect\nwith creators',
                          const Color(0xFFFFFDE7),
                          const Color(0xFFF9A825),
                          Icons.person_search_outlined,
                          () => ref.read(custom_nav.navBarController.notifier).index = 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Large Banner - "Apply directly to creative jobs"
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: _buildLargeBanner(
                    'Apply directly to\ncreative jobs',
                    'Find opportunities, connect with brands, and do what you love.',
                    const Color(0xFFE0F2F1),
                    AppImages.homeBanner,
                    () {
                       ref.read(jobTabIndexProvider.notifier).state = 0; // Search tab
                       ref.read(custom_nav.navBarController.notifier).index = 2; // Jobs tab
                    },
                  ),
                ),
              ),

              // Metrics Row (Scrollable)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _buildFixedMiniMetric('Open jobs', '${jobState.jobs.length}', const Color(0xFFE0F2F1), const Color(0xFF00BFA5), Icons.work_outline, () {
                        ref.read(jobTabIndexProvider.notifier).state = 0;
                        ref.read(custom_nav.navBarController.notifier).index = 2;
                      }),
                      12.0.width,
                      _buildFixedMiniMetric('Applications', '4', const Color(0xFFE3F2FD), const Color(0xFF2196F3), Icons.assignment_outlined, () {
                        ref.read(jobTabIndexProvider.notifier).state = 1; // Applied tab
                        ref.read(custom_nav.navBarController.notifier).index = 2;
                      }),
                      12.0.width,
                      _buildFixedMiniMetric('Profile views', '18', const Color(0xFFFFFDE7), const Color(0xFFF9A825), Icons.remove_red_eye_outlined, () {}),
                      12.0.width,
                      _buildFixedMiniMetric('Bookings', '${bookings.value?.length ?? 0}', const Color(0xFFFCEBEC), const Color(0xFFFF6F61), Icons.calendar_today_outlined, () => ref.read(custom_nav.navBarController.notifier).index = 3),
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

              // Recommended Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    children: [
                      _buildTitledHeader(
                        _recommendedToggle == 0 ? 'Recommended creators' : 'Recommended for you',
                        _buildToggleSwitch(_recommendedToggle, (val) => setState(() => _recommendedToggle = val)),
                      ),
                      16.0.height,
                      if (_recommendedToggle == 0)
                        _buildCreatorsList(recommendedCreatorsAsync)
                      else
                        _buildRecommendationsList(jobState),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => ref.read(custom_nav.navBarController.notifier).index = _recommendedToggle == 0 ? 1 : 2,
                          icon: const Text('See all', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold)),
                          label: const Icon(Icons.chevron_right, color: Color(0xFF00BFA5), size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Listings / Quick Actions Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    children: [
                      _buildTitledHeader(
                        _listingToggle == 0 ? 'Your active listings' : 'Quick actions',
                        _buildToggleSwitch(_listingToggle, (val) => setState(() => _listingToggle = val)),
                      ),
                      16.0.height,
                      if (_listingToggle == 0)
                        _buildActiveListings(jobState)
                      else
                        _buildQuickActionsRow(),
                      if (_listingToggle == 0)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => ref.read(custom_nav.navBarController.notifier).index = 2,
                            icon: const Text('See all', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold)),
                            label: const Icon(Icons.chevron_right, color: Color(0xFF00BFA5), size: 18),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Recent Activity
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 120), // More padding for floating bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitledHeader('Recent activity', TextButton(onPressed: () {}, child: const Text('See all', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold)))),
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

  Widget _buildSmallActionBanner(String title, String subtitle, Color bgColor, Color iconColor, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.grey100)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            8.0.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1B3131))),
                  Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.body)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 14, color: iconColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedMiniMetric(String label, String value, Color bgColor, Color iconColor, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140,
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
                    Text(label, style: const TextStyle(fontSize: 9, color: AppColors.body, fontWeight: FontWeight.w500)),
                    Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B3131))),
                  ],
                )),
                const Icon(Icons.chevron_right, size: 14, color: AppColors.body),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeBanner(String title, String subtitle, Color bgColor, String imagePath, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) => SvgPicture.asset(AppImages.suitcase, width: 60, color: Colors.white.withOpacity(0.2)),
              ),
            ),
          ),
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
                Text(title, style: const TextStyle(color: Color(0xFF1B3131), fontWeight: FontWeight.bold, fontSize: 24, height: 1.2)),
                8.0.height,
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Text(subtitle, style: TextStyle(color: const Color(0xFF1B3131).withOpacity(0.7), fontSize: 11)),
                ),
                20.0.height,
                MainButton(
                  text: 'Browse jobs',
                  width: 140,
                  borderRadius: 24,
                  color: const Color(0xFF00796B),
                  onPressed: onTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitledHeader(String title, Widget trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B3131))),
        trailing,
      ],
    );
  }

  Widget _buildToggleSwitch(int current, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleItem(0, current == 0, onChanged, '1'),
          _buildToggleItem(1, current == 1, onChanged, '2'),
        ],
      ),
    );
  }

  Widget _buildToggleItem(int index, bool active, Function(int) onTap, String label) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 36,
        height: 24,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: active ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : null
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? AppColors.primary : AppColors.body))),
      ),
    );
  }

  Widget _buildCreatorsList(AsyncValue<RecommendedCreatorsDto> recommendedAsync) {
    return recommendedAsync.when(
      data: (data) {
        final list = data.data ?? [];
        if (list.isEmpty) return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No recommended creators found', style: TextStyle(fontSize: 12, color: AppColors.body))));
        return SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => 12.0.width,
            itemBuilder: (context, index) => SizedBox(width: 280, child: CreatorsCard(profile: list[index])),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (e, s) => Center(child: Text('Error loading creators: $e')),
    );
  }

  Widget _buildRecommendationsList(JobState state) {
    if (state.jobs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No recommendations found', style: TextStyle(fontSize: 12, color: AppColors.body))));
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.jobs.length > 5 ? 5 : state.jobs.length,
        separatorBuilder: (_, __) => 16.0.width,
        itemBuilder: (context, index) => _buildRecommendationCard(state.jobs[index]),
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
                child: Image.network('https://picsum.photos/seed/${job.id}/400/250', height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height: 120, color: AppColors.grey50)),
              ),
              const Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border, color: Colors.white)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B3131)), maxLines: 1, overflow: TextOverflow.ellipsis),
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

  Widget _buildActiveListings(JobState state) {
    final active = state.jobs.where((j) => j.status?.toLowerCase() == 'active').toList();
    if (active.isEmpty) return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No current active listing', style: TextStyle(color: AppColors.body))));
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: active.length > 2 ? 2 : active.length,
      separatorBuilder: (_, __) => 12.0.height,
      itemBuilder: (context, index) => JobPostCard(
        title: active[index].title ?? '',
        location: active[index].location ?? '',
        price: active[index].price ?? 0,
        currency: active[index].currency ?? 'NGN',
        dateRange: 'Active',
        status: 'Active',
        onTap: () {},
        description: active[index].description ?? '',
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickActionCard('Update portfolio', Icons.image_outlined, const Color(0xFFE9F4FE), const Color(0xFF2196F3), () {}),
          12.0.width,
          _buildQuickActionCard('Set availability', Icons.calendar_month_outlined, const Color(0xFFFFFDE7), const Color(0xFFF9A825), () {}),
          12.0.width,
          _buildQuickActionCard('View applications', Icons.assignment_outlined, const Color(0xFFFCEBEC), const Color(0xFFFF6F61), () {}),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.grey100), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 18)),
            12.0.width,
            Expanded(child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B3131), height: 1.2))),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.grey300),
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
