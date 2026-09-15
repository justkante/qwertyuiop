import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/booking_details_view.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/cache_image_handler.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookingsCard extends ConsumerWidget {
  final BookingItemDto? bookingDetails;
  final bool isSent;
  const BookingsCard({
    super.key,
    this.bookingDetails,
    this.isSent = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUser = isSent ? bookingDetails?.creator : bookingDetails?.recruiter;
    final status = bookingDetails?.status;

    final statusColor = switch (status) {
      BookingStatus.pending => const Color(0xFFF4A261),
      BookingStatus.accepted => const Color(0xFF2E7D32),
      BookingStatus.completed => const Color(0xFF2196F3),
      BookingStatus.cancelled => AppColors.highlightRed,
      BookingStatus.negotiated => const Color(0xFF1B3131),
      null => Colors.grey,
    };

    final statusBgColor = switch (status) {
      BookingStatus.pending => const Color(0xFFFEF6EF),
      BookingStatus.accepted => const Color(0xFFE8F5E9),
      BookingStatus.completed => const Color(0xFFE3F2FD),
      BookingStatus.cancelled => const Color(0xFFFFF1EF),
      BookingStatus.negotiated => const Color(0xFFF3F4F6),
      null => AppColors.grey50,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Info, Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              otherUser?.profileImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CachedImageHandler(
                        imageUrl: otherUser!.profileImage!,
                        height: 48,
                        width: 48,
                      ),
                    )
                  : CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.grey100,
                      child: Text(otherUser?.initials ?? 'U', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
              12.0.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUser?.name ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131)),
                    ),
                    Text(
                      bookingDetails?.service?.name ?? 'Service Details',
                      style: const TextStyle(color: AppColors.body, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      status == BookingStatus.accepted ? Icons.check_circle_outline : Icons.access_time,
                      size: 14,
                      color: statusColor,
                    ),
                    4.0.width,
                    Text(
                      status?.name.capitalize() ?? 'Pending',
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              8.0.width,
              const Icon(Icons.chevron_right, color: AppColors.body, size: 20),
            ],
          ),
          16.0.height,

          // Metadata Row: Date, Time, Location
          Row(
            children: [
              _buildMetaIcon(Icons.calendar_today_outlined, bookingDetails?.startDate?.toFormattedDate() ?? 'Date'),
              16.0.width,
              _buildMetaIcon(Icons.access_time, bookingDetails?.startTime?.toBookingTime() ?? 'Time'),
              16.0.width,
              Expanded(child: _buildMetaIcon(Icons.location_on_outlined, bookingDetails?.location ?? 'Location', isFlexible: true)),
            ],
          ),
          16.0.height,

          // Bottom Row: Price, Sent text, View details button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    num.tryParse(bookingDetails?.finalPrice ?? bookingDetails?.offeredPrice ?? '0')
                        .amountWithCurrency(bookingDetails?.currency ?? 'NGN'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1B3131),
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    '${isSent ? 'Sent' : 'Received'} ${bookingDetails?.createdAt?.timeAgo() ?? ''}',
                    style: const TextStyle(fontSize: 10, color: AppColors.body),
                  ),
                ],
              ),
              MainButton(
                text: 'View details',
                width: 120,
                borderRadius: 24,
                color: const Color(0xFFE0F2F1),
                textColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                onPressed: () {
                  context.push(
                    BookingDetailsView(
                      bookingId: bookingDetails?.id,
                      isSent: isSent,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaIcon(IconData icon, String text, {bool isFlexible = false}) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.body),
        4.0.width,
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: AppColors.body, fontWeight: FontWeight.w500),
        ),
      ],
    );

    return isFlexible ? content : content;
  }
}
