import 'package:creatify_mobile/data/models/responses/job_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: widget.job?.user?.profileImage != null
                      ? NetworkImage(widget.job!.user!.profileImage!)
                      : AssetImage(AppImages.dummyAvatar) as ImageProvider,
                ),
                12.0.height,
                Text(
                  widget.job?.user?.name ?? 'Unknown',
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.job?.title ?? 'No Title',
                  style: context.textTheme.bodySmall?.copyWith(color: AppColors.primary),
                ),
                if (widget.status != JobStatus.initial) ...[
                  8.0.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 8, color: _getStatusColor(widget.status)),
                      4.0.width,
                      Text(_getStatusText(widget.status), style: context.textTheme.bodySmall?.copyWith(fontSize: 10, color: AppColors.body)),
                    ],
                  ),
                ],
                24.0.height,
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.job?.description ?? 'No description available',
                    style: context.textTheme.bodySmall?.copyWith(height: 1.5, color: AppColors.body),
                    textAlign: TextAlign.center,
                  ),
                ),
                24.0.height,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Amount', style: context.textTheme.bodyMedium?.copyWith(color: AppColors.body)),
                    Text(
                        '${widget.job?.currency ?? 'NGN'} ${widget.job?.price?.amountInt() ?? '0.00'}',
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF009688))),
                  ],
                ),
                24.0.height,
                const Divider(color: AppColors.grey100),
                24.0.height,
                if (widget.job?.user?.reviewsReceived?.isNotEmpty ?? false) ...[
                  Row(
                    children: [
                      Text('Rating & Reviews', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  16.0.height,
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (widget.job?.user?.reviewsReceived?.map((e) => e.rating ?? 0).reduce((a, b) => a + b) ?? 0 / (widget.job?.user?.reviewsReceived?.length ?? 1)).toStringAsFixed(1),
                            style: context.textTheme.displayMedium?.copyWith(fontSize: 32, fontWeight: FontWeight.bold)
                          ),
                          Row(
                            children: List.generate(5, (index) => const Icon(Icons.star, size: 10, color: Colors.orange)),
                          ),
                          Text('(${widget.job?.user?.reviewsReceived?.length ?? 0} reviews)', style: context.textTheme.bodySmall?.copyWith(fontSize: 10, color: AppColors.body)),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                  24.0.height,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Most recent',
                      style: context.textTheme.bodySmall?.copyWith(color: AppColors.body, fontSize: 10),
                    ),
                  ),
                  12.0.height,
                  ...widget.job!.user!.reviewsReceived!.take(2).map((review) => Column(
                    children: [
                      _buildReviewItem(context, review.reviewer?.name ?? 'Anonymous', review.createdAt?.toFormattedDate() ?? '', review.comment ?? '', review.rating?.toInt() ?? 5),
                      const Divider(color: AppColors.grey100),
                    ],
                  )).toList(),
                ],
                24.0.height,
                Center(
                  child: MainButton(
                    text: 'View Recruiter profile',
                    color: const Color(0xFFACF4EE).withOpacity(0.3),
                    textColor: const Color(0xFF009688),
                    onPressed: () {
                      if (widget.job?.userId != null) {
                        NavigationService.instance.push(FetchedRecruiterProfileView(
                          creatorId: widget.job!.userId!,
                          creatorName: widget.job?.user?.name ?? '',
                        ));
                      }
                    },
                  ),
                ),
                120.0.height, // Space for bottom bar
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context),
          ),
          if (ref.watch(jobControllerProvider).isLoading)
            const Center(child: CircularProgressIndicator.adaptive()),
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, String name, String date, String comment, int rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(date, style: const TextStyle(color: AppColors.body, fontSize: 10)),
          ],
        ),
        4.0.height,
        Row(
          children: List.generate(5, (index) => Icon(Icons.star, size: 10, color: index < rating ? Colors.orange : Colors.grey[300])),
        ),
        8.0.height,
        Text(
          comment,
          style: context.textTheme.bodySmall?.copyWith(fontSize: 11, color: AppColors.body, height: 1.4),
        ),
        12.0.height,
      ],
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.viewed: return Colors.blue;
      case JobStatus.accepted: return const Color(0xFF009688);
      case JobStatus.rejected: return Colors.red;
      case JobStatus.closed: return Colors.grey;
      default: return Colors.transparent;
    }
  }

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.viewed: return 'Viewed';
      case JobStatus.accepted: return 'Accepted';
      case JobStatus.rejected: return 'Rejected';
      case JobStatus.closed: return 'Job Closed';
      default: return '';
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    if (widget.status == JobStatus.closed || widget.status == JobStatus.rejected) return const SizedBox.shrink();

    final currentUser = ref.watch(userControllerProvider);
    final isOwner = currentUser.id == widget.job?.userId;

    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.white.withOpacity(0.9),
      child: Row(
        children: [
          if (widget.status == JobStatus.initial || widget.status == JobStatus.accepted || isOwner)
            GestureDetector(
              onTap: () async {
                if (isOwner || widget.status == JobStatus.accepted) {
                  // Logic to close/delete the job if you're the owner
                  if (widget.job?.id != null) {
                    final error = await ref.read(jobControllerProvider.notifier).closeJob(widget.job!.id!);
                    if (error == null && mounted) {
                      Navigator.pop(context);
                      ToastDialog.showSuccess('Job closed successfully', context);
                    } else if (mounted) {
                      ToastDialog.showError(error ?? 'Failed to close job', context);
                    }
                  }
                } else if (widget.status == JobStatus.initial && widget.job?.id != null) {
                  await ref.read(jobControllerProvider.notifier).toggleFavorite(widget.job!.id!);
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isOwner || widget.status == JobStatus.accepted) ? const Color(0xFFFFF1EF) : AppColors.grey50,
                  shape: BoxShape.circle,
                  border: Border.all(color: ((isOwner || widget.status == JobStatus.accepted) ? const Color(0xFFFF6F61) : AppColors.grey100).withOpacity(0.2)),
                ),
                child: Icon(
                  (isOwner || widget.status == JobStatus.accepted) ? Icons.close : (isFavorite ? Icons.favorite : Icons.favorite_outline),
                  size: 20,
                  color: (isOwner || widget.status == JobStatus.accepted) ? const Color(0xFFFF6F61) : (isFavorite ? Colors.red : AppColors.body),
                ),
              ),
            ),
          if (widget.status == JobStatus.initial || widget.status == JobStatus.accepted || isOwner)
            16.0.width,
          Expanded(
            child: MainButton(
              text: isOwner
                  ? 'Close Job'
                  : (widget.status == JobStatus.accepted ? 'Chat ${widget.job?.user?.name?.split(' ').first ?? ''}' : 'Apply'),
              onPressed: () async {
                if (isOwner) {
                  if (widget.job?.id != null) {
                    final error = await ref.read(jobControllerProvider.notifier).closeJob(widget.job!.id!);
                    if (error == null && mounted) {
                      Navigator.pop(context);
                      ToastDialog.showSuccess('Job closed successfully', context);
                    } else if (mounted) {
                      ToastDialog.showError(error ?? 'Failed to close job', context);
                    }
                  }
                } else if (widget.status == JobStatus.initial) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => ApplyJobSheet(job: widget.job),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.body, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count) {
    return Row(
      children: [
        Text('$stars', style: const TextStyle(fontSize: 10)),
        2.0.width,
        const Icon(Icons.star, size: 8, color: Colors.orange),
        4.0.width,
        Container(
          width: 100,
          height: 4,
          decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(2)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.7,
            child: Container(decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2))),
          ),
        ),
        4.0.width,
        Text('$count', style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
