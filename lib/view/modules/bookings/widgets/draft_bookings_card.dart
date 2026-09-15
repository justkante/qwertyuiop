import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/data/models/responses/draft_booking_item_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/book_creator_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/cache_image_handler.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DraftBookingsCard extends ConsumerWidget {
  final DraftingBookingItemDto? bookingDetails;
  final Function()? onDelete;
  final bool isLoading;
  const DraftBookingsCard({
    super.key,
    this.bookingDetails,
    this.onDelete,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creator = bookingDetails?.creator;

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
          // Header: Avatar, Name, Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              creator?.profileImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CachedImageHandler(
                        imageUrl: creator!.profileImage!,
                        height: 48,
                        width: 48,
                      ),
                    )
                  : CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.grey100,
                      child: Text(creator?.initials ?? 'C', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
              12.0.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creator?.name ?? 'Unknown Creator',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B3131)),
                    ),
                    Text(
                      bookingDetails?.category?.name ?? 'Creator Niche',
                      style: const TextStyle(color: Color(0xFFFF6F61), fontSize: 12),
                    ),
                    Text(
                      'Created ${bookingDetails?.createdAt?.timeAgo() ?? ''}',
                      style: const TextStyle(fontSize: 10, color: AppColors.body),
                    ),
                  ],
                ),
              ),
              // Draft Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('Draft', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              8.0.width,
              const Icon(Icons.more_vert, color: AppColors.body, size: 20),
            ],
          ),
          16.0.height,

          // Metadata: Location and Start Date
          Row(
            children: [
              _buildMetaItem(Icons.location_on_outlined, bookingDetails?.location ?? 'Remote'),
              24.0.width,
              _buildMetaItem(Icons.calendar_today_outlined, 'Start date: ${bookingDetails?.startDate?.toFormattedDate() ?? 'TBD'}'),
            ],
          ),
          20.0.height,

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 4,
                child: MainButton(
                  text: 'Continue',
                  borderRadius: 24,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onPressed: () {
                    context.push(
                      BookCreatorView(
                        creatorProfile: CreatorProfileDto(
                          id: creator?.id,
                          name: creator?.name,
                          profileImage: creator?.profileImage,
                          primaryCurrency: bookingDetails?.primaryCurrency,
                          exchangeRateInfo: bookingDetails?.exchangeRateInfo,
                        ),
                        draftBooking: bookingDetails,
                      ),
                    );
                  },
                ),
              ),
              12.0.width,
              InkWell(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1EF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.red)))
                      : const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.body),
        4.0.width,
        Text(text, style: const TextStyle(fontSize: 11, color: AppColors.body, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
