import 'package:creatify_mobile/core/deeplinking/deeplink_provider.dart';
import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/creator_card.dart';
import 'package:creatify_mobile/view/modules/home/notifications_view.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
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

class _SearchTalentsViewState extends ConsumerState<SearchTalentsView>
    with SingleTickerProviderStateMixin, RouteAware {
  final searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  bool _showBackToTop = false;
  bool _isRefreshing = false;
  double _dragDistance = 0;
  bool _appliedDefaultPreferences = false;

  String _searchQuery = '';

  void _triggerRefresh() {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
    });
    clearFilters();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = searchController.text.toLowerCase();
    });
  }

  void clearFilters() {
    ref.read(hasSearchFiltersProvider.notifier).state = false;
    ref.read(filter_vm.filterCreatorsProvider.notifier).filterCreators();
    searchController.clear();
    locationNotifier.value = null;
    minPriceNotifier.value = 1000;
    maxPriceNotifier.value = 10000000;
    categoriesNotifier.value = {};
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _resetSearch();
  }

  void _resetSearch() {
    if (mounted) {
      setState(() {
        searchController.clear();
        _searchQuery = '';
      });
      clearFilters();
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 100 && _showBackToTop) {
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
    routeObserver.unsubscribe(this);
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _scrollController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(navBarController, (previous, next) {
      if (next == 1 && previous != 1) {
        _resetSearch();
      }
    });

    final userData = ref.watch(userControllerProvider);
    final creators = ref.watch(filter_vm.filterCreatorsProvider);
    final preferencesAsync = ref.watch(fetchPreferencesProvider);

    if (!_appliedDefaultPreferences && preferencesAsync.hasValue && !ref.read(hasSearchFiltersProvider)) {
      final value = preferencesAsync.value;
      if (value != null && value is List && value.isNotEmpty) {
        _appliedDefaultPreferences = true;
        final List<String> categoryNames = (value as List)
            .map((p) => p?.name?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
        if (categoryNames.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              categoriesNotifier.value = Set<String>.from(categoryNames);
              ref.read(hasSearchFiltersProvider.notifier).state = true;
              ref.read(filter_vm.filterCreatorsProvider.notifier).filterCreators(
                category: categoryNames
                    .map((e) => e.removeSpace().removeSlash().toLowerCase())
                    .join('|'),
              );
            }
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _showBackToTop
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90), // Floating above bottom nav bar
              child: AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bounceAnimation.value),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: _scrollToTop,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.88),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: Color(0xFF00796B),
                      size: 28,
                    ),
                  ),
                ),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Find & Book Talents',
          style: context.textTheme.displayMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B3131),
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          _triggerRefresh();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              4.0.height,
              Center(
                child: Text(
                  'Discover amazing creators for your next project',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(color: AppColors.body, fontSize: 13),
                ),
              ),
              6.0.height,

              // Search Bar
              SearchTextInputField(
                controller: searchController,
                hintText: 'Search name, skill, or keyword...',
                onSubmitted: (val) {
                   ref.read(filter_vm.filterCreatorsProvider.notifier).filterCreators(name: val);
                },
                trailingIcon: InkWell(
                  onTap: () {
                     AppBottomSheet.showBottomSheet(context, widget: const TalentFilterSheet());
                  },
                  child: const Icon(Icons.tune, color: Colors.black, size: 20),
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
              _isRefreshing
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )
                  : creators.when(
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
                      loading: () => const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 80), child: CircularProgressIndicator.adaptive())),
                      error: (e, s) => Center(child: Text(e.toString())),
                    ),
              16.0.height,
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
