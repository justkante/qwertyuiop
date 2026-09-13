import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/quick_icons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class IncomingOutcomingCard extends ConsumerWidget {
  final String? title, amount;
  final Color? iconColor;
  const IncomingOutcomingCard({
    super.key,
    this.title,
    this.amount,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.surface,
        ),
      ),
      child: Row(
        children: [
          QuickIcon(
            icon: AppImages.suitcase,
            color: Colors.white,
            bgColor: iconColor ?? AppColors.highlightBlue,
            padding: 6,
            size: 12,
          ),
          8.0.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'Incoming',
                  style: context.textTheme.bodySmall,
                ),
                4.0.height,
                Text(
                  ref.watch(balanceVisibleController)
                      ? amount ?? 0.00.amountWithCurrency('')
                      : '●●●●●●●●',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontSize: ref.watch(balanceVisibleController) ? 16 : 12,
                    fontFamily: FontFamily.inter,
                    color: AppColors.subHeading,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
