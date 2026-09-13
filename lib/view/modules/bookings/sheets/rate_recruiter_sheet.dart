import 'package:creatify_mobile/data/models/requests/submit_review_req.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/submit_review_vm.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RateRecruiterSheet extends ConsumerStatefulWidget {
  final String bookingId;
  final String recruiterName;
  final String jobDescription;

  const RateRecruiterSheet({
    super.key,
    required this.bookingId,
    required this.recruiterName,
    required this.jobDescription,
  });

  @override
  ConsumerState<RateRecruiterSheet> createState() => _RateRecruiterSheetState();
}

class _RateRecruiterSheetState extends ConsumerState<RateRecruiterSheet> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submittingReview = ref.watch(submitBookingReviewProvider).isLoading;

    ref.listen(submitBookingReviewProvider, (_, value) {
      if (value is AsyncData) {
        Navigator.pop(context);
        ToastDialog.showSuccess('Review Submitted!', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: submittingReview,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          20.0.height,

          // Title
          Center(
            child: Text(
              'How was your booking with ${widget.recruiterName}?',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.black2,
              ),
            ),
          ),
          8.0.height,
          Center(
            child: Text(
              'Your feedback helps recruiters improve and helps other creators make better choices.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.body,
              ),
            ),
          ),
          24.0.height,

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.jobDescription,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.body,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          12.0.height,

          // Rating
          Text(
            'Rate Recruiter',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.black2,
            ),
          ),
          8.0.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              bool isSelected = _rating > index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                  child: Container(
                    width: isSelected ? 42.w : 42.w,
                    height: isSelected ? 42.h : 42.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : AppColors.grey100,
                    ),
                    child: Center(
                      child: Icon(
                        isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isSelected ? AppColors.highlightYellow : AppColors.body,
                        size: isSelected ? 36 : 32,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          24.0.height,

          // Review
          Text(
            'Write a Review',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.black2,
            ),
          ),
          8.0.height,
          TextInputField(
            controller: _reviewController,
            inputType: TextInputType.text,
            hint: 'Write your review here',
            maxLines: 3,
            validator: (value) {
              if (value != null && value.length > 100) {
                return 'Review cannot be more than 100 characters';
              }
              return null;
            },
          ),
          24.0.height,

          // Submit
          MainButton(
            text: 'Submit Review',
            isLoading: submittingReview,
            onPressed:  () {
              if (_rating == 0) {
                ToastDialog.showError('Please leave a rating!', context);
                return;
              }

              ref.read(submitBookingReviewProvider.notifier).submitBookingReview(
                    widget.bookingId,
                    SubmitReviewReq(
                      rating: _rating,
                      review: _reviewController.text.trim(),
                    ),
                  );
            },
          ),
          12.0.height,

          // // Skip
          // Center(
          //   child: TextButton(
          //     onPressed: () => Navigator.pop(context),
          //     child: Text(
          //       'Skip',
          //       style: context.textTheme.bodyMedium?.copyWith(
          //         color: AppColors.body,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
