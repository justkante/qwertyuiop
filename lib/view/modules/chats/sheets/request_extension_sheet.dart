import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/request_extension_vm.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/transactions/widgets/transaction_line.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RequestExtensionSheet extends ConsumerStatefulWidget {
  final BookingItemDto booking;
  const RequestExtensionSheet({super.key, required this.booking});

  @override
  ConsumerState<RequestExtensionSheet> createState() => _RequestExtensionSheetState();
}

class _RequestExtensionSheetState extends ConsumerState<RequestExtensionSheet> {
  final GlobalKey<State> unitKey = GlobalKey();

  final TextEditingController durationController = TextEditingController();
  final TextEditingController unitController = TextEditingController();

  int availableDuration = 0;

  @override
  void initState() {
    super.initState();

    // If this is a time-based booking, extract numeric hours from
    // strings like '5hours' and prefill the duration field with
    // the remaining hours from a 24-hour day.
    if (widget.booking.bookingType == 'time-based') {
      final dur = widget.booking.duration ?? '';
      final match = RegExp(r"(\d+)").firstMatch(dur);
      if (match != null) {
        final current = int.tryParse(match.group(1) ?? '') ?? 0;
        final remaining = (24 - current) < 0 ? 0 : (24 - current);
        availableDuration = remaining;
      }
    }
  }

  @override
  void dispose() {
    durationController.dispose();
    unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestLoading = ref.watch(creatorRequestExtensionProvider).isLoading;
    final userData = ref.watch(userControllerProvider);

    ref.listen(creatorRequestExtensionProvider, (_, value) {
      if (value is AsyncData) {
        Navigator.of(context).pop();
        ToastDialog.showSuccess('Extension request has been sent to the Recruiter', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          16.0.height,

          SvgPicture.asset(
            AppImages.extend,
            width: 120,
            height: 120,
          ),
          16.0.height,
          Text(
            'Extend Duration?',
            style: context.textTheme.headlineSmall?.copyWith(fontSize: 19),
          ),
          12.0.height,
          Text(
            "Need more time? Propose a new end date and add a brief reason. The recruiter can approve or decline. No charges change automatically",
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          24.0.height,
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (var details in [
                  ('Start Date', widget.booking.startDate?.toBookingDateTime() ?? 'N/A'),
                  ('End Date', widget.booking.endDate?.toBookingDateTime() ?? 'N/A'),
                  ('Duration', widget.booking.duration ?? 'N/A')
                ])
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
                    child: TransactionLine(
                      title: details.$1,
                      value: details.$2,
                    ),
                  ),
                12.0.height,

                // Amount
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TransactionLine(
                    title: 'Amount',
                    valueColor: AppColors.primary,
                    value: num.tryParse(
                            widget.booking.finalPrice ?? widget.booking.offeredPrice ?? '0')
                        .amountWithCurrency(userData.primaryCurrency ?? ''),
                  ),
                ),
              ],
            ),
          ),
          12.0.height,

          // Duration
          TextInputField(
            header:
                'How many ${widget.booking.bookingType == 'time-based' ? 'hours' : 'days'} do you need?',
            controller: durationController,
            hint:
                'Enter the number of ${widget.booking.bookingType == 'time-based' ? 'hours' : 'days'}',
            inputType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty || int.parse(value) == 0) {
                return 'This field is required';
              } else if ((widget.booking.bookingType == 'time-based') &&
                  int.parse(value) > availableDuration) {
                return 'Extension cannot exceed $availableDuration hours in total';
              }
              return null;
            },
          ),
          32.0.height,

          // Buttons
          Row(
            children: [
              Expanded(
                flex: 3,
                child: MainButton(
                  color: AppColors.red50,
                  text: 'Back',
                  textColor: AppColors.btnText,
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
              16.0.width,
              Expanded(
                flex: 4,
                child: ValueListenableBuilder(
                  valueListenable: durationController,
                  builder: (context, _, __) {
                    final isValid = durationController.text.isNotEmpty &&
                        (widget.booking.bookingType == 'time-based'
                            ? int.parse(durationController.text) > 0 &&
                                int.parse(durationController.text) <= availableDuration
                            : int.parse(durationController.text) > 0);
                    return MainButton(
                      color: AppColors.highlightYellow,
                      text: 'Request Extension',
                      isLoading: requestLoading,
                      onPressed: isValid
                          ? () {
                              ref
                                  .read(creatorRequestExtensionProvider.notifier)
                                  .creatorRequestExtension(
                                    isTimeBased: widget.booking.bookingType == 'time-based',
                                    bookingId: widget.booking.id ?? '',
                                    durationDays: int.parse(durationController.text),
                                  );
                            }
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
          32.0.height,
        ],
      ),
    );
  }
}
