import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/job_dto.dart';
import 'package:creatify_mobile/view/modules/jobs/vm/job_controller.dart';
import 'package:creatify_mobile/view/modules/bookings/received_bookings_view.dart';
import 'package:creatify_mobile/view/modules/bookings/sent_bookings_view.dart';
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
import 'package:creatify_mobile/view/modules/home/widgets/talent_card.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/my_creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/my_recruiter_profile_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/onboarding_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/start_onboarding_vm.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart' as custom_nav;
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/modules/jobs/widgets/job_post_card.dart';
import 'package:creatify_mobile/view/modules/jobs/job_details_view.dart';
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
import 'package:flutter_animate/flutter_animate.dart';
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

  openOnboardingSheet() {
    ref.invalidate(getOnboardingStatusProvider);
    ref.watch(getOnboardingStatusProvider.future).then((status) {
      if (mounted) {
        if (status.isOnboarded != true) {
          ref.read(startOnboardingProvider.notifier).startOnboarding();
        }
      }
    });
  }

  openFirstTimeBiometricsSheet() {
    final userData = ref.watch(userControllerProvider);
    if (SharedPrefManager.shownBiometricsSheet || userData.authStrategy != 'email') {
      return;
    }

    AppBottomSheet.showBottomSheet(
      context,
      widget: const EnableBiometricsSheet(),
    );

    SharedPrefManager.shownBiometricsSheet = true;
  }

  openRecruiterReviewSheet() {
    ref.invalidate(fetchPendingReviewsProvider);
    ref.watch(fetchPendingReviewsProvider.future).then((review) {
      if (review.isNotEmpty) {
        if (mounted) {
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
      }
    });
  }

  openFirstTimeCountrySheet() {
    if (SharedPrefManager.countryUpdatedAt.isNotEmpty) return;

    AppBottomSheet.showBottomSheet(
      context,
      widget: const SetCountrySheet(),
    );
  }

  setUserPresence() {
    ref.read(presenceProvider.notifier).setPresence(true);
  }

  void _initSequence() async {
    setUserPresence();

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

    openFirstTimeCountrySheet();
    openRecruiterReviewSheet();

    if (widget.showOnboardingSheet) {
      openOnboardingSheet();
    } else {
      openFirstTimeBiometricsSheet();
    }
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
    final hasUnreadNotifications = ref.watch(fetchNotificationsProvider).hasValue &&
        ((ref.watch(fetchNotificationsProvider).value?.unreadCount ?? 0) > 0);

    ref.listen(startOnboardingProvider, (_, value) {
      if (value is AsyncData) {
        AppBottomSheet.showBottomSheet(
          context,
          widget: const OnboardingSheet(),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      drawer: const HomeDrawer(),
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                      child: Row(
                        children: [
                          GuardedShowcase(
                            showcaseKey: TourKeys.homeDrawerMenu,
                            description: 'Tap here to access your profile, settings, and more.',
                            targetBorderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                              child: InitialAvatar(
                                initials: userData.getInitials,
                              ),
                            ),
                          ),
                          12.0.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello ${userData.name?.split(' ').first},',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.heading,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'What would you like to do today?',
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: AppColors.body,
                                ),
                              )
                            ],
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              context.push(const FavoritesView());
                            },
                            child: SvgPicture.asset(AppImages.favorite),
                          ),
                          16.0.width,
                          InkWell(
                            onTap: () {
                              context.push(const NotificationsView());
                            },
                            child: Stack(
                              alignment: AlignmentGeometry.topRight,
                              children: [
                                SvgPicture.asset(AppImages.bell),
                                if (hasUnreadNotifications) ...[
                                  Positioned(
                                    right: 2,
                                    child: SvgPicture.asset(
                                      width: 8,
                                      height: 8,
                                      AppImages.indicator,
                                      colorFilter: AppColors.highlightRed.colorFilterMode(),
                                    ),
                                  )
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    24.0.height,

                    // Talent Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: [
                          Expanded(
                            child: HomeActionCard(
                              onTap: () async {
                                final isCreator = userData.roles?.contains('creator') ?? false;
                                if (isCreator) {
                                  context.push(const MyCreatorProfileView());
                                  return;
                                }

                                final isRecruiter = userData.roles?.contains('recruiter') ?? false;
                                if (isRecruiter) {
                                  context.push(const MyRecruiterProfileView());
                                  return;
                                }

                                ref.invalidate(getOnboardingStatusProvider);
                                ref.watch(getOnboardingStatusProvider.future).then((status) {
                                  if (context.mounted) {
                                    if (status.isOnboarded != true) {
                                      ref.read(startOnboardingProvider.notifier).startOnboarding();
                                    } else {
                                      context.push(const MyCreatorProfileView());
                                    }
                                  }
                                });
                              },
                              title: 'View\nMy Profile',
                              subtitle: 'Upload and highlight\nyour best work',
                              bgColor: const Color(0xFFF4A261),
                              illustration: AppImages.bulb,
                              isLoading: ref.watch(getOnboardingStatusProvider).isLoading ||
                                  ref.watch(startOnboardingProvider).isLoading,
                            ),
                          ),
                          16.0.width,
                          Expanded(
                            child: HomeActionCard(
                              onTap: () {
                                ref.read(custom_nav.navBarController.notifier).index = 1;
                              },
                              title: 'Find\nTalent',
                              subtitle: 'Find top creators for\nyour project',
                              bgColor: const Color(0xFF3186E5),
                              illustration: AppImages.magnifier,
                            ),
                          ),
                        ],
                      ),
                    ),
                    24.0.height,

                    // Referral Card
                    if (userData.roles != null &&
                        !(userData.roles?.contains('ambassador') == true)) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: InkWell(
                          onTap: () {
                            context.push(const ReferralPageView());
                          },
                          child: Container(
                            width: double.infinity,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Image.asset(
                              AppImages.referralCard,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      24.0.height,
                    ],

                    // Activities Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Activities',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              final index = ref.read(custom_nav.navBarController);
                              if (index == 2 || index == 3) {
                                // Already in jobs or bookings
                              } else {
                                ref.read(custom_nav.navBarController.notifier).index = 3;
                              }
                            },
                            child: Text(
                              'View All',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.highlightCoral,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    16.0.height,
                  ],
                ),
              ),
            ];
          },
          body: const HomeActivitiesSection(),
        ),
      ),
    );
  }
}

