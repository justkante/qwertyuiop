import 'package:creatify_mobile/core/deeplinking/deeplink_provider.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/creator_card.dart';
import 'package:creatify_mobile/view/modules/home/notifications_view.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/search-talents/talent_filter_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/my_creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/my_recruiter_profile_view.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/favorite_creators_vm.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/filter_creators_vm.dart' as filter_vm;
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final recommendedDismissedProvider = StateProvider<bool>((ref) => false);

class SearchTalentsView extends ConsumerStatefulWidget {
  const SearchTalentsView({super.key});

  @override
  ConsumerState<SearchTalentsView> createState() => _SearchTalentsViewState();
}

class _SearchTalentsViewState extends ConsumerState<SearchTalentsView> {
  final searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  String _searchQuery = '';

  void _onSearchChanged() {
    setState(() {
      _searchQuery = searchController.text.toLowerCase();
    });
  }

  void clearFilters() {
    ref.read(hasSearchFiltersProvider.notifier).state = false;
    ref.read(filter_vm.filterCreatorsProvider.notifier).filterCreators();
    searchController.clear();
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 300 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final creators = ref.watch(filter_vm.filterCreatorsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.extended(
              onPressed: _scrollToTop,
              backgroundColor: const Color(0xFF00796B),
              icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
              label: const Text('Back to top', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            )
          : null,
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
          GestureDetector(
            onTap: () {
               if (userData.roles?.contains('recruiter') == true) {
                 NavigationService.instance.push(const MyRecruiterProfileView());
               } else {
                 NavigationService.instance.push(const MyCreatorProfileView());
               }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 24, left: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: userData.profileImage != null
                    ? NetworkImage(userData.profileImage!)
                    : const AssetImage(AppImages.dummyAvatar) as ImageProvider,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          clearFilters();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.0.height,
              Center(
                child: Column(
                  children: [
                    Text(
                      'Find & Book Talents',
                      textAlign: TextAlign.center,
                      style: context.textTheme.displayMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B3131),
                      ),
                    ),
                    4.0.height,
                    Text(
                      'Discover amazing creators for your next project',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(color: AppColors.body, fontSize: 13),
                    ),
                  ],
                ),
              ),
              24.0.height,

              // Search Bar - Distinct light grey input field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: searchController,
                        onFieldSubmitted: (val) {
                           ref.read(filter_vm.filterCreatorsProvider.notifier).filterCreators(name: val);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search name, skill, or keyword...',
                          hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 13, color: AppColors.body),
                          prefixIcon: const Icon(Icons.search, color: AppColors.body, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                         AppBottomSheet.showBottomSheet(context, widget: const TalentFilterSheet());
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.tune, color: Colors.black, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              16.0.height,

              // Filter Chips - Wired to open sheet
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Role', () => AppBottomSheet.showBottomSheet(context, widget: const TalentFilterSheet())),
                    8.0.width,
                    _buildFilterChip('Location', () => AppBottomSheet.showBottomSheet(context, widget: const TalentFilterSheet())),
                    8.0.width,
                    _buildFilterChip('Budget', () => AppBottomSheet.showBottomSheet(context, widget: const TalentFilterSheet())),
                    8.0.width,
                    _buildFilterChip('Rating', () => AppBottomSheet.showBottomSheet(context, widget: const TalentFilterSheet())),
                    8.0.width,
                    _buildFilterChip('Availability', () => AppBottomSheet.showBottomSheet(context, widget: const TalentFilterSheet())),
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

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
