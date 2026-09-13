import 'package:creatify_mobile/view/modules/home/rating/star_rating.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';

class MostRecentCard extends StatelessWidget {
  final String reviewerName;
  final num rating;
  final String reviewDate;
  final String reviewText;
  final String? reviewerAvatar;
  final int starCount;

  const MostRecentCard({
    super.key,
    required this.reviewerName,
    required this.rating,
    required this.reviewDate,
    required this.reviewText,
    this.reviewerAvatar,
    this.starCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reviewerName,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                reviewDate,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.body,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          2.0.height,

          // Star rating
          StarRating(
            rating: rating,
            starCount: starCount,
            starSize: 10,
          ),
          8.0.height,

          // Review text
          Text(
            reviewText,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.subHeading,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
