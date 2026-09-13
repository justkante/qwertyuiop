import 'package:creatify_mobile/data/models/responses/transaction_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/transactions/transaction_details_view.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/quick_icons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TransactionItem extends ConsumerWidget {
  final TransactionItemDto? transaction;
  const TransactionItem({
    super.key,
    this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        context.push(TransactionDetailsView(transactionDetails: transaction!));
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        visualDensity: VisualDensity.compact,
        leading: QuickIcon(
          icon: AppImages.suitcase,
          padding: 10,
          size: 21,
          color: transaction?.category == 'outgoing'
              ? AppColors.highlightRed
              : AppColors.highlightBlue,
          bgColor: transaction?.category == 'outgoing'
              ? AppColors.highlightRed50
              : AppColors.highlightBlue50,
        ),
        title: Text(
          transaction?.otherParty == null
              ? transaction?.type?.replaceAll('_', ' ').toTitleCase() ?? ''
              : transaction?.otherParty?.name ?? '',
          style: context.textTheme.bodyLarge?.copyWith(
            fontSize: 15,
            color: AppColors.subHeading,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          (transaction?.paidAt == null
                  ? transaction?.createdAt?.transactionDate()
                  : transaction!.paidAt?.transactionDate()) ??
              '',
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: 10,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              ref.watch(balanceVisibleController)
                  ? '${transaction?.category == 'outgoing' ? '-' : '+'}${(transaction?.amount ?? 0).amountWithCurrency(ref.watch(userControllerProvider).primaryCurrency ?? '')}'
                  : '●●●●●●●●●●',
              style: context.textTheme.bodyLarge?.copyWith(
                fontSize: ref.watch(balanceVisibleController) ? 15 : 10,
                fontFamily: FontFamily.inter,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              switch (transaction?.status) {
                'pending' => 'Pending',
                'failed' => 'Failed',
                'successful' => 'Successful',
                'completed' => 'Successful',
                _ => '',
              },
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: switch (transaction?.status) {
                  'pending' => AppColors.highlightYellow,
                  'failed' => AppColors.highlightRed,
                  'successful' => AppColors.highlightGreen,
                  'completed' => AppColors.highlightGreen,
                  _ => AppColors.subHeading,
                },
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