class HomeActionCard extends StatelessWidget {
  final String title, subtitle, illustration;
  final Color bgColor;
  final VoidCallback onTap;
  final bool isLoading;

  const HomeActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.illustration,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 180, // Fixed height to match reference image aspect ratio
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Background Illustration
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.3, // Increased visibility
                child: SvgPicture.asset(
                  illustration,
                  width: 140,
                  height: 140,
                  // Removed colorFilter to show original illustration colors
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          illustration == AppImages.bulb ? AppImages.suitcase : AppImages.search,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          width: 16,
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  4.0.height,
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeActivitiesSection extends StatefulWidget {
  const HomeActivitiesSection({super.key});

  @override
  State<HomeActivitiesSection> createState() => _HomeActivitiesSectionState();
}

class _HomeActivitiesSectionState extends State<HomeActivitiesSection> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.zero,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.black,
              unselectedLabelColor: AppColors.body,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Jobs'),
                Tab(text: 'Bookings'),
              ],
            ),
          ),
        ),
        16.0.height,
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Jobs Tab: Show Marketplace Job cards as per Figma
              Consumer(
                builder: (context, ref, child) {
                  final jobState = ref.watch(jobControllerProvider);
                  if (jobState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (jobState.jobs.isEmpty) {
                    return const Center(child: Text('No jobs found'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: jobState.jobs.length,
                    separatorBuilder: (context, index) => 12.0.height,
                    itemBuilder: (context, index) {
                      final job = jobState.jobs[index];
                      return JobPostCard(
                        title: job.title ?? '',
                        description: job.description ?? '',
                        location: job.location ?? '',
                        price: job.price ?? 0,
                        currency: job.currency ?? 'NGN',
                        dateRange: job.expiresAt != null ? '${job.createdAt?.toFormattedDate()} - ${job.expiresAt?.toFormattedDate()}' : '',
                        status: '',
                        initialFavorite: job.isFavorited ?? false,
                        onFavoriteToggle: (val) {
                          ref.read(jobControllerProvider.notifier).toggleFavorite(job.id!);
                        },
                        onTap: () {
                          context.push(JobDetailView(job: job));
                        },
                      );
                    },
                  );
                },
              ),
              // Bookings Tab: Show original received booking cards as per Figma
              const ReceivedBookingsView(length: 3),
            ],
          ),
        ),
      ],
    );
  }
}
