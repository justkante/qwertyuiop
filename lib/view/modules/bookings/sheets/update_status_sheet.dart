import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_dropdown.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/validator.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/input_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UpdateDeliverableStatusSheet extends StatefulWidget {
  final String? deliverable, status;
  const UpdateDeliverableStatusSheet({
    super.key,
    this.deliverable,
    this.status,
  });

  @override
  State<UpdateDeliverableStatusSheet> createState() => _UpdateDeliverableStatusSheetState();
}

class _UpdateDeliverableStatusSheetState extends State<UpdateDeliverableStatusSheet> {
  final GlobalKey<State> statusKey = GlobalKey();
  final statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    statusController.text = widget.status ?? '';
  }

  @override
  void dispose() {
    statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
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
          'Update Deliverable Status',
          style: context.textTheme.headlineSmall?.copyWith(fontSize: 19),
        ),
        6.0.height,
        Text(
          "Update the status of this deliverable. Once confirmed, the creator will be notified",
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),

        // Show the Deliverable if it's Deliverable Based
        if (widget.deliverable != null) ...[
          12.0.height,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Deliverable',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.subHeading,
                          decorationColor: AppColors.body,
                        ),
                      ),
                    ),
                  ],
                ),
                8.0.height,
                Text(
                  widget.deliverable ?? '',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.body,
                  ),
                )
              ],
            ),
          ),
        ],
        24.0.height,

        TextInputField(
          key: statusKey,
          readOnly: true,
          header: 'Select Status',
          controller: statusController,
          hint: 'Select Status',
          inputType: TextInputType.text,
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.body,
            size: 18,
          ),
          onPressed: () async {
            await platformSpecificDropdown(
              context: context,
              items: [
                if (widget.deliverable != null) ...[
                  "Pending",
                  "In Progress",
                ],
                'Completed',
              ],
              value: statusController.text,
              onChanged: (value) {
                setState(() {
                  statusController.text = value!;
                });
              },
              key: statusKey,
            );
          },
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
                  context.pop(false);
                },
              ),
            ),
            12.0.width,
            ValueListenableBuilder(
                valueListenable: statusController,
                builder: (context, _, __) {
                  final isValid =
                      statusController.text.isNotEmpty && statusController.text != widget.status;

                  return Expanded(
                    flex: 6,
                    child: MainButton(
                      text: 'Update Status',
                      onPressed: isValid
                          ? () {
                              context.pop(statusController.text);
                            }
                          : null,
                    ),
                  );
                })
          ],
        ),
        64.0.height,
      ],
    );
  }
}
