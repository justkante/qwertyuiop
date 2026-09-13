import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/data/models/responses/job_application_dto.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/modules/bookings/fetched_creator_profile_view.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'vm/job_controller.dart';
import 'payment_success_view.dart';
import 'sheets/job_payment_confirmation_sheet.dart';

class ApplicantProfileView extends ConsumerWidget {
  final JobApplicationDto application;
  const ApplicantProfileView({super.key, required this.application});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              if (value == 'view_profile') {
                context.push(FetchedCreatorProfileView(
                  creatorId: application.userId ?? '',
                  creatorName: application.user?.name ?? '',
                ));
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'view_profile',
                child: Text('View applicant\'s profile', style: TextStyle(fontSize: 13)),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // User Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: application.user?.profileImage != null
                        ? NetworkImage(application.user!.profileImage!)
                        : AssetImage(AppImages.dummyAvatar) as ImageProvider,
                    radius: 35,
                  ),
                  12.0.height,
                  Text(
                    application.user?.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.heading),
                  ),
                  Text(
                    application.job?.category?.name ?? 'Creator',
                    style: const TextStyle(color: Color(0xFF3186E5), fontSize: 11, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            24.0.height,

            // Application (Pitch)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Application', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.body)),
            ),
            8.0.height,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.grey100)),
              child: Text(
                application.pitch ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.heading, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            24.0.height,

            // Portfolio Link
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Portfolio Link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.body)),
            ),
            8.0.height,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                application.portfolioLink ?? '',
                style: const TextStyle(color: Color(0xFF3186E5), fontSize: 11, decoration: TextDecoration.underline),
              ),
            ),
            24.0.height,

            // Attachments
            if (application.attachments?.isNotEmpty ?? false) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Attachment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.body)),
              ),
              8.0.height,
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: application.attachments!.length,
                  separatorBuilder: (context, index) => 8.0.width,
                  itemBuilder: (context, index) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(application.attachments![index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              24.0.height,
            ],

            // Ratings & Reviews
            if (application.user?.reviewsReceived?.isNotEmpty ?? false) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Rating & Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.heading)),
              ),
              16.0.height,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (application.user?.reviewsReceived?.isEmpty ?? true)
                            ? "0.0"
                            : (application.user!.reviewsReceived!.map((e) => e.rating ?? 0).reduce((a, b) => a + b) /
                                    application.user!.reviewsReceived!.length)
                                .toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: AppColors.heading)
                      ),
                      4.0.height,
                      Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.orange, size: 12))),
                      4.0.height,
                      Text('(${application.user?.reviewsReceived?.length ?? 0} reviews)', style: const TextStyle(color: AppColors.body, fontSize: 9)),
                    ],
                  ),
                  24.0.width,
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        int stars = 5 - index;
                        // For demo purposes matching screenshot visuals
                        double widthFactor = [0.8, 0.6, 0.4, 0.2, 0.1][index];
                        return _RatingBar(stars: stars, widthFactor: widthFactor, count: 200);
                      }),
                    ),
                  ),
                ],
              ),
              24.0.height,

              const Align(alignment: Alignment.centerLeft, child: Text('Most recent', style: TextStyle(color: AppColors.body, fontSize: 10, fontWeight: FontWeight.w400))),
              12.0.height,
              ...application.user!.reviewsReceived!.take(2).map((review) => _buildReviewItem(
                review.reviewer?.name ?? 'Reviewer',
                review.createdAt?.toFormattedDate() ?? '',
                review.comment ?? 'No comment provided',
              )).toList(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.grey100))),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(jobControllerProvider.notifier).respondToApplication(application.id!, 'rejected');
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1EF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Decline', style: TextStyle(color: Color(0xFFFF6F61), fontWeight: FontWeight.bold)),
              ),
            ),
            16.0.width,
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  AppBottomSheet.showBottomSheet(
                    context,
                    widget: JobPaymentConfirmationSheet(application: application),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009688),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        8.0.height,
        Text(content, style: context.textTheme.bodySmall?.copyWith(color: AppColors.body, height: 1.5)),
      ],
    );
  }

  Widget _buildReviewItem(String name, String date, String comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.heading)),
              Text(date, style: const TextStyle(color: AppColors.body, fontSize: 10, fontWeight: FontWeight.w400)),
            ],
          ),
          4.0.height,
          Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.orange, size: 10))),
          8.0.height,
          Text(comment, style: const TextStyle(color: AppColors.body, fontSize: 10, height: 1.6, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int stars, count;
  final double widthFactor;
  const _RatingBar({required this.stars, required this.count, this.widthFactor = 0.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w400, color: AppColors.body)),
          2.0.width,
          const Icon(Icons.star, size: 8, color: Colors.orange),
          8.0.width,
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(3)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widthFactor,
                child: Container(decoration: BoxDecoration(color: const Color(0xFFF4A261), borderRadius: BorderRadius.circular(3))),
              ),
            ),
          ),
          8.0.width,
          SizedBox(
            width: 30,
            child: Text('$count', style: const TextStyle(fontSize: 9, color: AppColors.body)),
          ),
        ],
      ),
    );
  }
}
