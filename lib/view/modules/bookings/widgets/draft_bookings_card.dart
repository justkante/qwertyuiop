import 'package:creatify_mobile/data/models/responses/creator_profile_dto.dart';
import 'package:creatify_mobile/data/models/responses/draft_booking_item_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/book_creator_view.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/cache_image_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DraftBookingsCard extends ConsumerStatefulWidget {
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
  ConsumerState<DraftBookingsCard> createState() => _DraftBookingsCardState();
}

class _DraftBookingsCardState extends ConsumerState<DraftBookingsCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surface,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              widget.bookingDetails?.creator?.profileImage == null
                  ? InitialAvatar(
                      initials: widget.bookingDetails?.creator?.initials ?? 'C',
                      size: 20,
                    )
                  : CachedImageHandler(
                      imageUrl: widget.bookingDetails?.creator?.profileImage,
                      height: 56,
                      width: 56,
                    ),
              8.0.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 9,
                          child: Text(
                            widget.bookingDetails?.creator?.name ?? 'Client Name',
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontSize: 14,
                              color: AppColors.subHeading,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        12.0.width,
                        Expanded(
                          flex: 5,
                          child: Text(
                            num.tryParse(widget.bookingDetails?.offeredPrice ?? '0')
                                .amountWithCurrency(widget.bookingDetails?.primaryCurrency ?? ''),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.spot500,
                              fontFamily: FontFamily.inter,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    2.0.height,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request drafted at ${widget.bookingDetails?.createdAt?.toBookingDateTime() ?? ''}',
                          style: context.textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                        4.0.height,
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(AppImages.licenseDraft),
                            4.0.width,
                            Text(
                              "Saved as Draft",
                              style: context.textTheme.bodySmall?.copyWith(fontSize: 10),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          12.0.height,
          Row(
            children: [
              Expanded(
                child: MainButton(
                  text: 'Complete Booking',
                  textColor: AppColors.grey50,
                  borderRadius: 8,
                  color: AppColors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onPressed: () {
                    context.push(
                      BookCreatorView(
                        creatorProfile: CreatorProfileDto(
                          id: widget.bookingDetails?.creator?.id,
                          name: widget.bookingDetails?.creator?.name,
                          profileImage: widget.bookingDetails?.creator?.profileImage,
                          primaryCurrency: widget.bookingDetails?.primaryCurrency,
                          exchangeRateInfo: widget.bookingDetails?.exchangeRateInfo,
                        ),
                        draftBooking: widget.bookingDetails,
                      ),
                    );
                  },
                ),
              ),
              12.0.width,

              // Delete Draft Button
              InkWell(
                onTap: widget.onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.highlightRed.withValues(alpha: 0.32)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: widget.isLoading
                      ? CircularProgressIndicator.adaptive(
                          constraints: BoxConstraints.tight(const Size(16, 16)),
                          padding: const EdgeInsets.all(12.0),
                          valueColor: const AlwaysStoppedAnimation(AppColors.highlightRed),
                          strokeWidth: 2,
                        )
                      : SvgPicture.asset(
                          AppImages.trash,
                          colorFilter: AppColors.kErrorColor.colorFilterMode(),
                        ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
