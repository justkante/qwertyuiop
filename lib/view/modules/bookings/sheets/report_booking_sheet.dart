import 'package:creatify_mobile/data/models/requests/booking_request_req.dart';
import 'package:creatify_mobile/data/models/responses/get_report_reasons_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/report_booking_reasons_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/report_booking_vm.dart';
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

class ReportBookingSheet extends ConsumerStatefulWidget {
  final String? userId, bookingId;
  const ReportBookingSheet({
    super.key,
    this.userId,
    this.bookingId,
  });

  @override
  ConsumerState<ReportBookingSheet> createState() => _ReportCreatorAccountSheetState();
}

class _ReportCreatorAccountSheetState extends ConsumerState<ReportBookingSheet> {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  ReportReasonsDto? selectedReason;

  @override
  void dispose() {
    reasonController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportBookingLoading = ref.watch(reportBookingProvider).isLoading;

    ref.listen(reportBookingProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        ToastDialog.showSuccess(
          'You have successfully reported this Booking.\nOur team will review it shortly and get back to you',
          context,
          seconds: 5,
          textAlign: TextAlign.center,
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: reportBookingLoading,
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
              child: SvgPicture.asset(AppImages.warningTriangleIllustration),
            ),
            24.0.height,
            Text(
              'Report Booking',
              style: context.textTheme.displayMedium,
            ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
            8.0.height,
            Text(
              "If you believe this booking has violated our community guidelines or engaged in inappropriate behaviour, you can report it here",
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ).animate().fadeIn(begin: 0, delay: 400.ms).slideY(begin: .1, end: 0),
            18.0.height,
            TextInputField(
              header: "Select Reason",
              controller: reasonController,
              hint: 'Select',
              readOnly: true,
              onPressed: () async {
                selectedReason = await AppBottomSheet.showBottomSheet(
                  context,
                  widget: const ReportBookingReasonsSheet(),
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
              header: "Details of Report ${reasonController.text == 'Other' ? '' : '(Optional)'}",
              controller: detailsController,
              maxLines: 4,
              hint: 'Enter Reason Here...',
              inputType: TextInputType.text,
              validator: null,
            ).animate().fadeIn(begin: 0, delay: 550.ms).slideY(begin: .1, end: 0),
            32.0.height,
            Center(
              child: RichText(
                text: TextSpan(
                  text: "Note: ",
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.kErrorColor,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'All reports are confidential. The reported user will not see who submitted the report.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(begin: 0, delay: 600.ms).slideY(begin: .1, end: 0),
            24.0.height,
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
                          text: 'Yes, Report',
                          isLoading: reportBookingLoading,
                          color: AppColors.highlightRed,
                          onPressed: isValid
                              ? () {
                                  ref.read(reportBookingProvider.notifier).reportBooking(
                                        ReportBookingReq(
                                          bookingId: widget.bookingId ?? '',
                                          reportedUserId: widget.userId ?? '',
                                          reportedReasonId: selectedReason?.id ?? '',
                                          details: detailsController.text.isEmpty
                                              ? reasonController.text
                                              : detailsController.text,
                                        ),
                                        reportedReason: selectedReason?.reason ?? '',
                                      );
                                }
                              : null,
                        ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0);
                      }),
                ),
              ],
            ),
            50.0.height,
          ],
        ),
      ),
    );
  }
}
