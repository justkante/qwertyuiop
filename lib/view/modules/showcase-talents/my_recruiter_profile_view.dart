import 'dart:math';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/share_profile_widget.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/expandable_profile_image.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/image_preview.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/jobs/vm/job_controller.dart';
import 'package:creatify_mobile/view/modules/search-talents/talent_filter_sheet.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_dialog.dart';
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
import 'package:creatify_mobile/view/modules/home/edit_profile_view.dart';
import 'package:creatify_mobile/view/modules/bookings/fetched_recruiter_profile_view.dart';
import 'package:creatify_mobile/view/modules/home/support_view.dart';
import 'package:creatify_mobile/view/modules/home/favorites_view.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/requests/update_availability_req.dart';
import 'package:creatify_mobile/data/models/responses/recruiter_profile_dto.dart' hide RatingsAndReviews;
import 'package:creatify_mobile/view/modules/showcase-talents/vm/update_availability_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/update_profile_vm.dart';
import 'package:creatify_mobile/view/modules/home/vm/update_preferences_vm.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';

class MyRecruiterProfileView extends ConsumerStatefulWidget {
  const MyRecruiterProfileView({super.key});

  @override
  ConsumerState<MyRecruiterProfileView> createState() => _MyRecruiterProfileViewState();
}

class _MyRecruiterProfileViewState extends ConsumerState<MyRecruiterProfileView> with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool openingGallery = false;
  String selectedTimeframeValue = 'last_month';

  // Looking For Preferences state
  List<String> _creativeRoles = SharedPrefManager.recruiterCreativeRoles.isNotEmpty
      ? SharedPrefManager.recruiterCreativeRoles
      : ['Content Creators', 'Photographers', 'Videographers', 'Models', 'Stylists', 'Designers', 'Makeup Artists'];
  List<String> _typesOfProjects = SharedPrefManager.recruiterTypesOfProjects.isNotEmpty
      ? SharedPrefManager.recruiterTypesOfProjects
      : ['Brand Campaigns', 'Events', 'Social Media Content', 'Product Shoots', 'Editorial', 'UGC Content'];
  List<String> _workSetup = SharedPrefManager.recruiterWorkSetup.isNotEmpty
      ? SharedPrefManager.recruiterWorkSetup
      : ['On-site', 'Remote', 'Project-based', 'Long-term'];
  List<String> _locationPreferences = SharedPrefManager.recruiterLocationPreferences.isNotEmpty
      ? SharedPrefManager.recruiterLocationPreferences
      : ['Lagos, Nigeria', 'Other cities in Nigeria', 'Open to international talent'];

  String get selectedTimeframeDisplay {
    switch (selectedTimeframeValue) {
      case 'day':
        return 'Current day';
      case 'last_day':
        return 'Last day';
      case 'last_week':
        return 'Last week';
      case 'last_month':
        return 'Last 30 days';
      default:
        return 'Last 30 days';
    }
  }

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

  void _onShareProfile() {
    final userData = ref.read(userControllerProvider);
    final recruiterProfile = ref.read(fetchRecruiterProfileProvider((userData.id ?? '', selectedTimeframeValue))).value;

    AppDialog.showAppDialog(
      context,
      widget: ShareProfileWidget(
        profile: CreatorProfileDto(
          id: recruiterProfile?.id ?? userData.id,
          name: recruiterProfile?.name ?? userData.name,
          profileId: recruiterProfile?.id ?? userData.id,
          profileImage: recruiterProfile?.profileImage ?? userData.profileImage,
          ratingsAndReviews: RatingsAndReviews(
             averageRating: recruiterProfile?.ratingsAndReviews?.averageRating ?? 0.0,
             totalReviews: recruiterProfile?.ratingsAndReviews?.totalReviews ?? 0,
          ),
        ),
        self: true,
      ),
    );
  }

  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _editLookingFor(String sectionTitle) async {
    final prevCreativeRoles = List<String>.from(_creativeRoles);
    final prevTypesOfProjects = List<String>.from(_typesOfProjects);
    final prevWorkSetup = List<String>.from(_workSetup);
    final prevLocationPreferences = List<String>.from(_locationPreferences);

    categoriesNotifier.value = {};
    locationNotifier.value = null;
    workModeNotifier.value = null;

    final result = await AppBottomSheet.showBottomSheet(
      context,
      widget: const TalentFilterSheet(),
    );

    if (result != true) {
      if (mounted) {
        ToastDialog.showError('No changes were made to $sectionTitle', context);
      }
      return;
    }

    final List<String> updatedSections = [];

    // 1. Creative Roles & Types of Projects (Categories)
    if (categoriesNotifier.value.isNotEmpty) {
      final selectedCats = categoriesNotifier.value.toList();
      if (sectionTitle == 'Creative Roles') {
        _creativeRoles = selectedCats;
        if (!_areListsEqual(prevCreativeRoles, _creativeRoles)) {
          updatedSections.add('Creative Roles');
          ref.read(updatePreferencesProvider.notifier).updatePreferences(selectedCats);
        }
      } else if (sectionTitle == 'Types of Projects') {
        _typesOfProjects = selectedCats;
        if (!_areListsEqual(prevTypesOfProjects, _typesOfProjects)) {
          updatedSections.add('Types of Projects');
          ref.read(updatePreferencesProvider.notifier).updatePreferences(selectedCats);
        }
      } else {
        _creativeRoles = selectedCats;
        if (!_areListsEqual(prevCreativeRoles, _creativeRoles)) {
          updatedSections.add('Creative Roles');
          ref.read(updatePreferencesProvider.notifier).updatePreferences(selectedCats);
        }
      }
    }

    // 2. Work Setup
    if (workModeNotifier.value != null && workModeNotifier.value!.isNotEmpty) {
      final mode = workModeNotifier.value!.toTitleCase();
      _workSetup = [mode, ..._workSetup.where((e) => e != mode)];
      if (!_areListsEqual(prevWorkSetup, _workSetup) || sectionTitle == 'Work Setup') {
        if (!updatedSections.contains('Work Setup')) {
          updatedSections.add('Work Setup');
        }
        ref.read(updateAvailabilityProvider.notifier).updateAvailability(
          UpdateAvailabilityReq(workMode: mode.toLowerCase()),
        );
      }
    }

    // 3. Location Preferences
    if (locationNotifier.value?.name != null && locationNotifier.value!.name!.isNotEmpty) {
      final loc = locationNotifier.value!.name!;
      _locationPreferences = [loc, ..._locationPreferences.where((e) => e != loc)];
      if (!_areListsEqual(prevLocationPreferences, _locationPreferences) || sectionTitle == 'Location Preferences') {
        if (!updatedSections.contains('Location Preferences')) {
          updatedSections.add('Location Preferences');
        }
        ref.read(updateAvailabilityProvider.notifier).updateAvailability(
          UpdateAvailabilityReq(
            stateId: locationNotifier.value?.id ?? locationNotifier.value?.name,
          ),
        );
      }
    }

    setState(() {
      SharedPrefManager.recruiterCreativeRoles = _creativeRoles;
      SharedPrefManager.recruiterTypesOfProjects = _typesOfProjects;
      SharedPrefManager.recruiterWorkSetup = _workSetup;
      SharedPrefManager.recruiterLocationPreferences = _locationPreferences;
    });

    if (updatedSections.isNotEmpty) {
      ref.invalidate(fetchRecruiterProfileProvider);
      ref.invalidate(fetchPreferencesProvider);
      if (mounted) {
        ToastDialog.showSuccess('${updatedSections.join(", ")} updated and saved to server', context);
      }
    } else {
      if (mounted) {
        ToastDialog.showError('No changes were made to $sectionTitle', context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final myRecruiterProfile = ref.watch(fetchRecruiterProfileProvider((userData.id ?? '', selectedTimeframeValue)));

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
            IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.icons),
              onPressed: _onShareProfile,
            ),
          ],
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: () async {
            ref.invalidate(fetchRecruiterProfileProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                myRecruiterProfile.when(
                  data: (data) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // MARK: Centered Profile Picture
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              ExpandableProfileImage(
                                imageUrl: data.profileImage,
                                initials: data.initials,
                                size: 100,
                                initialsFallback: Center(child: InitialAvatar(initials: data.initials, size: 36, padding: const EdgeInsets.all(20))),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _onEditProfileImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)]),
                                    child: const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        4.0.height,

                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(userData.name ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                if (data.isPremium == true || (data.ratingsAndReviews?.averageRating != null && data.ratingsAndReviews!.averageRating! >= 4.5)) ...[
                                  4.0.width,
                                  const Icon(Icons.check_circle, color: Color(0xFF2196F3), size: 18),
                                ],
                              ],
                            ),
                            Text('Recruiter Profile', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                            8.0.height,
                            StarRating(rating: data.ratingsAndReviews?.averageRating ?? 0.0, starCount: 5, starSize: 16),
                            Text('${data.ratingsAndReviews?.averageRating ?? 0.0} (${data.ratingsAndReviews?.totalReviews ?? 0} reviews)', style: const TextStyle(color: AppColors.body, fontSize: 11)),
                          ],
                        ),
                        16.0.height,

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSmallInfoChip(Icons.location_on_outlined, 'Lagos, Nigeria'),
                            12.0.width,
                            _buildSmallInfoChip(Icons.business_center_outlined, 'Agency'),
                          ],
                        ),
                        24.0.height,
                        Row(
                          children: [
                            Expanded(child: MainButton(text: 'Edit Profile', color: const Color(0xFFE0F2F1), textColor: AppColors.primary, onPressed: () {
                               NavigationService.instance.push(const EditProfileView());
                            })),
                            12.0.width,
                            Expanded(child: MainButton(text: 'View Public', color: AppColors.grey50, textColor: const Color(0xFF1B3131), onPressed: () {
                               NavigationService.instance.push(FetchedRecruiterProfileView(creatorId: userData.id ?? '', creatorName: userData.name ?? ''));
                            })),
                          ],
                        ),
                        32.0.height,
                        _buildProfileTabs(),
                        24.0.height,
                        AnimatedBuilder(
                          animation: tabController,
                          builder: (context, _) {
                            if (tabController.index == 0) return _buildOverviewTab(data);
                            if (tabController.index == 1) return _buildLookingForTab(data);
                            return _buildActivityTab(data);
                          },
                        ),
                        180.0.height, // Scrolling Padding
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
        indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
        labelColor: Colors.black,
        unselectedLabelColor: AppColors.body,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Looking For'),
          Tab(text: 'Activity'),
        ],
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
            const Text('Recruiter Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            PopupMenuButton<String>(
              onSelected: (val) {
                 setState(() {
                    selectedTimeframeValue = val;
                 });
                 ref.invalidate(fetchRecruiterProfileProvider);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Text(selectedTimeframeDisplay, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.body)),
                    4.0.width,
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.body),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'day', child: Text('Current day')),
                const PopupMenuItem(value: 'last_day', child: Text('Last day')),
                const PopupMenuItem(value: 'last_week', child: Text('Last week')),
                const PopupMenuItem(value: 'last_month', child: Text('Last 30 days')),
              ],
            ),
          ],
        ),
        16.0.height,
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildMetricItem('Bookings', data.analytics?.totalBookings?.toString() ?? '0', Icons.shopping_bag_outlined, const Color(0xFFE3F2FD), const Color(0xFF2196F3)),
            _buildMetricItem('Repeat Rate', '${data.analytics?.repeatHireRate ?? 0}%', Icons.refresh_outlined, const Color(0xFFF3E5F5), const Color(0xFF7B1FA2)),
            _buildMetricItem('Resp. Time', '${data.analytics?.averageResponseTime ?? 0}h', Icons.bolt, const Color(0xFFE0F2F1), const Color(0xFF00897B)),
          ],
        ),
        32.0.height,
        const Text('Ratings & Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        16.0.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('${data.ratingsAndReviews?.averageRating ?? 0.0}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1B3131))),
                StarRating(rating: data.ratingsAndReviews?.averageRating ?? 0.0, starCount: 5, starSize: 14),
              ],
            ),
            40.0.width,
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
        24.0.height,
        _buildNoReviewsState(),
      ],
    );
  }

  Widget _buildLookingForTab(dynamic data) {
    final recruiterProfile = data is RecruiterProfileDto ? data : null;
    final preferencesAsync = ref.watch(fetchPreferencesProvider);
    final savedPrefNames = preferencesAsync.value?.map((p) => p.name ?? '').where((n) => n.isNotEmpty).toList() ?? [];

    final activeCreativeRoles = (recruiterProfile?.creativeRoles?.isNotEmpty == true)
        ? recruiterProfile!.creativeRoles!
        : (recruiterProfile?.categories?.isNotEmpty == true)
            ? recruiterProfile!.categories!.map((c) => c.name ?? '').where((n) => n.isNotEmpty).toList()
            : (savedPrefNames.isNotEmpty)
                ? savedPrefNames
                : _creativeRoles;

    final activeTypesOfProjects = (recruiterProfile?.typesOfProjects?.isNotEmpty == true)
        ? recruiterProfile!.typesOfProjects!
        : _typesOfProjects;

    final activeWorkSetup = (recruiterProfile?.workSetup?.isNotEmpty == true)
        ? recruiterProfile!.workSetup!
        : (recruiterProfile?.workMode != null && recruiterProfile!.workMode!.isNotEmpty)
            ? [recruiterProfile.workMode!.toTitleCase(), ..._workSetup.where((e) => e != recruiterProfile.workMode!.toTitleCase())]
            : _workSetup;

    final activeLocationPreferences = (recruiterProfile?.locationPreferences?.isNotEmpty == true)
        ? recruiterProfile!.locationPreferences!
        : (recruiterProfile?.location != null && recruiterProfile!.location!.isNotEmpty)
            ? [recruiterProfile.location!, ..._locationPreferences.where((e) => e != recruiterProfile.location!)]
            : _locationPreferences;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPreferenceCard(
          context,
          title: 'Creative Roles',
          subtitle: "Types of talent I'm looking to work with",
          items: activeCreativeRoles,
          icons: [Icons.videocam_outlined, Icons.camera_alt_outlined, Icons.video_camera_front_outlined, Icons.person_outline, Icons.checkroom, Icons.palette_outlined, Icons.brush_outlined],
          onEdit: () => _editLookingFor('Creative Roles'),
        ),
        16.0.height,
        _buildPreferenceCard(
          context,
          title: 'Types of Projects',
          subtitle: 'The kind of projects I usually work on',
          items: activeTypesOfProjects,
          icons: [Icons.campaign_outlined, Icons.event_outlined, Icons.phone_android_outlined, Icons.photo_camera_outlined, Icons.menu_book_outlined, Icons.video_library_outlined],
          onEdit: () => _editLookingFor('Types of Projects'),
        ),
        16.0.height,
        _buildPreferenceCard(
          context,
          title: 'Work Setup',
          subtitle: 'How I usually work',
          items: activeWorkSetup,
          icons: [Icons.location_on_outlined, Icons.wifi, Icons.work_outline, Icons.timer_outlined],
          onEdit: () => _editLookingFor('Work Setup'),
        ),
        16.0.height,
        _buildPreferenceCard(
          context,
          title: 'Location Preferences',
          subtitle: 'Where I prefer to work with talent',
          items: activeLocationPreferences,
          icons: [Icons.location_on_outlined, Icons.flag_outlined, Icons.public],
          onEdit: () => _editLookingFor('Location Preferences'),
        ),
      ],
    );
  }

  Widget _buildPreferenceCard(BuildContext context, {required String title, required String subtitle, required List<String> items, required List<IconData> icons, required VoidCallback onEdit}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131))),
                  2.0.height,
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.body)),
                ],
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.primary),
                label: const Text('Edit', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          12.0.height,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(items.length, (index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icons[index % icons.length], size: 14, color: AppColors.subHeading),
                    6.0.width,
                    Text(items[index], style: const TextStyle(fontSize: 12, color: Color(0xFF1B3131), fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab(dynamic data) {
    final favoritesAsync = ref.watch(fetchFavoriteCreatorsProvider);
    final bookingsAsync = ref.watch(fetchReceivedBookingsProvider);
    final jobState = ref.watch(jobControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Bookings
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Bookings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131))),
                  TextButton(
                    onPressed: () {
                      ref.read(navBarController.notifier).index = 3;
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('See all', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, fontSize: 13)),
                        Icon(Icons.chevron_right, color: Color(0xFF00BFA5), size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              8.0.height,
              bookingsAsync.when(
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return const Text('No recent bookings yet', style: TextStyle(color: AppColors.body, fontSize: 12));
                  }
                  return Column(
                    children: bookings.take(3).map((booking) {
                      final status = booking.status?.toString() ?? 'Completed';
                      final isCompleted = status.toLowerCase() == 'completed';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildBookingItem(
                          booking.creator?.name ?? 'Creator',
                          booking.jobDescription ?? 'Creative Service',
                          booking.createdAt != null ? booking.createdAt!.toLocal().toFormattedDateWithYear() : 'Recent',
                          booking.creator?.countryCode ?? 'Nigeria',
                          status.toTitleCase(),
                          isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD),
                          isCompleted ? const Color(0xFF2E7D32) : const Color(0xFF2196F3),
                          booking.creator?.profileImage,
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                error: (_, __) => const Text('Error loading bookings', style: TextStyle(color: AppColors.body, fontSize: 12)),
              ),
            ],
          ),
        ),
        16.0.height,

        // Recent Applications
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Applications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131))),
                  TextButton(
                    onPressed: () {
                      ref.read(jobTabIndexProvider.notifier).state = 0;
                      ref.read(navBarController.notifier).index = 2;
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('See all', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, fontSize: 13)),
                        Icon(Icons.chevron_right, color: Color(0xFF00BFA5), size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              8.0.height,
              if (jobState.applications.isEmpty)
                const Text('No recent applications yet', style: TextStyle(color: AppColors.body, fontSize: 12))
              else
                Column(
                  children: jobState.applications.take(3).map((app) {
                    final status = app.status ?? 'New';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildApplicationItem(
                        app.user?.name ?? 'Applicant',
                        app.job?.category?.name ?? 'Creative',
                        'Applied recently',
                        status.toTitleCase(),
                        const Color(0xFFFFF8E1),
                        const Color(0xFFF57C00),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        16.0.height,

        // Saved Creators
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saved Creators', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131))),
                  TextButton(
                    onPressed: () => NavigationService.instance.push(const FavoritesView()),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('See all', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, fontSize: 13)),
                        Icon(Icons.chevron_right, color: Color(0xFF00BFA5), size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              12.0.height,
              favoritesAsync.when(
                data: (favs) {
                  if (favs.isEmpty) {
                    return const Text('No saved creators yet', style: TextStyle(color: AppColors.body, fontSize: 12));
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...favs.take(5).map((creator) => Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundImage: creator.profileImage != null ? NetworkImage(creator.profileImage!) : AssetImage(AppImages.dummyAvatar) as ImageProvider,
                              ),
                              6.0.height,
                              Text(creator.name?.split(' ').first ?? 'Creator', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1B3131))),
                            ],
                          ),
                        )),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                error: (_, __) => const Text('Error loading saved creators', style: TextStyle(color: AppColors.body, fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingItem(String name, String role, String date, String location, String status, Color statusBg, Color statusFg, String? avatar) {
    return Row(
      children: [
        CircleAvatar(radius: 22, backgroundImage: avatar != null ? NetworkImage(avatar) : AssetImage(AppImages.dummyAvatar) as ImageProvider),
        12.0.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B3131))),
              2.0.height,
              Text(role, style: const TextStyle(fontSize: 11, color: AppColors.body)),
              2.0.height,
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 10, color: AppColors.body),
                  4.0.width,
                  Text(date, style: const TextStyle(fontSize: 10, color: AppColors.body)),
                  8.0.width,
                  const Icon(Icons.location_on_outlined, size: 10, color: AppColors.body),
                  2.0.width,
                  Text(location, style: const TextStyle(fontSize: 10, color: AppColors.body)),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
          child: Text(status, style: TextStyle(color: statusFg, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        8.0.width,
        const Icon(Icons.chevron_right, color: AppColors.body, size: 18),
      ],
    );
  }

  Widget _buildApplicationItem(String name, String role, String appliedDate, String status, Color statusBg, Color statusFg) {
    return Row(
      children: [
        const CircleAvatar(radius: 22, backgroundImage: AssetImage(AppImages.dummyAvatar)),
        12.0.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B3131))),
              2.0.height,
              Text(role, style: const TextStyle(fontSize: 11, color: AppColors.body)),
              2.0.height,
              Text(appliedDate, style: const TextStyle(fontSize: 10, color: AppColors.body)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
          child: Text(status, style: TextStyle(color: statusFg, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        8.0.width,
        const Icon(Icons.chevron_right, color: AppColors.body, size: 18),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: AppColors.grey100), borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 14)),
          4.0.height,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, maxLines: 1, style: const TextStyle(fontSize: 11, color: AppColors.body, fontWeight: FontWeight.w600)),
          ),
            FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, maxLines: 1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B3131))),
          ),
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
