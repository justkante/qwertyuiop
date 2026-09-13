import 'package:creatify_mobile/data/models/requests/renegotiate_booking_req.dart';
import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
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
import 'package:creatify_mobile/view/widgets/number_input_field.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class DeliverableBasedRenegotiateBookingView extends ConsumerStatefulWidget {
  final String? bookingId, jobDescription, oldPrice, duration, currency;
  final DateTime? startDate;
  final List<BookingDeliverable>? deliverables;
  const DeliverableBasedRenegotiateBookingView({
    super.key,
    this.bookingId,
    this.jobDescription,
    this.oldPrice,
    this.duration,
    this.startDate,
    this.deliverables,
    this.currency,
  });

  @override
  ConsumerState<DeliverableBasedRenegotiateBookingView> createState() =>
      _RenegotiateBookingSheetState();
}

class _RenegotiateBookingSheetState extends ConsumerState<DeliverableBasedRenegotiateBookingView> {
  late final bool isDeliverableBased = widget.deliverables != null;

  final TextEditingController reasonController = TextEditingController();
  final TextEditingController totalPriceController = TextEditingController();

  // Controllers for each deliverable
  List<TextEditingController> deliverablePriceControllers = [];

  CancelNegotationsReasonsItemDto? selectedReason;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each deliverable
    if (isDeliverableBased && widget.deliverables != null) {
      for (var _ in widget.deliverables!) {
        final controller = TextEditingController();
        controller.addListener(_calculateTotal);
        deliverablePriceControllers.add(controller);
      }
      // Calculate initial total with old prices
      _calculateTotal();
    }
  }

  void _calculateTotal() {
    num total = 0;
    for (int i = 0; i < deliverablePriceControllers.length; i++) {
      final newPrice = num.tryParse(deliverablePriceControllers[i].text.removeCommas()) ?? 0;
      final oldPrice = num.tryParse(widget.deliverables?[i].price ?? '0') ?? 0;
      // Add new price if entered, otherwise add old price
      total += newPrice > 0 ? newPrice : oldPrice;
    }
    totalPriceController.text = total.toStringAsFixed(0);
    setState(() {});
  }

  @override
  void dispose() {
    reasonController.dispose();
    totalPriceController.dispose();
    for (var controller in deliverablePriceControllers) {
      controller.dispose();
    }
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Renegotiate Booking',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.subHeading,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              12.0.height,
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
              ).animate().fadeIn(begin: 0, delay: 100.ms).slideY(begin: .1, end: 0),
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
              ).animate().fadeIn(begin: 0, delay: 200.ms).slideY(begin: .1, end: 0),
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
              ).animate().fadeIn(begin: 0, delay: 300.ms).slideY(begin: .1, end: 0),
              16.0.height,
              if (isDeliverableBased) ...[
                // Deliverables List
                ...List.generate(
                  widget.deliverables?.length ?? 0,
                  (index) {
                    final deliverable = widget.deliverables![index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Deliverable ${index + 1}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.subHeading,
                                ),
                              ),
                              Text(
                                (num.tryParse(deliverable.price ?? '0') ?? 0)
                                    .amountWithCurrency(widget.currency ?? ''),
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          //8.0.height,
                          Text(
                            deliverable.description ?? '',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.body,
                            ),
                          ),
                          12.0.height,

                          NumberInputField(
                            header: "Enter New Price",
                            headerSize: 10,
                            controller: deliverablePriceControllers[index],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.subHeading,
                            ),
                            decoration: const InputDecoration(
                              fillColor: AppColors.grey50,
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: AppColors.body,
                                fontSize: 14,
                              ),
                              contentPadding: EdgeInsets.all(8),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                              LengthLimitingTextInputFormatter(17),
                              ThousandsFormatter(
                                allowFraction: true,
                                formatter: NumberFormat.decimalPattern(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(begin: 0, delay: (400 + (index * 100)).ms)
                        .slideY(begin: .1, end: 0);
                  },
                ),

                // Total Price
                12.0.height,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Total',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.subHeading,
                        ),
                      ),
                      Text(
                        (num.tryParse(totalPriceController.text.removeCommas()) ?? 0)
                            .amountWithCurrency(widget.currency ?? ''),
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.highlightGreen,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(begin: 0, delay: 600.ms).slideY(begin: .1, end: 0),
              ]
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListenableBuilder(
                listenable: Listenable.merge([
                  reasonController,
                  totalPriceController,
                  ...deliverablePriceControllers,
                ]),
                builder: (context, child) {
                  // Check if at least one deliverable has a new price
                  final hasAtLeastOneNewPrice = deliverablePriceControllers.any(
                    (controller) {
                      final value = num.tryParse(controller.text.removeCommas()) ?? 0;
                      return value > 0;
                    },
                  );

                  final isValid =
                      validateRequiredFields([reasonController.text]) && hasAtLeastOneNewPrice;
                  return MainButton(
                    text: 'Renegotiate',
                    isLoading: renegotiateBookingLoading,
                    color: AppColors.highlightBlue,
                    onPressed: isValid
                        ? () {
                            // Collect new prices for each deliverable (only non-zero values)
                            final newPrices = <NewDeliverablePrice>[];
                            for (int index = 0;
                                index < deliverablePriceControllers.length;
                                index++) {
                              final newPrice = num.tryParse(
                                      deliverablePriceControllers[index].text.removeCommas()) ??
                                  0;
                              if (newPrice > 0) {
                                newPrices.add(NewDeliverablePrice(
                                  deliverableId: widget.deliverables?[index].id,
                                  newPrice: newPrice,
                                ));
                              }
                            }

                            ref.read(renegotiateBookingProvider.notifier).renegotiateBooking(
                                  req: RenegotiateBookingReq(
                                    reasonId: selectedReason?.id ?? '',
                                    details: reasonController.text,
                                    newDeliverablePrices: newPrices,
                                  ),
                                  bookingId: widget.bookingId ?? '',
                                );
                          }
                        : null,
                  ).animate().fadeIn(begin: 0, delay: 700.ms).slideY(begin: .1, end: 0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
