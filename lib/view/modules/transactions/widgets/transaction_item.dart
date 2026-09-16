import 'package:creatify_mobile/data/models/responses/transaction_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/transactions/transaction_details_view.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
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
    final isOutgoing = transaction?.category == 'outgoing';
    final currency = ref.watch(userControllerProvider).primaryCurrency ?? 'NGN';

    return InkWell(
      onTap: () {
        if (transaction != null) {
          NavigationService.instance.push(TransactionDetailsView(transactionDetails: transaction!));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isOutgoing ? const Color(0xFFFFF1EF) : const Color(0xFFE0F2F1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOutgoing ? Icons.arrow_upward : Icons.arrow_downward,
                color: isOutgoing ? const Color(0xFFFF6F61) : const Color(0xFF00BFA5),
                size: 18,
              ),
            ),
            16.0.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction?.otherParty == null
                        ? transaction?.type?.replaceAll('_', ' ').toTitleCase() ?? ''
                        : transaction?.otherParty?.name ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1B3131),
                    ),
                  ),
                  Text(
                    transaction?.createdAt?.toFormattedDate() ?? '',
                    style: const TextStyle(fontSize: 11, color: AppColors.body),
                  ),
                ],
              ),
            ),
            Text(
              ref.watch(balanceVisibleController)
                  ? '${isOutgoing ? '-' : '+'}${(transaction?.amount ?? 0).amountWithCurrency(currency)}'
                  : '●●●●●●',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isOutgoing ? const Color(0xFFFF6F61) : const Color(0xFF00BFA5),
                fontFamily: 'Inter',
              ),
            ),
            8.0.width,
            const Icon(Icons.chevron_right, color: AppColors.grey200, size: 18),
          ],
        ),
      ),
    );
  }
}
