import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class JobPostCard extends StatefulWidget {
  final String title;
  final String description;
  final String location;
  final double price;
  final String currency;
  final String dateRange;
  final String status;
  final String? serviceName;
  final int? applicationCount;
  final List<String>? applicationAvatars;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Function(bool)? onFavoriteToggle;
  final bool initialFavorite;

  const JobPostCard({
    super.key,
    required this.title,
    this.description = '',
    required this.location,
    required this.price,
    required this.currency,
    required this.dateRange,
    required this.status,
    this.serviceName,
    this.applicationCount,
    this.applicationAvatars,
    required this.onTap,
    this.onDelete,
    this.onFavoriteToggle,
    this.initialFavorite = false,
  });

  @override
  State<JobPostCard> createState() => _JobPostCardState();
}

class _JobPostCardState extends State<JobPostCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initialFavorite;
  }

  @override
  void didUpdateWidget(covariant JobPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFavorite != oldWidget.initialFavorite) {
      setState(() {
        isFavorite = widget.initialFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusLower = widget.status.toLowerCase();
    final isExpiredStatus = statusLower.contains('expired');
    final isClosed = statusLower == 'closed' || isExpiredStatus;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isClosed ? AppColors.grey50 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.grey100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1B3131),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                12.0.width,
                GestureDetector(
                  onTap: () async {
                    final newValue = !isFavorite;
                    setState(() {
                      isFavorite = newValue;
                    });
                    await widget.onFavoriteToggle?.call(newValue);
                  },
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_outline,
                    size: 22,
                    color: isFavorite ? Colors.red : AppColors.grey400,
                  ),
                ),
              ],
            ),
            8.0.height,
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.body),
                4.0.width,
                Text(
                  widget.location,
                  style: const TextStyle(fontSize: 13, color: AppColors.body),
                ),
                12.0.width,
                Text(
                  widget.price.amountWithCurrency(widget.currency),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF00796B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            12.0.height,
            Text(
              widget.description.isNotEmpty
                  ? widget.description
                  : 'If you no longer wish to receive these emails, you can Unsubscribe or Manage Preferences at any time.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.body,
                height: 1.4,
              ),
            ),
            16.0.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.dateRange,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.body,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00796B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.white,
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
