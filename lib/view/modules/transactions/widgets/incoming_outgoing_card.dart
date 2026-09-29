import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class IncomingOutcomingCard extends ConsumerWidget {
  final String? title, amount;
  final bool isIncoming;
  final Color? iconColor;

  const IncomingOutcomingCard({
    super.key,
    this.title,
    this.amount,
    this.isIncoming = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveColor = iconColor ?? (isIncoming ? const Color(0xFF00BFA5) : const Color(0xFFFF6F61));
    final effectiveBgColor = isIncoming ? const Color(0xFFE0F2F1) : const Color(0xFFFFF1EF);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: effectiveBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
              color: effectiveColor,
              size: 16,
            ),
          ),
          12.0.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? (isIncoming ? 'Incoming' : 'Outgoing'),
                  style: context.textTheme.bodySmall?.copyWith(fontSize: 10, color: AppColors.body),
                ),
                Text(
                  ref.watch(balanceVisibleController)
                      ? amount ?? '0.00'
                      : '●●●●●●',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1B3131),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey300, size: 16),
        ],
      ),
    );
  }
}
