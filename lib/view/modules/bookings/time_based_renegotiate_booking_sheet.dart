import 'package:creatify_mobile/data/models/requests/renegotiate_booking_req.dart';
import 'package:creatify_mobile/data/models/responses/cancel_reasons_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/negotiation_reasons_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/renegotiate_booking_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/thousands_formatter.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class TimeBasedRenegotiateBookingSheet extends ConsumerStatefulWidget {
  final String? bookingId, jobDescription, oldPrice, duration, currency;
  final DateTime? startDate;
  const TimeBasedRenegotiateBookingSheet({
    super.key,
    this.bookingId,
    this.currency,
    this.jobDescription,
    this.oldPrice,
    this.duration,
    this.startDate,
  });

  @override
  ConsumerState<TimeBasedRenegotiateBookingSheet> createState() => _RenegotiateBookingSheetState();
}

class _RenegotiateBookingSheetState extends ConsumerState<TimeBasedRenegotiateBookingSheet> {
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController newPriceController = TextEditingController();

  CancelNegotationsReasonsItemDto? selectedReason;

  @override
  void dispose() {
    reasonController.dispose();
    newPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final renegotiateBookingLoading = ref.watch(renegotiateBookingProvider).isLoading;

    ref.listen(renegotiateBookingProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        ToastDialog.showSuccess(
          'You have Renegotiated the Price.'.toTitleCase(),
          context,
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });
    return AbsorbPointer(
      absorbing: renegotiateBookingLoading,
      child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              24.0.height,
              Text(
                'Renegotiate Booking',
                style: context.textTheme.displayMedium,
              ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
              18.0.height,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.jobDescription ?? '',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.body,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate().fadeIn(begin: 0, delay: 400.ms).slideY(begin: .1, end: 0),
              16.0.height,
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.highlightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var details in [
                          (
                            AppImages.moneyOutline,
                            num.tryParse(widget.oldPrice ?? '0')
                                .amountWithCurrency(widget.currency ?? '')
                          ),
                          (AppImages.watchOutline, widget.duration ?? ''),
                          (
                            AppImages.calendarOutline,
                            widget.startDate?.toFormattedDateWithYear() ?? ''
                          ),
                        ])
                          Row(
                            children: [
                              SvgPicture.asset(details.$1),
                              4.0.width,
                              Text(
                                details.$2,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: AppColors.grey100,
                                  fontFamily: FontFamily.inter,
                                ),
                              )
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(begin: 0, delay: 450.ms).slideY(begin: .1, end: 0),
              24.0.height,
              TextInputField(
                header: "Select Reason",
                controller: reasonController,
                hint: 'Select',
                readOnly: true,
                onPressed: () async {
                  selectedReason = await AppBottomSheet.showBottomSheet(
                    context,
                    widget: const NegotiationReasonsSheet(),
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
                header: "New Price",
                controller: newPriceController,
                hint: 'Enter New Price',
                inputType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  LengthLimitingTextInputFormatter(17),
                  ThousandsFormatter(
                    allowFraction: true,
                    formatter: NumberFormat.decimalPattern(),
                  ),
                ],
                validator: null,
              ).animate().fadeIn(begin: 0, delay: 550.ms).slideY(begin: .1, end: 0),
              const Spacer(),
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
                          newPriceController,
                        ]),
                        builder: (context, child) {
                          final isValid = validateRequiredFields(
                            [
                              reasonController.text,
                              if (reasonController.text == 'Other') newPriceController.text,
                            ],
                          );
                          return MainButton(
                            text: 'Renegotiate',
                            isLoading: renegotiateBookingLoading,
                            color: AppColors.highlightBlue,
                            onPressed: isValid
                                ? () {
                                    ref
                                        .read(renegotiateBookingProvider.notifier)
                                        .renegotiateBooking(
                                          req: RenegotiateBookingReq(
                                            reasonId: selectedReason?.id ?? '',
                                            newPrice: num.tryParse(
                                                newPriceController.text.replaceAll(',', '')),
                                            details: reasonController.text,
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
      ),
    );
  }
}
