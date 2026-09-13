import 'package:creatify_mobile/core/utils/device_details.dart';
import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/booking_details_view.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/booking_status_card.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/cache_image_handler.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookingsCard extends ConsumerStatefulWidget {
  final BookingItemDto? bookingDetails;
  final bool isSent;
  const BookingsCard({
    super.key,
    this.bookingDetails,
    this.isSent = false,
  });

  @override
  ConsumerState<BookingsCard> createState() => _BookingsCardState();
}

class _BookingsCardState extends ConsumerState<BookingsCard> {
  bool isIpad = false;

  Future<void> isIpadMethod() async {
    isIpad = await Device.isIpadAsync();
  }

  @override
  void initState() {
    super.initState();
    isIpadMethod();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Banner(
        message: widget.bookingDetails?.paymentStatus?.name.toTitleCase() ?? 'Unknown',
        color: switch (widget.bookingDetails?.paymentStatus) {
          BookingPaymentStatus.unpaid => AppColors.body,
          BookingPaymentStatus.paid => AppColors.highlightBlue,
          BookingPaymentStatus.refunded => AppColors.highlightCoral,
          null => AppColors.grey300,
        },
        location: BannerLocation.topStart,
        child: Container(
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
                  if (widget.isSent) ...[
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
                  ] else ...[
                    widget.bookingDetails?.recruiter?.profileImage == null
                        ? InitialAvatar(
                            initials: widget.bookingDetails?.recruiter?.initials ?? 'C',
                            size: 20,
                          )
                        : CachedImageHandler(
                            imageUrl: widget.bookingDetails?.recruiter?.profileImage,
                            height: 56,
                            width: 56,
                          ),
                  ],
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
                                widget.isSent
                                    ? widget.bookingDetails?.creator?.name ?? 'Creator Name'
                                    : widget.bookingDetails?.recruiter?.name ?? 'Client Name',
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
                                num.tryParse(widget.bookingDetails?.finalPrice == null
                                        ? widget.bookingDetails?.offeredPrice ?? '0'
                                        : widget.bookingDetails?.finalPrice ?? '0')
                                    .amountWithCurrency(widget.bookingDetails?.currency ?? ''),
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
                              'Request ${widget.isSent ? 'sent' : 'received'} at ${widget.bookingDetails?.createdAt?.toBookingDateTime() ?? ''}',
                              style: context.textTheme.bodySmall?.copyWith(fontSize: 10),
                            ),
                            4.0.height,
                            BookingStatusCard(
                              status: widget.bookingDetails?.status,
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              12.0.height,
              MainButton(
                text: 'View Request',
                textColor: widget.bookingDetails?.status == BookingStatus.completed
                    ? AppColors.subHeading
                    : AppColors.grey50,
                borderRadius: 8,
                color: switch (widget.bookingDetails?.status) {
                  BookingStatus.pending => AppColors.highlightYellow,
                  BookingStatus.accepted => AppColors.highlightGreen,
                  BookingStatus.completed => AppColors.grey300,
                  BookingStatus.cancelled => AppColors.highlightRed,
                  BookingStatus.negotiated => AppColors.highlightBlue,
                  null => AppColors.grey300,
                },
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  context.push(
                    BookingDetailsView(
                      bookingId: widget.bookingDetails?.id,
                      isSent: widget.isSent,
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
