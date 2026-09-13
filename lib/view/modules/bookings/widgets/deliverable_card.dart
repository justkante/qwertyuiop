import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/utils/thousands_formatter.dart';
import 'package:creatify_mobile/view/widgets/number_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DevlierableCard extends StatefulWidget {
  final int index;
  final TextEditingController priceController, deliverableController;

  const DevlierableCard({
    super.key,
    required this.index,
    required this.priceController,
    required this.deliverableController,
  });

  @override
  State<DevlierableCard> createState() => _DevlierableCardState();
}

class _DevlierableCardState extends State<DevlierableCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Delivery ${widget.index + 1}",
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: AppColors.subHeading,
                fontWeight: FontWeight.w500,
              ),
        ),
        6.0.height,
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                autocorrect: true,
                controller: widget.deliverableController,
                maxLines: 3,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.subHeading,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter Deliverable',
                  hintStyle: TextStyle(
                    color: AppColors.body,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              12.0.height,
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.4,
                  child: NumberInputField(
                    controller: widget.priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      LengthLimitingTextInputFormatter(17),
                      ThousandsFormatter(
                        allowFraction: true,
                        formatter: NumberFormat.decimalPattern(),
                      ),
                    ],
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
