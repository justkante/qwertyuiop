import 'package:creatify_mobile/view/modules/bookings/vm/mark_completed_vm.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RequestRevisionSheet extends ConsumerStatefulWidget {
  final String deliverableId;
  final String bookingId;
  const RequestRevisionSheet({
    super.key,
    required this.deliverableId,
    required this.bookingId,
  });

  @override
  ConsumerState<RequestRevisionSheet> createState() => _RequestRevisionSheetState();
}

class _RequestRevisionSheetState extends ConsumerState<RequestRevisionSheet> {
  final extensionReasonController = TextEditingController();

  @override
  void dispose() {
    extensionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestLoading = ref.watch(deliveryBasedMarkAsCompletedProvider).isLoading;

    // Listen to Marking Delivery Completed - Delivery Based
    ref.listen(deliveryBasedMarkAsCompletedProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();
        ToastDialog.showSuccess('Revision Request has been sent to the Creator', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: requestLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          12.0.height,
          SvgPicture.asset(
            AppImages.revision,
            width: 115,
            height: 80,
          ),
          16.0.height,

          // MARK: Title
          Text(
            'Request Revision',
            style: context.textTheme.headlineSmall?.copyWith(fontSize: 19),
          ),
          6.0.height,
          Text(
            "Are you sure you want to request a revision for this deliverable? Your request will be sent to the creator with your notes, and payment will pause until you approve",
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          24.0.height,

          TextInputField(
            header: 'Reason for Revision (Optional)',
            controller: extensionReasonController,
            inputType: TextInputType.multiline,
            maxLines: 4,
            hint: 'Enter Reason for Revision',
            validator: validateGeneric,
          ),
          32.0.height,

          Row(
            children: [
              Expanded(
                flex: 5,
                child: MainButton(
                  color: AppColors.highlightRed50,
                  text: 'Back',
                  textColor: AppColors.btnText,
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
              12.0.width,
              Expanded(
                flex: 6,
                child: MainButton(
                  text: 'Send Request',
                  isLoading: requestLoading,
                  onPressed: () {
                    ref
                        .read(deliveryBasedMarkAsCompletedProvider.notifier)
                        .markAsCompletedDeliveryBased(
                          bookingId: widget.bookingId,
                          deliverableId: widget.deliverableId,
                          action: 'request_revision',
                        );
                  },
                ),
              ),
            ],
          ),
          64.0.height,
        ],
      ),
    );
  }
}
