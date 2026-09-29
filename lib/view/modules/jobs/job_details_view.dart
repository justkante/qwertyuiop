import 'package:creatify_mobile/data/models/responses/job_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/jobs/vm/job_controller.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/modules/bookings/fetched_recruiter_profile_view.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'apply_job_sheet.dart';

enum JobStatus { initial, viewed, accepted, rejected, closed }

class JobDetailView extends ConsumerStatefulWidget {
  final JobStatus status;
  final JobDto? job;
  const JobDetailView({super.key, this.status = JobStatus.initial, this.job});

  @override
  ConsumerState<JobDetailView> createState() => _JobDetailViewState();
}

class _JobDetailViewState extends ConsumerState<JobDetailView> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.job?.isFavorited ?? false;
  }

  Widget _buildPosterAvatar() {
    final img = widget.job?.user?.profileImage;
    final hasImg = img != null && img.trim().isNotEmpty && img.trim().startsWith('http');

    if (hasImg) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(img),
        backgroundColor: AppColors.grey100,
      );
    }

    final name = widget.job?.user?.name ?? widget.job?.title ?? 'Recruiter';
    final initials = name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('').toUpperCase();

    return InitialAvatar(
      initials: initials.isNotEmpty ? initials : 'R',
      padding: const EdgeInsets.all(24),
      size: 28,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = widget.job?.isExpired == true;
    final displayStatus = isExpired ? 'Inactive - Job Expired' : _getStatusText(widget.status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
        ),
        title: const Text('Job Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B3131))),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                _buildPosterAvatar(),
                12.0.height,
                Text(
                  widget.job?.user?.name ?? 'Recruiter',
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1B3131)),
                ),
                4.0.height,
                Text(
                  widget.job?.title ?? 'No Title',
                  style: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold, fontSize: 15),
                ),
                if (isExpired || widget.status != JobStatus.initial) ...[
                  8.0.height,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired ? const Color(0xFFFEE2E2) : _getStatusColor(widget.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: isExpired ? const Color(0xFFDC2626) : _getStatusColor(widget.status)),
                        6.0.width,
                        Text(displayStatus, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isExpired ? const Color(0xFFDC2626) : _getStatusColor(widget.status))),
                      ],
                    ),
                  ),
                ],
                24.0.height,

                // Description Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.grey100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Job Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B3131))),
                      8.0.height,
                      Text(
                        widget.job?.description ?? 'No description available',
                        style: context.textTheme.bodySmall?.copyWith(height: 1.5, color: AppColors.body, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                24.0.height,

                // Details Rows
                _buildDetailRow('Service', widget.job?.category?.name ?? 'Not Specified'),
                _buildDetailRow('Booking Type', widget.job?.type?.capitalize() ?? 'Not Specified'),
                _buildDetailRow('Work Mode', widget.job?.workMode ?? 'Not Specified'),
                if (widget.job?.startDate != null)
                  _buildDetailRow('Start Date', widget.job?.startDate ?? ''),
                if (widget.job?.startTime != null)
                  _buildDetailRow('Start Time', widget.job?.startTime ?? ''),
                if (widget.job?.duration != null)
                  _buildDetailRow('Duration', widget.job?.duration ?? ''),
                if (widget.job?.createdAt != null)
                  _buildDetailRow('Posted Date', widget.job!.createdAt!.toFormattedDate()),
                if (widget.job?.expiresAt != null)
                  _buildDetailRow('Expiry Date', widget.job!.expiresAt!.toFormattedDate()),
                _buildDetailRow('Location', widget.job?.location ?? 'Not Specified'),
                24.0.height,

                // Amount
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Budget / Amount', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.body)),
                      Text(
                        '${widget.job?.currency ?? 'NGN'} ${widget.job?.price?.amountInt() ?? '0.00'}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF00796B)),
                      ),
                    ],
                  ),
                ),
                24.0.height,
                const Divider(color: AppColors.grey100),
                24.0.height,

                // View Recruiter Profile Button
                Center(
                  child: MainButton(
                    text: 'View Recruiter Profile',
                    color: const Color(0xFF00796B),
                    textColor: Colors.white,
                    borderRadius: 24,
                    fontSize: 14,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    onPressed: () {
                      if (widget.job?.userId != null) {
                        NavigationService.instance.push(FetchedRecruiterProfileView(
                          creatorId: widget.job!.userId!,
                          creatorName: widget.job?.user?.name ?? 'Recruiter',
                        ));
                      }
                    },
                  ),
                ),
                120.0.height,
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context, isExpired),
          ),
          if (ref.watch(jobControllerProvider).isLoading)
            const Center(child: CircularProgressIndicator.adaptive()),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.body, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B3131))),
        ],
      ),
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.viewed: return Colors.blue;
      case JobStatus.accepted: return const Color(0xFF009688);
      case JobStatus.rejected: return Colors.red;
      case JobStatus.closed: return Colors.grey;
      default: return const Color(0xFF009688);
    }
  }

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.viewed: return 'Viewed';
      case JobStatus.accepted: return 'Accepted';
      case JobStatus.rejected: return 'Rejected';
      case JobStatus.closed: return 'Job Closed';
      default: return 'Active';
    }
  }

  Widget _buildBottomBar(BuildContext context, bool isExpired) {
    final currentUser = ref.watch(userControllerProvider);
    final isOwner = currentUser.id == widget.job?.userId;

    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.white.withOpacity(0.95),
      child: Row(
        children: [
          if (!isOwner) ...[
            GestureDetector(
              onTap: () async {
                if (widget.job?.id != null) {
                  await ref.read(jobControllerProvider.notifier).toggleFavorite(widget.job!.id!);
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grey100),
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_outline,
                  size: 20,
                  color: isFavorite ? Colors.red : AppColors.body,
                ),
              ),
            ),
            16.0.width,
          ],
          Expanded(
            child: isOwner
                ? (isExpired
                    ? OutlinedButton.icon(
                        onPressed: () async {
                          if (widget.job?.id != null) {
                            final error = await ref.read(jobControllerProvider.notifier).deleteJob(widget.job!.id!);
                            if (error == null && mounted) {
                              Navigator.pop(context);
                              ToastDialog.showSuccess('Job listing deleted', context);
                            } else if (mounted) {
                              ToastDialog.showError(error ?? 'Failed to delete job', context);
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        label: const Text('Delete Listing', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () async {
                          if (widget.job?.id != null) {
                            final error = await ref.read(jobControllerProvider.notifier).closeJob(widget.job!.id!);
                            if (error == null && mounted) {
                              Navigator.pop(context);
                              ToastDialog.showSuccess('Job closed successfully', context);
                            } else if (mounted) {
                              ToastDialog.showError(error ?? 'Failed to close job', context);
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF6F61)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text('Close Job', style: TextStyle(color: Color(0xFFFF6F61), fontWeight: FontWeight.bold, fontSize: 14)),
                      ))
                : MainButton(
                    text: isExpired ? 'Job Expired' : 'Apply Now',
                    borderRadius: 24,
                    fontSize: 14,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: isExpired ? Colors.grey : const Color(0xFF00796B),
                    onPressed: isExpired
                        ? null
                        : () {
                            if (widget.job != null) {
                              AppBottomSheet.showBottomSheet(
                                context,
                                widget: ApplyJobSheet(job: widget.job!),
                              );
                            }
                          },
                  ),
          ),
        ],
      ),
    );
  }
}
