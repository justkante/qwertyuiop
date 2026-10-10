import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import '../widgets/job_post_card.dart';
import '../widgets/job_filter_sheet.dart';
import '../job_details_view.dart';
import '../vm/job_controller.dart';
import '../upload_job_view.dart';

class JobSearchTab extends ConsumerStatefulWidget {
  const JobSearchTab({super.key});

  @override
  ConsumerState<JobSearchTab> createState() => _JobSearchTabState();
}

class _JobSearchTabState extends ConsumerState<JobSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      setState(() {
        if (!_recentSearches.contains(trimmed)) {
          _recentSearches.insert(0, trimmed);
        }
      });
      ref.read(jobControllerProvider.notifier).fetchJobs(filters: {'search': trimmed});
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(jobControllerProvider);
    final hasActiveSearch = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar with integrated filter icon
            SearchTextInputField(
              controller: _searchController,
              hintText: 'Search Job, Role...',
              onSubmitted: _onSearch,
              trailingIcon: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const JobFilterSheet(),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.tune, color: Colors.black, size: 20),
                ),
              ),
            ),
            24.0.height,

            // Recent Searches (Only user's immediate typed searches)
            if (_recentSearches.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Search',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.body,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _recentSearches.clear();
                      });
                    },
                    child: const Text('Clear all', style: TextStyle(color: Color(0xFFFF6F61), fontSize: 10)),
                  ),
                ],
              ),
              Column(
                children: _recentSearches.map((search) => _buildRecentSearchItem(context, search)).toList(),
              ),
              16.0.height,
            ],

            // Section Header (Search Results vs Recommended Jobs)
            Text(
              hasActiveSearch
                  ? '${jobState.jobs.length} Search Result${jobState.jobs.length == 1 ? '' : 's'}'
                  : 'Recommended Jobs',
              style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.body),
            ),
            16.0.height,

            if (jobState.isLoading)
              const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: CircularProgressIndicator.adaptive()))
            else if (jobState.jobs.isEmpty)
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(color: Color(0xFFFFF1EF), shape: BoxShape.circle),
                      child: const Icon(Icons.search, size: 40, color: Color(0xFFFF6F61)),
                    ),
                    12.0.height,
                    Text(
                      hasActiveSearch ? 'No jobs match your search' : 'No jobs available right now',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.body, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                    status: job.effectiveStatus,
                    serviceName: job.category?.name,
                    initialFavorite: job.isFavorited ?? false,
                    onFavoriteToggle: (val) {
                      ref.read(jobControllerProvider.notifier).toggleFavorite(job.id!);
                    },
                    onTap: () {
                      NavigationService.instance.push(JobDetailView(job: job));
                    },
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: FloatingActionButton(
          onPressed: () {
            NavigationService.instance.push(const UploadJobView());
          },
          backgroundColor: const Color(0xFF009688),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _searchController.text = text;
                _onSearch(text);
              },
              child: Text(text, style: const TextStyle(color: AppColors.body, fontSize: 13)),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _recentSearches.remove(text);
              });
            },
            child: const Icon(Icons.close, size: 14, color: Color(0xFFFF6F61)),
          ),
        ],
      ),
    );
  }
}
