import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class JobPostCard extends StatefulWidget {
  final String title;
  final String description; // Add this
  final String location;
  final double price;
  final String currency;
  final String dateRange;
  final String status; // Sent, Viewed, etc
  final int? applicationCount; // Add this
  final List<String>? applicationAvatars; // Add this
  final VoidCallback onTap;
  final VoidCallback? onDelete; // Add this
  final Function(bool)? onFavoriteToggle; // Add this
  final bool initialFavorite;

  const JobPostCard({
    super.key,
    required this.title,
    this.description = '', // Add this
    required this.location,
    required this.price,
    required this.currency,
    required this.dateRange,
    required this.status,
    this.applicationCount, // Add this
    this.applicationAvatars, // Add this
    required this.onTap,
    this.onDelete, // Add this
    this.onFavoriteToggle, // Add this
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
  Widget build(BuildContext context) {
    final statusLower = widget.status.toLowerCase();
    final isClosed = statusLower == 'closed';
    final statusColor = switch (statusLower) {
      'sent' => Colors.orange,
      'viewed' => Colors.blue,
      'accepted' => const Color(0xFF009688),
      'rejected' => Colors.red,
      'closed' => Colors.grey,
      'active' => const Color(0xFF009688),
      _ => Colors.transparent,
    };

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isClosed ? AppColors.grey50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey100),
        ),
        child: Opacity(
          opacity: isClosed ? 0.6 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Row(
                    children: [
                      if (widget.status.isNotEmpty && statusLower != 'active') ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        6.0.width,
                        Text(
                          widget.status.capitalize(),
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: AppColors.body,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        12.0.width,
                      ],
                      if (widget.onDelete != null) ...[
                        GestureDetector(
                          onTap: widget.onDelete,
                          child: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                        ),
                        12.0.width,
                      ],
                      GestureDetector(
                        onTap: () {
                          final newValue = !isFavorite;
                          setState(() {
                            isFavorite = newValue;
                          });
                          widget.onFavoriteToggle?.call(newValue);
                        },
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          size: 18,
                          color: isFavorite ? Colors.red : AppColors.body,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              4.0.height,
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: AppColors.body),
                  4.0.width,
                  Text(
                    widget.location,
                    style: context.textTheme.bodySmall?.copyWith(fontSize: 11, color: AppColors.body),
                  ),
                  12.0.width,
                  Text(
                    widget.price.amountWithCurrency(widget.currency),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF009688),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              12.0.height,
              Text(
                widget.description.isNotEmpty
                    ? widget.description.truncate(100)
                    : 'No description available',
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
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
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: AppColors.body,
                    ),
                  ),
                  if (widget.applicationCount != null) ...[
                    Row(
                      children: [
                        if (widget.applicationAvatars != null && widget.applicationAvatars!.isNotEmpty) ...[
                          SizedBox(
                            height: 20,
                            width: (widget.applicationAvatars!.length * 12.0) + 8,
                            child: Stack(
                              children: List.generate(widget.applicationAvatars!.length, (index) {
                                return Positioned(
                                  left: index * 12.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                    child: CircleAvatar(
                                      radius: 8,
                                      backgroundImage: NetworkImage(widget.applicationAvatars![index]),
                                      backgroundColor: AppColors.grey100,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          4.0.width,
                        ],
                        Text(
                          '${widget.applicationCount} Applications',
                          style: context.textTheme.bodySmall?.copyWith(fontSize: 10, color: AppColors.body),
                        ),
                      ],
                    ),
                  ] else if (!isClosed)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF009688),
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
      ),
    );
  }
}
