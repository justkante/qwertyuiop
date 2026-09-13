import 'package:creatify_mobile/data/models/responses/job_dto.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'vm/job_controller.dart';
import 'applicant_profile_view.dart';

class JobDetailCreatorView extends ConsumerStatefulWidget {
  final JobDto job;
  const JobDetailCreatorView({super.key, required this.job});

  @override
  ConsumerState<JobDetailCreatorView> createState() => _JobDetailCreatorViewState();
}

class _JobDetailCreatorViewState extends ConsumerState<JobDetailCreatorView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobControllerProvider.notifier).fetchApplications(widget.job.id!);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Job'),
                    content: const Text('Are you sure you want to delete this job listing?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close dialog
                          final error = await ref.read(jobControllerProvider.notifier).deleteJob(widget.job.id!);
                          if (error == null) {
                            if (mounted) {
                              Navigator.pop(context); // Go back to listings
                              ToastDialog.showSuccess('Job deleted successfully', context);
                            }
                          } else {
                            if (mounted) {
                              ToastDialog.showError(error, context);
                            }
                          }
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Job', style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Center(
            child: Column(
              children: [
                Text(
                  widget.job.title ?? '',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                4.0.height,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: _getStatusColor(widget.job.status ?? 'active'), shape: BoxShape.circle)),
                    6.0.width,
                    Text(widget.job.status?.capitalizeFirst ?? 'Active', style: context.textTheme.bodySmall?.copyWith(color: AppColors.body, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          24.0.height,

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(30)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                labelColor: Colors.black,
                unselectedLabelColor: AppColors.body,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: 'Job Description'), Tab(text: 'Applications')],
              ),
            ),
          ),
          16.0.height,

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescriptionTab(),
                _buildApplicationsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.grey100))),
        child: ElevatedButton(
          onPressed: () async {
            if (widget.job.id != null) {
              final error = await ref.read(jobControllerProvider.notifier).closeJob(widget.job.id!);
              if (error == null && mounted) {
                Navigator.pop(context);
                ToastDialog.showSuccess('Job closed successfully', context);
              } else if (mounted) {
                ToastDialog.showError(error ?? 'Failed to close job', context);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF009688),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('Close Job', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return const Color(0xFF009688);
      case 'closed': return Colors.grey;
      case 'pending': return const Color(0xFFF4A261);
      default: return Colors.transparent;
    }
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(12)),
            child: Text(
              widget.job.description ?? '',
              style: context.textTheme.bodySmall?.copyWith(color: AppColors.body, height: 1.5),
            ),
          ),
          24.0.height,
          _buildDetailRow('Service', widget.job.category?.name ?? 'Not Specified'),
          _buildDetailRow('Booking Type', widget.job.type?.capitalize() ?? 'Not Specified'),
          _buildDetailRow('Work Mode', widget.job.workMode ?? 'Not Specified'),
          if (widget.job.startDate != null)
            _buildDetailRow('Start Date', widget.job.startDate ?? ''),
          if (widget.job.startTime != null)
            _buildDetailRow('Start Time', widget.job.startTime ?? ''),
          if (widget.job.duration != null)
            _buildDetailRow('Duration', widget.job.duration ?? ''),
          if (widget.job.createdAt != null)
            _buildDetailRow('Posted Date', widget.job.createdAt!.toFormattedDate()),
          _buildDetailRow('Location', widget.job.location ?? 'Not Specified'),
          24.0.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amount', style: context.textTheme.bodyMedium?.copyWith(color: AppColors.body)),
              Text(
                widget.job.price?.amountWithCurrency(widget.job.currency ?? 'NGN') ?? 'NGN32,000',
                style: context.textTheme.titleMedium?.copyWith(color: const Color(0xFF009688), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsTab() {
    final jobState = ref.watch(jobControllerProvider);
    if (jobState.isLoading) return const Center(child: CircularProgressIndicator());
    if (jobState.applications.isEmpty) return const Center(child: Text('No applications yet'));

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: jobState.applications.length,
      separatorBuilder: (context, index) => 12.0.height,
      itemBuilder: (context, index) {
        final app = jobState.applications[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey100)),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundImage: NetworkImage(app.user?.profileImage ?? ''), radius: 24),
                  12.0.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        4.0.height,
                        Text('Request sent ${app.createdAt?.toFormattedDate() ?? ""}', style: const TextStyle(color: AppColors.body, fontSize: 10)),
                        4.0.height,
                        Row(
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFF4A261), shape: BoxShape.circle)),
                            4.0.width,
                            Text(app.status?.capitalizeFirst ?? 'Pending', style: const TextStyle(color: AppColors.body, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              12.0.height,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push(ApplicantProfileView(application: app)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4A261),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View Request', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodySmall?.copyWith(color: AppColors.body)),
          Text(value, style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
