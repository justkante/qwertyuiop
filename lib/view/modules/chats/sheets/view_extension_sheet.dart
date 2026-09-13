import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/request_extension_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/widgets/transaction_line.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/linear_loading.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ViewExtensionSheet extends ConsumerStatefulWidget {
  final BookingItemDto booking;
  final bool isLastRequest, isCreator;
  const ViewExtensionSheet({
    super.key,
    required this.booking,
    this.isLastRequest = false,
    this.isCreator = false,
  });

  @override
  ConsumerState<ViewExtensionSheet> createState() => _ViewExtensionSheetState();
}

class _ViewExtensionSheetState extends ConsumerState<ViewExtensionSheet> {
  final GlobalKey<State> unitKey = GlobalKey();

  final TextEditingController durationController = TextEditingController();
  final TextEditingController unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    durationController.text = widget.booking.bookingType == 'time-based'
        ? widget.booking.extensionRequests?.last.newEndTime?.toBookingDateTime() ?? ''
        : widget.booking.extensionRequests?.last.newEndDate?.toBookingDateTime() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final responseLoading = ref.watch(recruiterRespondExtensionProvider).isLoading;

    ref.listen(recruiterRespondExtensionProvider, (_, value) {
      if (value is AsyncData) {
        Navigator.of(context).pop();
        ToastDialog.showSuccess('Your response has been sent to the Creator', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: responseLoading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Extension Request',
            style: context.textTheme.headlineSmall?.copyWith(fontSize: 19),
          ),

          if (responseLoading) ...[
            16.0.height,
            const LineLoadingIndicator(loading: true),
          ],

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
                        .amountWithCurrency(widget.booking.currency ?? ''),
                  ),
                ),
              ],
            ),
          ),
          12.0.height,

          // Duration
          TextInputField(
            header: 'New End Date',
            controller: durationController,
            hint: 'How many days',
            readOnly: true,
            inputType: TextInputType.text,
            validator: validateGeneric,
          ),
          32.0.height,

          // Buttons
          if ((widget.isLastRequest &&
                  widget.booking.extensionRequests?.last.status == 'pending') &&
              !widget.isCreator) ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: MainButton(
                    color: AppColors.red50,
                    text: 'Reject',
                    textColor: AppColors.btnText,
                    onPressed: () {
                      ref
                          .read(recruiterRespondExtensionProvider.notifier)
                          .recruiterRespondExtension(
                            extensionId: widget.booking.extensionRequests!.last.id ?? 'extensionId',
                            isAccepted: false,
                          );
                    },
                  ),
                ),
                16.0.width,
                Expanded(
                  flex: 4,
                  child: MainButton(
                    text: 'Accept',
                    onPressed: () {
                      ref
                          .read(recruiterRespondExtensionProvider.notifier)
                          .recruiterRespondExtension(
                            extensionId: widget.booking.extensionRequests!.last.id ?? 'extensionId',
                            isAccepted: true,
                          );
                    },
                  ),
                ),
              ],
            ),
          ],

          32.0.height,
        ],
      ),
    );
  }
}
