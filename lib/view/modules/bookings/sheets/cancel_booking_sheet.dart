import 'package:creatify_mobile/data/models/requests/cancel_booking_req.dart';
import 'package:creatify_mobile/data/models/responses/cancel_reasons_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/cancel_reasons_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/cancel_booking_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CancelBookingSheet extends ConsumerStatefulWidget {
  final String? bookingId;
  final bool before48Hours, isCreator;
  const CancelBookingSheet({
    super.key,
    this.bookingId,
    this.before48Hours = false,
    this.isCreator = false,
  });

  @override
  ConsumerState<CancelBookingSheet> createState() => _CancelBookingSheetState();
}

class _CancelBookingSheetState extends ConsumerState<CancelBookingSheet> {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  CancelNegotationsReasonsItemDto? selectedReason;

  @override
  void dispose() {
    reasonController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cancelBookingLoading = ref.watch(cancelBookingProvider).isLoading;

    ref.listen(cancelBookingProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        ToastDialog.showSuccess(
          'Your booking has been successfully cancelled.'.toTitleCase(),
          context,
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });
    return AbsorbPointer(
      absorbing: cancelBookingLoading,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            24.0.height,
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: AppColors.coral50,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(AppImages.calendarIllustration),
            ),
            24.0.height,
            Text(
              'Cancel Booking Request?',
              style: context.textTheme.displayMedium,
            ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
            8.0.height,
            Text(
              widget.before48Hours
                  ? widget.isCreator
                      ? "This booking is less than 48 hours away. Consecutive last-minute cancellations may affect your account standing and risk a suspension"
                      : "This booking is less than 48 hours away. Cancelling now will result in a 5% late cancellation fee. Platform and gateway fees are non-refundable"
                  : "Are you sure you want to cancel this request? Once cancelled, the creator will be notified and this booking will no longer be active",
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ).animate().fadeIn(begin: 0, delay: 400.ms).slideY(begin: .1, end: 0),
            24.0.height,
            TextInputField(
              header: "Select Reason",
              controller: reasonController,
              hint: 'Select',
              readOnly: true,
              onPressed: () async {
                selectedReason = await AppBottomSheet.showBottomSheet(
                  context,
                  widget: const CancelReasonsSheet(),
                );

                if (selectedReason != null) {
                  reasonController.text = selectedReason?.reason ?? '';
                  setState(() {});
                }
              },
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.body,
                size: 18,
              ),
              inputType: TextInputType.text,
              validator: null,
            ).animate().fadeIn(begin: 0, delay: 500.ms).slideY(begin: .1, end: 0),
            20.0.height,
            TextInputField(
              header:
                  "Details of Cancellation ${reasonController.text == 'Other' ? '' : '(Optional)'}",
              controller: detailsController,
              maxLines: 4,
              hint: 'Enter Details Here...',
              inputType: TextInputType.text,
              validator: null,
            ).animate().fadeIn(begin: 0, delay: 550.ms).slideY(begin: .1, end: 0),
            24.0.height,
            Text(
              "Refunds will be processed within 3–5 business days.\nFrequent last-minute cancellations may affect your account standing",
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ).animate().fadeIn(begin: 0, delay: 600.ms).slideY(begin: .1, end: 0),
            48.0.height,
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: MainButton(
                    text: 'Back',
                    textColor: AppColors.btnText,
                    color: AppColors.highlightRed50,
                    onPressed: () {
                      context.pop();
                    },
                  ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0),
                ),
                12.0.width,
                Expanded(
                  flex: 3,
                  child: ListenableBuilder(
                      listenable: Listenable.merge([
                        reasonController,
                        detailsController,
                      ]),
                      builder: (context, child) {
                        final isValid = validateRequiredFields(
                          [
                            reasonController.text,
                            if (reasonController.text == 'Other') detailsController.text,
                          ],
                        );
                        return MainButton(
                          text: 'Yes, Cancel Request',
                          isLoading: cancelBookingLoading,
                          color: AppColors.highlightRed,
                          onPressed: isValid
                              ? () {
                                  ref.read(cancelBookingProvider.notifier).cancelBooking(
                                        before48Hours: widget.before48Hours,
                                        req: CancelBookingReq(
                                          reasonId: selectedReason?.id ?? '',
                                          reason: reasonController.text,
                                          details: detailsController.text.isEmpty
                                              ? reasonController.text
                                              : detailsController.text,
                                        ),
                                        bookingId: widget.bookingId ?? '',
                                      );
                                }
                              : null,
                        ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0);
                      }),
                ),
              ],
            ),
            12.0.height,
          ],
        ),
      ),
    );
  }
}
