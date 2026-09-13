import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BookingStatusCard extends StatelessWidget {
  final BookingStatus? status;
  const BookingStatusCard({
    super.key,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppImages.indicator,
          colorFilter: switch (status) {
            BookingStatus.pending => AppColors.highlightYellow.colorFilterMode(),
            BookingStatus.accepted => AppColors.highlightGreen.colorFilterMode(),
            BookingStatus.completed => AppColors.grey300.colorFilterMode(),
            BookingStatus.cancelled => AppColors.highlightRed.colorFilterMode(),
            BookingStatus.negotiated => AppColors.highlightBlue.colorFilterMode(),
            null => AppColors.grey300.colorFilterMode(),
          },
        ),
        4.0.width,
        Text(
          switch (status) {
            BookingStatus.pending => 'Pending',
            BookingStatus.accepted => 'Accepted',
            BookingStatus.completed => 'Completed',
            BookingStatus.cancelled => 'Cancelled',
            BookingStatus.negotiated => 'Renegotiated',
            null => 'Unknown',
          },
          style: context.textTheme.bodySmall?.copyWith(fontSize: 10),
        )
      ],
    );
  }
}
