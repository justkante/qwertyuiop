import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';

class TransactionLine extends StatelessWidget {
  final String? title, value;
  final double? titleSize, valueSize;
  final Color? valueColor;
  const TransactionLine({
    super.key,
    this.title,
    this.value,
    this.titleSize,
    this.valueSize,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title ?? 'Cost',
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.body,
            fontSize: titleSize ?? 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        24.0.width,
        Flexible(
          child: Text(
            value ?? 32000.amountWithCurrency(''),
            textAlign: TextAlign.right,
            style: context.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? AppColors.subHeading,
              fontSize: valueSize ?? 16,
              fontFamily: FontFamily.inter,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
