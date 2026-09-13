import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/utils/app_dialog.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../widgets/job_post_card.dart';
import '../job_details_view.dart';
import '../job_detail_creator_view.dart';
import '../vm/job_controller.dart';
import '../upload_job_view.dart';

class MyListingsTab extends ConsumerStatefulWidget {
  const MyListingsTab({super.key});

  @override
  ConsumerState<MyListingsTab> createState() => _MyListingsTabState();
}

class _MyListingsTabState extends ConsumerState<MyListingsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobControllerProvider.notifier).fetchMyListings();
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
              const Center(child: Text('No active listings found'))
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
                    dateRange: job.createdAt != null && job.expiresAt != null
                        ? '${job.createdAt!.toFormattedDate()} - ${job.expiresAt!.toFormattedDate()}'
                        : 'Active Listing',
                    status: job.status ?? '',
                    applicationCount: job.applicationsCount,
                    applicationAvatars: job.applications?.map((e) => e.user?.profileImage ?? '').where((e) => e.isNotEmpty).toList(),
                    onDelete: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Job'),
                          content: const Text('Are you sure you want to delete this job listing?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                final error = await ref.read(jobControllerProvider.notifier).deleteJob(job.id!);
                                if (error == null) {
                                  if (context.mounted) {
                                    ToastDialog.showSuccess('Job deleted successfully', context);
                                  }
                                } else {
                                  if (context.mounted) {
                                    ToastDialog.showError(error, context);
                                  }
                                }
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    onTap: () {
                      context.push(JobDetailCreatorView(job: job));
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
}
