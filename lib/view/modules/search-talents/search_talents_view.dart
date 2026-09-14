import 'package:creatify_mobile/core/deeplinking/deeplink_provider.dart';
import 'package:creatify_mobile/data/models/responses/creator_availabiity_dto.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/creator_card.dart';
import 'package:creatify_mobile/view/modules/home/search_preferences_sheet.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:creatify_mobile/view/modules/search-talents/talent_filter_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/favorite_creators_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/filter_creators_vm.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/core/services/tour_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/utils/tour/guarded_showcase.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';
import 'package:creatify_mobile/view/widgets/quick_icons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final recommendedDismissedProvider = StateProvider<bool>((ref) => false);

class SearchTalentsView extends ConsumerStatefulWidget {
  const SearchTalentsView({super.key});

  @override
  ConsumerState<SearchTalentsView> createState() => _SearchTalentsViewState();
}

class _SearchTalentsViewState extends ConsumerState<SearchTalentsView> {
  final searchController = TextEditingController();

  String _searchQuery = '';
  String creatorId = '';
  bool _hasShownPreferencesSheet = false;

  void _onSearchChanged() {
    setState(() {
      _searchQuery = searchController.text.toLowerCase();
    });
  }

  /// Finds the creator matching [profileId] in [creators] and opens their
  /// profile. Clears [pendingDeepLinkProvider] so this only fires once.
  ///
  /// The provider-value check at the top is the idempotency guard: both
  /// listeners may schedule this via addPostFrameCallback in the same frame;
  /// whichever runs first clears the provider, so the second call exits early.
  void _openCreatorFromDeepLink(List<CreatorProfileDto> creators, String profileId) {
    if (ref.read(pendingDeepLinkProvider) != profileId) return;

    ref.read(pendingDeepLinkProvider.notifier).state = null;

    final creator = creators.cast<CreatorProfileDto?>().firstWhere(
          (c) => c?.profileId == profileId,
          orElse: () => null,
        );

    if (creator == null || creator.id == null) return;

    NavigationService.instance.push(CreatorProfileView(profile: creator));
  }

