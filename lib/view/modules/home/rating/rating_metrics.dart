import 'package:creatify_mobile/view/modules/home/rating/rating_metric_item.dart';
import 'package:flutter/material.dart';

class RatingMetrics extends StatelessWidget {
  final List<RatingData> ratings;

  const RatingMetrics({
    super.key,
    required this.ratings,
  });

  @override
  Widget build(BuildContext context) {
    final totalReviews = ratings.fold<int>(0, (sum, rating) => sum + rating.count);

    return Column(
      children: ratings.map((rating) {
        final percentage = totalReviews > 0 ? (rating.count / totalReviews) * 100 : 0.0;
        return RatingMetricItem(
          starCount: rating.stars,
          reviewCount: rating.count,
          percentage: percentage,
          progressColor: rating.progressColor,
        );
      }).toList(),
    );
  }
}

class RatingData {
  final int stars;
  final int count;
  final Color? progressColor;

  const RatingData({
    required this.stars,
    required this.count,
    this.progressColor,
  });
}
