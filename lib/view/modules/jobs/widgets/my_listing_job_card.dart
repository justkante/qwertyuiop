import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';

class MyListingJobCard extends StatelessWidget {
  final String title;
  final String location;
  final double price;
  final String currency;
  final String description;
  final String? serviceName; // Add this
  final int applicationCount;
  final String postedDate;
  final String status; // active, draft, closed
  final VoidCallback onTap;
  final VoidCallback onViewApplicants;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MyListingJobCard({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.currency,
    required this.description,
    this.serviceName, // Add this
    required this.applicationCount,
    required this.postedDate,
    required this.status,
    required this.onTap,
    required this.onViewApplicants,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusLower = status.toLowerCase();
    final statusColor = statusLower == 'active'
        ? const Color(0xFF2E7D32)
        : statusLower == 'draft'
            ? const Color(0xFFF59E0B)
            : Colors.grey;

    final statusBgColor = statusLower == 'active'
        ? const Color(0xFFE8F5E9)
        : statusLower == 'draft'
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFF3F4F6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.grey100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Increased from 16
                      color: const Color(0xFF1B3131),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          6.0.width,
                          Text(
                            status.capitalize(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    8.0.width,
                    const Icon(Icons.more_vert, color: AppColors.body, size: 20),
                  ],
                ),
              ],
            ),
            8.0.height,
            if (serviceName != null) ...[
              Text(
                serviceName!,
                style: const TextStyle(
                  color: Color(0xFFFF6F61),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.0.height,
            ],
            // Location and Price
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.body),
                4.0.width,
                Text(
                  location,
                  style: context.textTheme.bodySmall?.copyWith(fontSize: 14, color: AppColors.body), // Increased
                ),
                12.0.width,
                const Text('|', style: TextStyle(color: AppColors.grey200)),
                12.0.width,
                const Icon(Icons.account_balance_wallet_outlined, size: 14, color: AppColors.primary),
                4.0.width,
                Text(
                  price.amountWithCurrency(currency),
                  style: const TextStyle(
                    fontSize: 15, // Increased
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            12.0.height,

            // Description
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 14, // Increased
                color: AppColors.body,
                height: 1.4,
              ),
            ),
            16.0.height,

            // Applications and Posted Date
            Row(
              children: [
                const Icon(Icons.group_outlined, size: 16, color: AppColors.body),
                6.0.width,
                Text(
                  '$applicationCount Applications',
                  style: context.textTheme.bodySmall?.copyWith(fontSize: 13, color: AppColors.body), // Increased
                ),
                16.0.width,
                const Text('|', style: TextStyle(color: AppColors.grey200)),
                16.0.width,
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.body),
                6.0.width,
                Text(
                  '${statusLower == 'draft' ? 'Saved' : 'Posted'} $postedDate',
                  style: context.textTheme.bodySmall?.copyWith(fontSize: 13, color: AppColors.body), // Increased
                ),
              ],
            ),
            20.0.height,

            // Action Buttons
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: MainButton(
                    text: 'View Applicants',
                    borderRadius: 24,
                    color: const Color(0xFFE0F2F1),
                    textColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: onViewApplicants,
                    prefixIcon: const Icon(Icons.group_outlined, color: AppColors.primary, size: 18),
                  ),
                ),
                8.0.width,
                Expanded(
                  flex: 3,
                  child: MainButton(
                    text: 'Edit',
                    borderRadius: 24,
                    color: AppColors.grey50,
                    textColor: const Color(0xFF1B3131),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: onEdit,
                    prefixIcon: const Icon(Icons.edit_outlined, color: Color(0xFF1B3131), size: 16),
                  ),
                ),
                8.0.width,
                InkWell(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1EF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
