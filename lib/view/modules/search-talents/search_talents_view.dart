import 'package:creatify_mobile/core/deeplinking/deeplink_provider.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/creator_card.dart';
import 'package:creatify_mobile/view/modules/home/notifications_view.dart';
import 'package:creatify_mobile/view/modules/home/search_preferences_sheet.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/search-talents/talent_filter_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/favorite_creators_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/filter_creators_vm.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  void _onSearchChanged() {
    setState(() {
      _searchQuery = searchController.text.toLowerCase();
    });
  }

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
    ref.read(hasSearchFiltersProvider.notifier).state = false;
    ref.read(filterCreatorsProvider.notifier).filterCreators();
    searchController.clear();
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
    final userData = ref.watch(userControllerProvider);
    final creators = ref.watch(filterCreatorsProvider);
    final recommendedCreators = ref.watch(getRecommendedCreatorsProvider);
    final hasUnreadNotifications = ref.watch(fetchNotificationsProvider).hasValue &&
        ((ref.watch(fetchNotificationsProvider).value?.unreadCount ?? 0) > 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'creatify',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(const NotificationsView()),
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none_outlined, color: Colors.black, size: 28),
                if (hasUnreadNotifications)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24, left: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: userData.profileImage != null
                  ? NetworkImage(userData.profileImage!)
                  : const AssetImage(AppImages.dummyAvatar) as ImageProvider,
            ),
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          clearFilters();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.0.height,
              Text(
                'Find & Book Talents',
                style: context.textTheme.displayMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B3131),
                ),
              ),
              Text(
                'Discover amazing creators for your next project',
                style: context.textTheme.bodyMedium?.copyWith(color: AppColors.body),
              ),
              24.0.height,

              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search name, skill, or keyword...',
                          hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: AppColors.body, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  12.0.width,
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: Colors.black, size: 20),
                  ),
                ],
              ),
              16.0.height,

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Role'),
                    8.0.width,
                    _buildFilterChip('Location'),
                    8.0.width,
                    _buildFilterChip('Budget'),
                    8.0.width,
                    _buildFilterChip('Rating'),
                    8.0.width,
                    _buildFilterChip('Availability'),
                  ],
                ),
              ),
              16.0.height,

              // Sort
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.swap_vert, size: 18, color: AppColors.body),
                  4.0.width,
                  Text(
                    'Sort: Relevance',
                    style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.body),
                ],
              ),
              16.0.height,

              // Creators count and Recommended badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  creators.maybeWhen(
                    data: (data) => Text(
                      '${data.length} creators',
                      style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    orElse: () => const Text('0 creators', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFF00BFA5), size: 14),
                        4.0.width,
                        const Text(
                          'Recommended',
                          style: TextStyle(
                            color: Color(0xFF00BFA5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              16.0.height,

              // Recommended horizontal list
              ref.watch(recommendedDismissedProvider)
                  ? const SizedBox.shrink()
                  : recommendedCreators.when(
                      data: (data) {
                        final list = data.data
                                ?.where((c) => c.categories?.isNotEmpty == true)
                                .toList() ??
                            [];
                        if (list.isEmpty) return const SizedBox.shrink();

                        return Column(
                          children: [
                            SizedBox(
                              height: 70,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: list.length,
                                separatorBuilder: (_, __) => 12.0.width,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: 230,
                                    child: RecommendedCreatorsCard(profile: list[index]),
                                  );
                                },
                              ),
                            ),
                            16.0.height,
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (e, s) => const SizedBox.shrink(),
                    ),

              // List of creators
              creators.when(
                data: (data) => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  separatorBuilder: (_, __) => 16.0.height,
                  itemBuilder: (context, index) {
                    final creator = data[index];
                    return CreatorsCard(
                      profile: creator,
                      isFavorite: creator.isFavorited ?? false,
                      onFavoriteToggle: () {
                        if (creator.isFavorited == true) {
                          ref.read(removeFromFavoriteCreatorsProvider.notifier).removeFromFavoriteCreators(creator.id ?? '');
                        } else {
                          ref.read(addToFavoriteCreatorsProvider.notifier).addToFavoriteCreators(creator.id ?? '');
                        }
                      },
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                error: (e, s) => Center(child: Text(e.toString())),
              ),
              40.0.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_getIconForFilter(label), size: 16, color: Colors.black87),
          6.0.width,
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.body),
        ],
      ),
    );
  }

  IconData _getIconForFilter(String label) {
    switch (label) {
      case 'Role': return Icons.person_outline;
      case 'Location': return Icons.location_on_outlined;
      case 'Budget': return Icons.account_balance_wallet_outlined;
      case 'Rating': return Icons.star_outline;
      case 'Availability': return Icons.calendar_today_outlined;
      default: return Icons.filter_list;
    }
  }
}
