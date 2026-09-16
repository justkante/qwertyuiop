import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
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
import 'package:creatify_mobile/view/modules/jobs/jobs_main_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/my_creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/my_recruiter_profile_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/onboarding_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/filter_creators_vm.dart';
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
import 'package:creatify_mobile/view/utils/tour/guarded_showcase.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';
import 'package:creatify_mobile/view/utils/tour/tour_providers.dart';
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
        ref.read(startMainTourProvider.notifier).state = true;
        return;
      }
    }

    if (!mounted) return;
    if (SharedPrefManager.countryUpdatedAt.isEmpty) {
      AppBottomSheet.showBottomSheet(context, widget: const SetCountrySheet());
    }

    // Check for pending reviews
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
    final recommendedCreators = ref.watch(getRecommendedCreatorsProvider);
    final transactions = ref.watch(getTransactionsProvider);
    final bookings = ref.watch(fetchReceivedBookingsProvider);

    final hasUnreadNotifications = ref.watch(fetchNotificationsProvider).hasValue &&
        ((ref.watch(fetchNotificationsProvider).value?.unreadCount ?? 0) > 0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const HomeDrawer(),
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () async {
            ref.invalidate(userControllerProvider);
            ref.invalidate(getOnboardingStatusProvider);
            ref.invalidate(jobControllerProvider);
            ref.invalidate(getRecommendedCreatorsProvider);
            ref.invalidate(getTransactionsProvider);
            ref.invalidate(fetchReceivedBookingsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // MARK: Header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: InitialAvatar(initials: userData.getInitials, size: 20),
                      ),
                      12.0.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello ${userData.name?.split(' ').first},',
                            style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text('What would you like to do today?', style: context.textTheme.bodySmall?.copyWith(fontSize: 10, color: AppColors.body)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(onPressed: () => NavigationService.instance.push(const FavoritesView()), icon: SvgPicture.asset(AppImages.favorite)),
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          IconButton(onPressed: () => NavigationService.instance.push(const NotificationsView()), icon: SvgPicture.asset(AppImages.bell)),
                          if (hasUnreadNotifications)
                            Positioned(right: 12, top: 12, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // MARK: Top Banners
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(child: _buildSmallBanner('Post a job advert', AppImages.editOutline, const Color(0xFFE0F2F1), const Color(0xFF00BFA5), () {
                        NavigationService.instance.push(JobsMainView(initialIndex: 2));
                      })),
                      12.0.width,
                      Expanded(child: _buildSmallBanner('Find talent', AppImages.search, const Color(0xFFE3F2FD), const Color(0xFF2196F3), () {
                        ref.read(custom_nav.navBarController.notifier).index = 1;
                      })),
                    ],
                  ),
                ),
              ),

              // MARK: Large Banner
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                sliver: SliverToBoxAdapter(
                  child: _buildLargeBanner('Apply directly to\ncreative jobs', 'Find and apply for top creative opportunities.', const Color(0xFF1B3131), AppImages.suitcase, () {
                    ref.read(custom_nav.navBarController.notifier).index = 2;
                  }),
                ),
              ),

              // MARK: Secondary Banners (Under Large Banner)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(child: _buildSmallBanner('Post a job advert', AppImages.editOutline, AppColors.grey50, AppColors.subHeading, () {
                         NavigationService.instance.push(JobsMainView(initialIndex: 2));
                      })),
                      12.0.width,
                      Expanded(child: _buildSmallBanner('Find talent', AppImages.search, AppColors.grey50, AppColors.subHeading, () {
                        ref.read(custom_nav.navBarController.notifier).index = 1;
                      })),
                    ],
                  ),
                ),
              ),

              // MARK: Metric Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Quick Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      16.0.height,
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.6,
                        children: [
                          MetricCard(label: 'Open jobs', value: '${jobState.jobs.length}', icon: Icons.work_outline, bgColor: const Color(0xFFE0F2F1), iconColor: const Color(0xFF00BFA5), onTap: () => ref.read(custom_nav.navBarController.notifier).index = 2),
                          MetricCard(label: 'Applications', value: '0', icon: Icons.assignment_outlined, bgColor: const Color(0xFFE3F2FD), iconColor: const Color(0xFF2196F3), onTap: () => NavigationService.instance.push(JobsMainView(initialIndex: 1))),
                          MetricCard(label: 'Profile Views', value: '${myCreatorProfile.value?.analytics?.totalBookings ?? 0}', icon: Icons.remove_red_eye_outlined, bgColor: const Color(0xFFFFFDE7), iconColor: const Color(0xFFF9A825), onTap: () {}),
                          MetricCard(label: 'Bookings', value: '${bookings.value?.length ?? 0}', icon: Icons.calendar_today_outlined, bgColor: const Color(0xFFF3E5F5), iconColor: const Color(0xFF7B1FA2), onTap: () => ref.read(custom_nav.navBarController.notifier).index = 3),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // MARK: Profile Strength (For Creators)
              if (userData.roles?.contains('creator') == true)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
                  sliver: SliverToBoxAdapter(
                    child: ProfileStrengthWidget(
                      user: userData,
                      onboardingStatus: onboardingStatus.value,
                      creatorProfile: myCreatorProfile.value,
                    ),
                  ),
                ),

              // MARK: Recommended Section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 32, 22, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SectionHeader(
                        title: _recommendedToggle == 0 ? 'Recommended creators' : 'Recommended for you',
                        trailing: _buildToggleSwitch(_recommendedToggle, (val) => setState(() => _recommendedToggle = val)),
                      ),
                      16.0.height,
                      if (_recommendedToggle == 0)
                        _buildCreatorsList(recommendedCreators)
                      else
                        _buildJobsList(jobState),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => ref.read(custom_nav.navBarController.notifier).index = _recommendedToggle == 0 ? 1 : 2,
                          child: const Text('View All', style: TextStyle(color: AppColors.highlightCoral, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // MARK: Listings Section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SectionHeader(
                        title: _listingToggle == 0 ? 'Your active listings' : 'Quick actions',
                        trailing: _buildToggleSwitch(_listingToggle, (val) => setState(() => _listingToggle = val)),
                      ),
                      16.0.height,
                      if (_listingToggle == 0)
                        _buildActiveListings(jobState)
                      else
                        _buildQuickActions(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => ref.read(custom_nav.navBarController.notifier).index = 2,
                          child: const Text('View All', style: TextStyle(color: AppColors.highlightCoral, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // MARK: Recent Activity
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 40),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      16.0.height,
                      transactions.when(
                        data: (data) => Column(
                          children: (data.data ?? []).take(3).map((t) => TransactionItem(transaction: t)).toList(),
                        ),
                        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                        error: (_, __) => const Text('Error loading activity'),
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

  Widget _buildSmallBanner(String title, String icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: SvgPicture.asset(icon, color: iconColor, width: 14)),
            8.0.width,
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1B3131)))),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeBanner(String title, String subtitle, Color bgColor, String icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(24)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, height: 1.2)),
                  8.0.height,
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                ],
              ),
            ),
            SvgPicture.asset(icon, width: 60, color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(int current, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          _buildToggleItem(0, current == 0, onChanged),
          _buildToggleItem(1, current == 1, onChanged),
        ],
      ),
    );
  }

  Widget _buildToggleItem(int index, bool active, Function(int) onTap) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 30,
        height: 20,
        decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(15), boxShadow: active ? [const BoxShadow(color: Colors.black12, blurRadius: 2)] : null),
      ),
    );
  }

  Widget _buildCreatorsList(AsyncValue<dynamic> recommended) {
    return recommended.when(
      data: (data) => SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: (data.data as List).length,
          separatorBuilder: (_, __) => 12.0.width,
          itemBuilder: (context, index) => SizedBox(width: 280, child: CreatorsCard(profile: data.data[index])),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (_, __) => const Text('Error loading creators'),
    );
  }

  Widget _buildJobsList(JobState state) {
    if (state.jobs.isEmpty) return const Text('No job adverts found');
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.jobs.length,
        separatorBuilder: (_, __) => 12.0.width,
        itemBuilder: (context, index) => SizedBox(width: 300, child: JobPostCard(
          title: state.jobs[index].title ?? '',
          location: state.jobs[index].location ?? '',
          price: state.jobs[index].price ?? 0,
          currency: state.jobs[index].currency ?? 'NGN',
          dateRange: 'Posted ${state.jobs[index].createdAt?.timeAgo()}',
          status: '',
          onTap: () {},
          description: state.jobs[index].description ?? '',
        )),
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

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionItem('Withdraw', Icons.account_balance_wallet_outlined, () {}),
        _buildActionItem('Fund Wallet', Icons.add_circle_outline, () {}),
        _buildActionItem('Subscription', Icons.star_outline, () {}),
        _buildActionItem('Referrals', Icons.people_outline, () {}),
      ],
    );
  }

  Widget _buildActionItem(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: AppColors.grey100), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [Icon(icon, size: 20, color: AppColors.primary), 12.0.width, Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))]),
      ),
    );
  }
}
