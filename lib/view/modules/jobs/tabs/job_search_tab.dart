import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(jobControllerProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (val) {
                        if (val.isNotEmpty) {
                          ref.read(jobControllerProvider.notifier).addSearch(val);
                          ref.read(jobControllerProvider.notifier).fetchJobs(filters: {'search': val});
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Job, Role...',
                        hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 12),
                        icon: const Icon(Icons.search, size: 20, color: AppColors.body),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                12.0.width,
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => const JobFilterSheet(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF009688),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.tune, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            24.0.height,

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: jobState.jobs.isNotEmpty
                  ? jobState.jobs.take(5).map((job) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterTag(job.category?.name ?? ''),
                    )).toList()
                  : [],
              ),
            ),
            16.0.height,

            Text(
              '${jobState.jobs.length} Search Result',
              style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.body),
            ),
            16.0.height,

            if (jobState.recentSearches.isNotEmpty) ...[
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
                      ref.read(jobControllerProvider.notifier).clearSearches();
                    },
                    child: const Text('Clear all', style: TextStyle(color: Color(0xFFFF6F61), fontSize: 10)),
                  ),
                ],
              ),
              Column(
                children: jobState.recentSearches.map((search) => _buildRecentSearchItem(context, search.query ?? '', search.id ?? '')).toList(),
              ),
              16.0.height,
            ],

            if (jobState.recentSearches.isEmpty && jobState.jobs.isEmpty && !jobState.isLoading)
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(color: Color(0xFFFFF1EF), shape: BoxShape.circle),
                      child: const Icon(Icons.search, size: 40, color: Color(0xFFFF6F61)),
                    ),
                    12.0.height,
                    Text('You don\'t have any active searches\nyet', textAlign: TextAlign.center, style: TextStyle(color: AppColors.body, fontSize: 12)),
                  ],
                ),
              ),

            if (jobState.jobs.isNotEmpty) ...[
              Text(
                'Recommended for you',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.body,
                ),
              ),
              16.0.height,
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
                    status: job.status ?? '',
                    serviceName: job.category?.name, // Added
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
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120), // Adjusted to be above nav bar
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

  Widget _buildRecentSearchItem(BuildContext context, String text, String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: AppColors.body, fontSize: 13)),
          InkWell(
            onTap: () {
              ref.read(jobControllerProvider.notifier).removeSearch(id);
            },
            child: const Icon(Icons.close, size: 14, color: Color(0xFFFF6F61)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 10, color: AppColors.body),
          ),
          4.0.width,
          const Icon(Icons.close, size: 12, color: Colors.red),
        ],
      ),
    );
  }
}
