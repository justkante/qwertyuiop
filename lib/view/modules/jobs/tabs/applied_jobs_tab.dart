import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../widgets/job_post_card.dart';
import '../job_details_view.dart';
import '../vm/job_controller.dart';
import 'package:creatify_mobile/view/modules/home/support_view.dart';

class AppliedJobsTab extends ConsumerStatefulWidget {
  const AppliedJobsTab({super.key});

  @override
  ConsumerState<AppliedJobsTab> createState() => _AppliedJobsTabState();
}

class _AppliedJobsTabState extends ConsumerState<AppliedJobsTab> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Pending', 'Reviewed', 'Shortlisted', 'Closed'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobControllerProvider.notifier).fetchAppliedJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(jobControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          16.0.height,
          // Horizontal Filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => 12.0.width,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => selectedFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey200),
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.body,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          24.0.height,

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search job, role...',
                  hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 13),
                  icon: const Icon(Icons.search, size: 20, color: AppColors.body),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          Expanded(
            child: jobState.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : jobState.jobs.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: jobState.jobs.length,
                        separatorBuilder: (_, __) => 16.0.height,
                        itemBuilder: (context, index) {
                          final job = jobState.jobs[index];
                          return JobPostCard(
                            title: job.title ?? '',
                            description: job.description ?? '',
                            location: job.location ?? '',
                            price: job.price ?? 0,
                            currency: job.currency ?? 'NGN',
                            dateRange: job.createdAt?.toFormattedDate() ?? '',
                            status: 'Sent', // From application
                            initialFavorite: job.isFavorited ?? false,
                            onTap: () => NavigationService.instance.push(JobDetailView(job: job, status: JobStatus.viewed)),
                          );
                        },
                      ),
          ),
          140.0.height, // Added padding for floating nav bar
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120), // Adjusted
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.tune, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          40.0.height,
          // Illustration Placeholder
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(color: Colors.teal.shade50.withOpacity(0.3), shape: BoxShape.circle),
                ),
                const Icon(Icons.search, size: 80, color: Color(0xFF00796B)),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                    child: const Icon(Icons.person_outline, size: 30, color: Color(0xFF00BFA5)),
                  ),
                ),
              ],
            ),
          ),
          24.0.height,
          const Text('No applications yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          8.0.height,
          const Text(
            'Jobs you apply for will appear here so you can track your progress and get updates.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.body, fontSize: 13, height: 1.5),
          ),
          32.0.height,
          MainButton(
            text: 'Explore Jobs  →',
            onPressed: () {}, // Navigate to Search tab
          ),
          16.0.height,
          TextButton(
            onPressed: () {},
            child: const Text('Set job alerts', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold)),
          ),
          32.0.height,
          // Tips Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FDFB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Color(0xFF00BFA5), size: 20),
                    8.0.width,
                    const Text('Tips to get hired', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                16.0.height,
                _buildTipItem('Complete your profile to stand out', 'A complete profile gets more attention.'),
                12.0.height,
                _buildTipItem('Apply early to new postings', 'Early applications have a higher chance of success.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, color: Color(0xFF00BFA5), size: 18),
        12.0.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(subtitle, style: const TextStyle(color: AppColors.body, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
