import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/request_revision_sheet.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MarkDeliveryCompletedSheet extends StatefulWidget {
  final String bookingId;
  final List<BookingDeliverable> deliverables;
  const MarkDeliveryCompletedSheet({
    super.key,
    required this.bookingId,
    required this.deliverables,
  });

  @override
  State<MarkDeliveryCompletedSheet> createState() => _MarkDeliveryCompletedSheetState();
}

class _MarkDeliveryCompletedSheetState extends State<MarkDeliveryCompletedSheet> {
  BookingDeliverable? selectedDeliverable;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  12.0.height,
                  SvgPicture.asset(
                    AppImages.markCompleted,
                    width: 115,
                    height: 80,
                  ),
                  16.0.height,

                  // MARK: Title
                  Text(
                    'Choose Deliverable',
                    style: context.textTheme.headlineSmall?.copyWith(fontSize: 19),
                  ),
                  6.0.height,
                  Text(
                    "Review submitted deliverables. Approve to release payment, request revision with notes, or raise a dispute if something’s off",
                    style: context.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  20.0.height,

                  // Deliverables List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.deliverables.length,
                    separatorBuilder: (context, index) => 12.0.height,
                    itemBuilder: (context, index) {
                      final deliverable = widget.deliverables[index];
                      return InkWell(
                        onTap: (deliverable.isCompleted != true)
                            ? () {
                                if ((deliverable.status == 'completed')) {
                                  setState(() {
                                    selectedDeliverable = deliverable;
                                  });
                                } else {
                                  ToastDialog.showError(
                                      'Creator has not completed this deliverable yet', context);
                                  return;
                                }
                              }
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: deliverable.isCompleted == true
                                ? AppColors.grey50
                                : AppColors.grey200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedDeliverable == deliverable
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Deliverable',
                                      style: context.textTheme.bodySmall?.copyWith(
                                        color: deliverable.isCompleted == true
                                            ? AppColors.body
                                            : AppColors.subHeading,
                                        decoration: deliverable.isCompleted == true
                                            ? TextDecoration.lineThrough
                                            : null,
                                        decorationColor: AppColors.body,
                                      ),
                                    ),
                                  ),
                                  if ((deliverable.isCompleted != true) &&
                                      deliverable.status == 'completed') ...[
                                    3.0.width,
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.highlightCoral,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Creator Marked Completed',
                                        style: context.textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              8.0.height,
                              Text(
                                deliverable.description ?? '',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: deliverable.isCompleted == true
                                      ? AppColors.body.withOpacity(0.5)
                                      : AppColors.body,
                                  decoration: deliverable.isCompleted == true
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: AppColors.body.withOpacity(0.5),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: MainButton(
                  color: AppColors.btnTertiary,
                  text: 'Request Revision',
                  textColor: AppColors.btnText,
                  onPressed: () {
                    if (selectedDeliverable != null) {
                      context.pop();

                      AppBottomSheet.showBottomSheet(
                        context,
                        widget: RequestRevisionSheet(
                          bookingId: widget.bookingId,
                          deliverableId: selectedDeliverable?.id ?? '',
                        ),
                      );
                    } else {
                      ToastDialog.showError('Select a Deliverable', context);
                    }
                  },
                ),
              ),
              12.0.width,
              Expanded(
                child: MainButton(
                  text: 'Mark Selected',
                  onPressed: () {
                    if (selectedDeliverable != null) {
                      context.pop(selectedDeliverable!.id);
                    } else {
                      ToastDialog.showError('Select a Deliverable', context);
                    }
                  },
                ),
              ),
            ],
          ),
          18.0.height,
        ],
      ),
    );
  }
}
