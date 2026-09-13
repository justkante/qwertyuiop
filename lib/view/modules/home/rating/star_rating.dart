import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StarRating extends StatelessWidget {
  final num rating;
  final int starCount;
  final double starSize;
  final Color filledColor;
  final Color unfilledColor;
  final bool isInteractive;
  final ValueChanged<double>? onRatingChanged;
  final MainAxisSize mainAxisSize;
  final double spacing;

  const StarRating({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.starSize = 16,
    this.filledColor = AppColors.highlightYellow,
    this.unfilledColor = AppColors.grey300,
    this.isInteractive = false,
    this.onRatingChanged,
    this.mainAxisSize = MainAxisSize.min,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: mainAxisSize,
      children: List.generate(
        starCount,
        (index) => GestureDetector(
          onTap:
              isInteractive && onRatingChanged != null ? () => onRatingChanged!(index + 1.0) : null,
          child: Padding(
            padding: EdgeInsets.only(right: index < starCount - 1 ? spacing : 0),
            child: SvgPicture.asset(
              AppImages.star,
              width: starSize,
              height: starSize,
              colorFilter: ColorFilter.mode(
                _getStarColor(index),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStarColor(int index) {
    if (index < rating.floor()) {
      return filledColor;
    } else if (index < rating && rating - index >= 0.5) {
      return filledColor;
    } else if (index < rating) {
      // For partial stars, we could implement a gradient, but for simplicity,
      // we'll show half-filled stars as filled if >= 0.5, unfilled otherwise
      return filledColor;
    } else {
      return unfilledColor;
    }
  }
}
