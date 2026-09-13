import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ReferralBarIndicator extends StatelessWidget {
  final num currentAmount;
  final num individualAmount;
  final int maxMilestones;
  final Color filledColor;
  final Color unfilledColor;
  final Color milestoneColor;

  const ReferralBarIndicator({
    super.key,
    required this.currentAmount,
    required this.individualAmount,
    this.maxMilestones = 5,
    this.filledColor = AppColors.highlightBlue,
    this.unfilledColor = AppColors.grey200,
    this.milestoneColor = AppColors.highlightYellow,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate how many segments are filled
    // 5 milestones create 4 segments, so maxMilestones - 1
    final int filledSegments = individualAmount > 0
        ? (currentAmount / individualAmount).floor().clamp(0, maxMilestones - 1)
        : 0;

    // Calculate the progress percentage (0.0 to 1.0)
    // Number of segments = maxMilestones - 1 (e.g., 5 milestones = 4 segments)
    // final double progress = individualAmount > 0
    //     ? (currentAmount / (individualAmount * (maxMilestones - 1))).clamp(0.0, 1.0)
    //     : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate milestone marker width and spacing
        const double markerWidth = 12;
        final double segmentWidth = (constraints.maxWidth - markerWidth) / (maxMilestones - 1);

        // Calculate filled width: reach the center of the target milestone marker
        final double filledWidth =
            filledSegments > 0 ? (filledSegments * segmentWidth) + (markerWidth / 2) : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar with milestones
            SizedBox(
              height: 30,
              child: Stack(
                children: [
                  // Background bar (unfilled)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: unfilledColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  // Filled bar
                  Positioned(
                    top: 12,
                    left: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      width: filledWidth,
                      height: 8,
                      decoration: BoxDecoration(
                        color: filledColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  // Milestone markers
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        maxMilestones,
                        (index) => Container(
                          width: 12,
                          height: 30,
                          decoration: BoxDecoration(
                            color: milestoneColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