  void clearFilters() {
    // Clear filters in the provider
    ref.read(hasSearchFiltersProvider.notifier).state = false;

    ref.read(filterCreatorsProvider.notifier).filterCreators();

    setState(() {
      // selectedCategories.clear();
      // amountRange = const RangeValues(minAmount, maxAmount);
      // locationController.clear();

      // // Reset to show only first 5 categories
      // showAllCategories = false;

      // Reset Values
      locationNotifier.value = StatesItemDto();
      minPriceNotifier.value = 1000;
      maxPriceNotifier.value = 1000000;
      categoriesNotifier.value = {};
    });
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creators = ref.watch(filterCreatorsProvider);
    final recommendedCreators = ref.watch(getRecommendedCreatorsProvider);
    final activeTabIndex = ref.watch(navBarController);
    bool hasFilters = ref.watch(hasSearchFiltersProvider);

    // Deep link: creators just finished loading — check for a pending profile ID.
    ref.listen(filterCreatorsProvider, (_, next) {
      final profileId = ref.read(pendingDeepLinkProvider);
      if (profileId == null) return;
      next.whenData((list) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openCreatorFromDeepLink(list, profileId);
        });
      });
    });

    // Deep link: profile ID just arrived — check if creators are already loaded.
    ref.listen(pendingDeepLinkProvider, (_, profileId) {
      if (profileId == null) return;
      creators.whenData((list) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openCreatorFromDeepLink(list, profileId);
        });
      });
    });

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

    if (!_hasShownPreferencesSheet &&
        activeTabIndex == 1 &&
        recommendedCreators.hasValue &&
        recommendedCreators.value?.meta != null &&
        recommendedCreators.value?.meta?.hasPreferences == false &&
        !TourService.shouldShowScreenTour(TourService.searchTab)) {
      _hasShownPreferencesSheet = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await AppBottomSheet.showBottomSheet(
          context,
          isDismissible: true,
          enableDrag: true,
          widget: const SearchPreferencesSheet(),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: GuardedShowcase(
          showcaseKey: TourKeys.discoverScreen,
          description: 'Discover and book talents from various categories based on their work.',
          targetBorderRadius: BorderRadius.circular(12),
          child: Text(
            'Find & Book Talents',
            style: context.textTheme.displayMedium?.copyWith(fontSize: 19),
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          clearFilters();
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // MARK: Search Bar & Filters
                    Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: GuardedShowcase(
                            showcaseKey: TourKeys.searchSearchBar,
                            description: 'Search directly by creator name, skill, or niche.',
                            targetBorderRadius: BorderRadius.circular(12),
                            child: SearchTextInputField(
                              controller: searchController,
                              onSubmitted: (value) {
                                ref
                                    .read(filterCreatorsProvider.notifier)
                                    .filterCreators(name: value);
                                searchController.clear();
                              },
                            ),
                          ),
                        ),
                        12.0.width,
                        Expanded(
                          flex: 1,
                          child: GuardedShowcase(
                            showcaseKey: TourKeys.searchFilterIcon,
                            description:
                                'Filter by skill, category, budget, or location to find the perfect creator.',
                            targetBorderRadius: BorderRadius.circular(12),
                            child: QuickIcon(
                              onTap: () async {
                                await AppBottomSheet.showBottomSheet(
                                  context,
                                  widget: const TalentFilterSheet(),
                                );
                              },
                              icon: AppImages.filter,
                              color: hasFilters ? Colors.white : AppColors.grey500,
                              size: 18,
                              padding: 8,
                              borderColor: AppColors.grey500,
                              bgColor: hasFilters ? AppColors.primary : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    16.0.height,

                    // MARK: Search Results
                    creators.when(
                      data: (data) {
                        final filterCreators = data
                            .where((creator) => creator.name!.toLowerCase().contains(_searchQuery))
                            .toList();

                        if (filterCreators.isEmpty) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              100.0.height,
                              SvgPicture.asset(
                                AppImages.magnifier,
                                height: 100,
                                width: 100,
                              ),
                              16.0.height,
                              Text(
                                hasFilters
                                    ? "No creators match your filters"
                                    : "You don't have any active searches yet",
                                style: context.textTheme.bodyMedium,
                              ),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Cards
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: categoriesNotifier.value
                                    .map(
                                      (e) => Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(32),
                                          border: Border.all(
                                            color: AppColors.grey300,
                                          ),
                                        ),
                                        child: Text(
                                          e,
                                          style: context.textTheme.bodySmall?.copyWith(
                                            fontSize: 10,
                                            color: AppColors.btnText,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            16.0.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${data.length} ${data.length > 1 ? 'Creators' : 'Creator'} ${hasFilters ? 'found' : ''}',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.subHeading,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (hasFilters) ...[
                                  InkWell(
                                    onTap: clearFilters,
                                    child: Text(
                                      'Clear Filters',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        color: AppColors.highlightCoral,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            16.0.height,
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filterCreators.length,
                              separatorBuilder: (context, index) => 12.0.height,
                              itemBuilder: (context, index) {
                                final creator = filterCreators[index];
                                return CreatorsCard(
                                  isFavorite: false,
                                  isLoading:
                                      (creator.id == creatorId) && (makeFavorite || removeFavorite),
                                  profile: creator,
                                  onFavoriteToggle: () {
                                    creatorId = creator.id ?? '';

                                    if (creator.isFavorited == true) {
                                      ref
                                          .read(removeFromFavoriteCreatorsProvider.notifier)
                                          .removeFromFavoriteCreators(creator.id ?? '');
                                    } else {
                                      ref
                                          .read(addToFavoriteCreatorsProvider.notifier)
                                          .addToFavoriteCreators(creator.id ?? '');
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                      error: (error, stackTrace) => Text('Error: $error'),
                      loading: () => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            64.0.height,
                            const CircularProgressIndicator.adaptive(
                              valueColor: AlwaysStoppedAnimation(AppColors.primary),
                            ),
                            8.0.height,
                            const Text('Loading Creators...'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // MARK: Recommended for you
            ref.watch(recommendedDismissedProvider)
                ? const SizedBox.shrink()
                : recommendedCreators.when(
                    data: (data) {
                      if (data.data?.isEmpty == true) return const SizedBox.shrink();

                      final recommendedCreators = data.data
                              ?.where((creator) => creator.categories?.isNotEmpty == true)
                              .toList() ??
                          [];

                      if (recommendedCreators.isEmpty) return const SizedBox.shrink();

                      return Container(
                        padding: const EdgeInsets.fromLTRB(21, 14, 0, 14),
                        decoration: const BoxDecoration(
                          color: AppColors.grey350,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 21),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recommended for You',
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: AppColors.subHeading,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      ref.read(recommendedDismissedProvider.notifier).state = true;
                                    },
                                    child: SvgPicture.asset(
                                      AppImages.cancel,
                                      colorFilter: AppColors.black.colorFilterMode(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            8.0.height,
                            SizedBox(
                              height: 70.h,
                              child: ListView.separated(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final creator = recommendedCreators[index];
                                  final isLastItem = index == (recommendedCreators.length - 1);

                                  return SizedBox(
                                    width: 230.w,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: isLastItem ? 21 : 0),
                                      child: RecommendedCreatorsCard(
                                        profile: creator,
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) => 10.0.width,
                                itemCount: recommendedCreators.length,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    error: (error, stackTrace) =>
                        kDebugMode ? Text('Error: $error') : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                  ),
          ],
        ),
      ),
    );
  }
}
