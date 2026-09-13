import 'package:creatify_mobile/data/models/requests/submit_review_req.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/submit_review_vm.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookingCompleteView extends ConsumerStatefulWidget {
  final String bookingId;
  const BookingCompleteView({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<BookingCompleteView> createState() => _BookingCompleteViewState();
}

class _BookingCompleteViewState extends ConsumerState<BookingCompleteView> {
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ratingController.text = '0';
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submittingReview = ref.watch(submitBookingReviewProvider).isLoading;

    ref.listen(submitBookingReviewProvider, (_, value) {
      if (value is AsyncData) {
        // Go to Home Screen
        NavigationService.instance.currentState?.popUntil((route) => route.isFirst);
        ref.read(navBarController.notifier).index = 2;

        ToastDialog.showSuccess('Review Submitted!', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });
    return AbsorbPointer(
      absorbing: submittingReview,
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    SvgPicture.asset(
                      AppImages.bookingConfettiSvg,
                      width: double.infinity,
                      height: 280.h,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 120.0),
                        child: SafeArea(
                          child: SvgPicture.asset(
                            AppImages.greenCheckMark,
                          ),
                        ).animate().scale(),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    "Booking Completed!",
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      color: AppColors.black2,
                    ),
                  ).animate().fadeIn(begin: 0, delay: 200.ms).slideY(begin: .1, end: 0),
                ),
                8.0.height,
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "This booking has been successfully marked as completed. Don't forget to leave feedback as this helps creators grow and helps other recruiters make better choices",
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
                32.0.height,

                // Rating Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Rate Creator',
                    textAlign: TextAlign.left,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.black2,
                    ),
                  ).animate().fadeIn(begin: 0, delay: 400.ms).slideY(begin: .1, end: 0),
                ),
                8.0.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    bool isSelected = int.parse(_ratingController.text) > index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _ratingController.text = (index + 1).toString();
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                        child: Container(
                          width: isSelected ? 48.w : 42.w,
                          height: isSelected ? 48.h : 42.h,
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
                ).animate().fadeIn(begin: 0, delay: 450.ms).slideY(begin: .1, end: 0),
                32.0.height,

                // Rating Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Creator Review',
                    textAlign: TextAlign.left,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.black2,
                    ),
                  ),
                ).animate().fadeIn(begin: 0, delay: 550.ms).slideY(begin: .1, end: 0),
                8.0.height,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextInputField(
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
                ).animate().fadeIn(begin: 0, delay: 600.ms).slideY(begin: .1, end: 0),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: ListenableBuilder(
                    listenable: Listenable.merge([
                      _reviewController,
                      _ratingController,
                    ]),
                    builder: (context, child) {
                      bool hasRating = int.parse(_ratingController.text) > 0;
                      bool hasReview = _reviewController.text.trim().isNotEmpty;
                      return MainButton(
                        text: (hasRating || hasReview) ? 'Submit' : 'Continue',
                        isLoading: submittingReview,
                        onPressed: () {
                          if (hasRating || hasReview) {
                            // Submit review and rating
                            if (!hasRating) {
                              // Submit rating
                              ToastDialog.showError('Please leave a rating also!', context);
                              return;
                            }

                            // Submit review
                            ref.read(submitBookingReviewProvider.notifier).submitBookingReview(
                                  widget.bookingId,
                                  SubmitReviewReq(
                                    rating: int.parse(_ratingController.text),
                                    review: _reviewController.text.trim(),
                                  ),
                                );
                          } else {
                            // Go to Home Screen
                            NavigationService.instance.currentState
                                ?.popUntil((route) => route.isFirst);

                            ref.read(navBarController.notifier).index = 2;
                          }
                        },
                      ).animate().fadeIn(begin: 0, delay: 800.ms).slideY(begin: .1, end: 0);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
