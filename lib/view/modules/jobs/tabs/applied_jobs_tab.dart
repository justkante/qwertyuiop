import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../widgets/job_post_card.dart';
import '../job_details_view.dart';
import '../vm/job_controller.dart';
import '../upload_job_view.dart';

class AppliedJobsTab extends ConsumerStatefulWidget {
  const AppliedJobsTab({super.key});

  @override
  ConsumerState<AppliedJobsTab> createState() => _AppliedJobsTabState();
}

class _AppliedJobsTabState extends ConsumerState<AppliedJobsTab> {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Internal Applied Filters
            SizedBox(
              height: 24,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildMiniFilter(context, 'All', true),
                ],
              ),
            ),
            16.0.height,
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Job, Role...',
                  hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 12),
                  icon: const Icon(Icons.search, size: 20, color: AppColors.body),
                  border: InputBorder.none,
                ),
              ),
            ),
            24.0.height,
            if (jobState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (jobState.jobs.isEmpty)
              const Center(child: Text('No applied jobs found'))
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
                    status: 'Sent', // This should come from application status
                    initialFavorite: job.isFavorited ?? false,
                    onFavoriteToggle: (val) {
                      ref.read(jobControllerProvider.notifier).toggleFavorite(job.id!);
                    },
                    onTap: () {
                      context.push(JobDetailView(
                        job: job,
                        status: JobStatus.viewed,
                      ));
                    },
                  );
                },
              ),
            100.0.height,
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          onPressed: () {
            context.push(const UploadJobView());
          },
          backgroundColor: const Color(0xFF009688),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMiniFilter(BuildContext context, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF009688).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF009688) : AppColors.grey100),
      ),
      child: Center(
        child: Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: isSelected ? const Color(0xFF009688) : AppColors.body,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
