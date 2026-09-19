import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../widgets/my_listing_job_card.dart';
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

    final activeCount = jobState.jobs.where((j) => j.status?.toLowerCase() == 'active').length;
    final draftCount = jobState.jobs.where((j) => j.status?.toLowerCase() == 'draft').length;
    final closedCount = jobState.jobs.where((j) => j.status?.toLowerCase() == 'closed').length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await ref.read(jobControllerProvider.notifier).fetchMyListings();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 150),
          child: Column(
            children: [
              16.0.height,
              // Status Row
              Row(
                children: [
                  _buildStatusCountCard('Active', activeCount, const Color(0xFFE0F2F1), const Color(0xFF00BFA5), Icons.assignment_outlined),
                  12.0.width,
                  _buildStatusCountCard('Draft', draftCount, const Color(0xFFE3F2FD), const Color(0xFF2196F3), Icons.description_outlined),
                  12.0.width,
                  _buildStatusCountCard('Closed', closedCount, AppColors.grey100, AppColors.subHeading, Icons.inventory_2_outlined),
                ],
              ),
              24.0.height,

              // Search and Post Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search listing title...',
                          hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 13),
                          icon: const Icon(Icons.search, size: 20, color: AppColors.body),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  12.0.width,
                  InkWell(
                    onTap: () => NavigationService.instance.push(const UploadJobView()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 20),
                          4.0.width,
                          const Text('Post Job', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              24.0.height,

              if (jobState.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (jobState.jobs.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(child: Text('No listings found')),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jobState.jobs.length,
                  separatorBuilder: (context, index) => 16.0.height,
                  itemBuilder: (context, index) {
                    final job = jobState.jobs[index];
                    return MyListingJobCard(
                      title: job.title ?? '',
                      location: job.location ?? 'Remote',
                      price: job.price ?? 0,
                      currency: job.currency ?? 'NGN',
                      description: job.description ?? '',
                      applicationCount: job.applicationsCount ?? 0,
                      postedDate: job.createdAt?.toFormattedDate() ?? '',
                      status: job.status ?? 'Active',
                      onTap: () => NavigationService.instance.push(JobDetailCreatorView(job: job)),
                      onViewApplicants: () => NavigationService.instance.push(JobDetailCreatorView(job: job)),
                      onEdit: () {
                        // TODO: Handle Edit
                      },
                      onDelete: () {
                        _showDeleteDialog(context, job.id!);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCountCard(String label, int count, Color bgColor, Color iconColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            12.0.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.body)),
                Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3131))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String jobId) {
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
              final error = await ref.read(jobControllerProvider.notifier).deleteJob(jobId);
              if (error == null) {
                if (context.mounted) ToastDialog.showSuccess('Job deleted successfully', context);
              } else {
                if (context.mounted) ToastDialog.showError(error, context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
