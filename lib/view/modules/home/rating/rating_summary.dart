import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/modules/home/rating/star_rating.dart';
import 'package:flutter/material.dart';

class RatingSummary extends StatelessWidget {
  final num rating;
  final int totalReviews;
  final int starCount;
  final bool showStars;

  const RatingSummary({
    super.key,
    required this.rating,
    required this.totalReviews,
    this.starCount = 5,
    this.showStars = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: context.textTheme.headlineSmall?.copyWith(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (showStars) ...[
          16.0.height,
          StarRating(
            rating: rating,
            starCount: starCount,
            starSize: 12,
          ),
        ],
        4.0.height,
        Text(
          "($totalReviews ${totalReviews == 1 ? 'Review' : 'Reviews'})",
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColors.body,
          ),
        ),
      ],
    );
  }
}
