import 'package:creatify_mobile/view/modules/bookings/widgets/creator_card.dart';
import 'package:creatify_mobile/view/modules/jobs/vm/favorite_jobs_vm.dart';
import 'package:creatify_mobile/view/modules/jobs/widgets/job_post_card.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/favorite_creators_vm.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/app_segmented_control.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  ConsumerState<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends ConsumerState<FavoritesView> {
  final searchController = TextEditingController();
  int _selectedTabIndex = 0; // 0 for Profiles, 1 for Jobs
  String _searchQuery = '';

  void _onSearchChanged() {
    setState(() {
      _searchQuery = searchController.text.toLowerCase();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.heading),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Favourites',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.heading,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          16.0.height,
          AppSegmentedControl(
            segments: const ['Profiles', 'Jobs'],
            selectedIndex: _selectedTabIndex,
            onValueChanged: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
          ),
          24.0.height,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SearchTextInputField(
              controller: searchController,
              hintText: 'Search Name, Role...',
            ),
          ),
          24.0.height,
          Expanded(
            child: _selectedTabIndex == 0 ? _buildProfilesList() : _buildJobsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilesList() {
    final favoriteCreators = ref.watch(fetchFavoriteCreatorsProvider);
    final removeFavoriteLoading = ref.watch(removeFromFavoriteCreatorsProvider).isLoading;

    ref.listen(removeFromFavoriteCreatorsProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Removed from Favourites', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return favoriteCreators.when(
      data: (data) {
        final filteredFavorites = data
            .where((creator) =>
                (creator.name?.toLowerCase().contains(_searchQuery) ?? false) ||
                (creator.categories?.any((c) => c.name?.toLowerCase().contains(_searchQuery) ?? false) == true))
            .toList();

        if (filteredFavorites.isEmpty) {
          return _buildEmptyState('You have not added any profile to favorites');
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: filteredFavorites.length,
          separatorBuilder: (context, index) => 16.0.height,
          itemBuilder: (context, index) {
            final creator = filteredFavorites[index];
            return CreatorsCard(
              isFavorite: true,
              profile: creator,
              isLoading: removeFavoriteLoading,
              onFavoriteToggle: () {
                ref
                    .read(removeFromFavoriteCreatorsProvider.notifier)
                    .removeFromFavoriteCreators(creator.id ?? '');
              },
            );
          },
        );
      },
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Widget _buildJobsList() {
    final favoriteJobs = ref.watch(fetchFavoriteJobsProvider);
    final toggleFavoriteLoading = ref.watch(toggleFavoriteJobProvider).isLoading;

    ref.listen(toggleFavoriteJobProvider, (_, value) {
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return favoriteJobs.when(
      data: (data) {
        final filteredJobs = data
            .where((job) =>
                (job.title?.toLowerCase().contains(_searchQuery) ?? false) ||
                (job.description?.toLowerCase().contains(_searchQuery) ?? false))
            .toList();

        if (filteredJobs.isEmpty) {
          return _buildEmptyState('You have not added any job to favorites');
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: filteredJobs.length,
          separatorBuilder: (context, index) => 16.0.height,
          itemBuilder: (context, index) {
            final job = filteredJobs[index];
            return JobPostCard(
              title: job.title ?? '',
              description: job.description ?? '',
              location: job.location ?? '',
              price: job.price ?? 0,
              currency: job.currency ?? 'NGN',
              dateRange: '${job.createdAt?.toFormattedDate() ?? ''}',
              status: '', // We don't need status here
              initialFavorite: true,
              onTap: () {
                // Navigate to job details if needed
              },
              onFavoriteToggle: (isFav) {
                if (!isFav) {
                  ref.read(toggleFavoriteJobProvider.notifier).toggleFavorite(job.id ?? '');
                }
              },
            );
          },
        );
      },
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.highlightRed50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: AppColors.highlightRed,
              size: 48,
            ),
          ),
          24.0.height,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.body,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          60.0.height, // Space to push it slightly up from center
        ],
      ),
    );
  }
}
