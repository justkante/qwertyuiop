import 'dart:developer';

import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
import 'package:creatify_mobile/data/models/responses/conversation_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/booking_complete.dart';
import 'package:creatify_mobile/view/modules/bookings/deliverable_based_renegotiate_booking_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/fetched_creator_profile_view.dart';
import 'package:creatify_mobile/view/modules/bookings/fetched_recruiter_profile_view.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/cancel_booking_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/payment_successful_view.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/make_payment_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/time_based_renegotiate_booking_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/mark_completed_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/mark_deliverable_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/sheets/update_status_sheet.dart';
import 'package:creatify_mobile/view/modules/bookings/update_creator_deliverable_view.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/accept_booking_vm.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/mark_completed_vm.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/recruiter_respond_renegotation_vm.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/update_booking_status_vm.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/verify_payment_vm.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/booking_status_card.dart';
import 'package:creatify_mobile/view/modules/chats/chat_conversation_view.dart';
import 'package:creatify_mobile/view/modules/chats/sheets/request_extension_sheet.dart';
import 'package:creatify_mobile/view/modules/chats/sheets/view_extension_sheet.dart';
import 'package:creatify_mobile/view/modules/chats/vm/chat_vm.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/home/widgets/initials_avatar.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/initialize_payment_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/stripe_init.dart';
import 'package:creatify_mobile/view/modules/transactions/widgets/transaction_line.dart';
import 'package:creatify_mobile/view/modules/webview/app_webview.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_bottomsheet.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/cache_image_handler.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BookingDetailsView extends ConsumerStatefulWidget {
  final String? bookingId;
  final bool isSent, fromChat;
  const BookingDetailsView({
    super.key,
    this.bookingId,
    this.isSent = false,
    this.fromChat = false,
  });

  @override
  ConsumerState<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends ConsumerState<BookingDetailsView> {
  String creator = '';
  String creatorId = '';
  String bookingId = '';
  String paymentMethod = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(fetchReceivedBookingsProvider);
      ref.invalidate(fetchSentBookingsProvider);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userControllerProvider);
    final bookingDetails = ref.watch(fetchBookingDetailsProvider(widget.bookingId ?? ''));
    final recruterAcceptNewPriceLoading =
        ref.watch(recruiterResponseRenegotiateBookingProvider).isLoading;
    final acceptBookingLoading = ref.watch(acceptBookingProvider).isLoading;
    final timeBasedMarkAsCompletedLoading = ref.watch(timeBasedMarkAsCompletedProvider).isLoading;
    final deliveryBasedMarkAsCompletedLoading =
        ref.watch(deliveryBasedMarkAsCompletedProvider).isLoading;
    final initializePaymentLoading = ref.watch(initializePaymentProvider).isLoading;
    final verifyLoading = ref.watch(verifyPaymentProvider).isLoading;
    final updatingCreatorBookingStatusLoading =
        ref.watch(updateCreatorBookingStatusProvider).isLoading;

    ref.listen(recruiterResponseRenegotiateBookingProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('You have accepted the new price.'.toTitleCase(), context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(acceptBookingProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('You have accepted the Booking'.toTitleCase(), context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    // Listen to Marking Delivery Completed - Time Based
    ref.listen(timeBasedMarkAsCompletedProvider, (_, value) {
      if (value is AsyncData) {
        context.push(
          BookingCompleteView(bookingId: widget.bookingId ?? ''),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    // Listen to Update Time Based Deliverable Status
    ref.listen(updateCreatorBookingStatusProvider, (_, value) {
      if (value is AsyncData) {
        context.pop();

        ToastDialog.showSuccess('Booking Status Updated', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    // Listen to Marking Delivery Completed - Deliverable Based
    ref.listen(deliveryBasedMarkAsCompletedProvider, (_, value) {
      if (value is AsyncData<(bool, bool)>) {
        if (value.value.$1) {
          context.push(
            BookingCompleteView(bookingId: widget.bookingId ?? ''),
          );
        } else {
          if (value.value.$2) {
            ToastDialog.showSuccess('Booking marked as completed', context);
          } else {
            ToastDialog.showSuccess('Revision successfully requested', context);
          }
        }
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    ref.listen(initializePaymentProvider, (_, next) async {
      if (next is AsyncData) {
        if (paymentMethod == 'online') {
          if (next.value?.currency == 'NGN') {
            context.push(
              WebviewScreen(
                url: next.value?.authorizationUrl ?? '',
                paymentReference: next.value?.paymentReference,
                bookingId: widget.bookingId,
                routeName: 'Make Payment',
              ),
            );
          } else {
            // Initialize Stripe First
            await initStripePayment(
              paymentIntent: next.value?.stripePaymentIntentId ?? '',
              clientSecret: next.value?.clientSecret ?? '',
              context: context,
            ).then((value) async {
              // Show the Payment Sheet
              await Stripe.instance.presentPaymentSheet().then((val) {
                if (context.mounted) {
                  log('Payment successful for reference: ${next.value?.paymentReference}');
                  // Pop the Screen and refresh Balance and Transactions if successful
                  ToastDialog.showSuccess('Your payment was successful', context);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref
                        .read(verifyPaymentProvider.notifier)
                        .verify(next.value?.paymentReference ?? '', widget.bookingId ?? '');
                  });
                }
              });
            });
          }
        } else if (paymentMethod == 'wallet') {
          ToastDialog.showSuccess('Booking paid succesfully from Wallet', context);
        }
      }
      if (next is AsyncError) {
        if (context.mounted) {
          ToastDialog.showError(next.error.toString(), context);
        }
      }
    });

    ref.listen(verifyPaymentProvider, (_, value) {
      if (value is AsyncData) {
        context.pushReplacement(
          PaymentSuccessfulView(
            creatorName: creator,
            creatorId: creatorId,
            bookingId: bookingId,
          ),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    final createChatLoading = ref.watch(createChatNotifier).isLoading;

    ref.listen(createChatNotifier, (_, value) {
      if (value is AsyncData<ConversationDto>) {
        ref.read(navBarController.notifier).index = 3;
        context.popToFirst();
        context.push(
          ChatConversationView(conversation: value.value),
        );
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return AbsorbPointer(
      absorbing: recruterAcceptNewPriceLoading ||
          acceptBookingLoading ||
          timeBasedMarkAsCompletedLoading ||
          deliveryBasedMarkAsCompletedLoading ||
          initializePaymentLoading ||
          verifyLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Booking Details',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.subHeading,
            ),
          ),
        ),
        body: bookingDetails.when(
          data: (data) {
            creator = data.creator?.name ?? '';
            creatorId = data.creator?.id ?? '';
            bookingId = data.id ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MARK: Booking Info
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // MARK: Image and Name
                        if (widget.isSent) ...[
                          data.creator?.profileImage == null
                              ? Center(
                                  child: InitialAvatar(
                                    initials: data.creator?.initials ?? 'C',
                                    size: 30,
                                  ),
                                )
                              : Center(
                                  child: CachedImageHandler(
                                    imageUrl: data.creator?.profileImage,
                                    height: 64,
                                    width: 64,
                                  ),
                                ),
                        ] else ...[
                          data.recruiter?.profileImage == null
                              ? Center(
                                  child: InitialAvatar(
                                    initials: data.recruiter?.initials ?? 'C',
                                    size: 20,
                                  ),
                                )
                              : Center(
                                  child: CachedImageHandler(
                                    imageUrl: data.recruiter?.profileImage,
                                    height: 64,
                                    width: 64,
                                  ),
                                ),
                        ],
                        8.0.height,
                        Center(
                          child: InkWell(
                            onTap: () {
                              if (widget.isSent) {
                                context.push(
                                  FetchedCreatorProfileView(
                                    creatorId: creatorId,
                                    creatorName: creator,
                                  ),
                                );
                              } else {
                                context.push(
                                  FetchedRecruiterProfileView(
                                    creatorId: data.recruiter?.id ?? '',
                                    creatorName: data.recruiter?.name ?? '',
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.isSent
                                      ? data.creator?.name ?? 'Client Name'
                                      : data.recruiter?.name ?? 'Creator Name',
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.subHeading,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                4.0.width,
                                SvgPicture.asset(
                                  AppImages.openExternal,
                                  colorFilter: AppColors.subHeading.colorFilterMode(),
                                  width: 20,
                                  height: 20,
                                )
                              ],
                            ),
                          ),
                        ),
                        8.0.height,
                        Center(
                          child: BookingStatusCard(
                            status: data.status,
                          ),
                        ),

                        // Chat with Creator Button
                        if (!widget.fromChat &&
                            data.status == BookingStatus.accepted &&
                            data.paymentStatus == BookingPaymentStatus.paid) ...[
                          0.0.height,
                          TextButton(
                            onPressed: () {
                              ref.read(createChatNotifier.notifier).createNewChat(
                                    widget.isSent
                                        ? data.creator?.id ?? ''
                                        : data.recruiter?.id ?? '',
                                    widget.bookingId ?? '',
                                  );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  AppImages.message,
                                  colorFilter: AppColors.primary.colorFilterMode(),
                                  width: 18,
                                  height: 18,
                                ),
                                3.0.width,
                                Text(
                                  'Chat with ${widget.isSent ? data.creator?.name?.split(' ').first ?? 'Creator' : data.recruiter?.name?.split(' ').first ?? 'Recruiter'}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                if (createChatLoading) ...[
                                  10.0.width,
                                  LoadingAnimationWidget.hexagonDots(
                                    color: AppColors.primary,
                                    size: 14,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        8.0.height,

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.grey50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            data.jobDescription ?? '',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.body,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        24.0.height,

                        // MARK: Booking Details
                        for (var details in [
                          ('Service', data.service?.name),
                          (
                            'Booking Type',
                            data.bookingType == 'time-based' ? 'Time Based' : 'Deliverable Based'
                          ),
                          ('Work Mode', data.workMode?.toTitleCase()),
                          if (data.bookingType == 'time-based')
                            ('Start Time', data.startTime?.toBookingTime()),
                          ('Start Date', data.startDate?.toLocal().toFormattedDateWithYear()),
                          ('End Date', data.endDate?.toLocal().toFormattedDateWithYear()),
                          ('Duration', data.duration),
                          ('Location', data.location ?? 'Remote'),
                          (
                            'Payment Status',
                            switch (data.paymentStatus) {
                              null => 'Unknown',
                              BookingPaymentStatus.paid => 'Paid',
                              BookingPaymentStatus.unpaid => 'Unpaid',
                              BookingPaymentStatus.refunded => 'Refunded',
                            }
                          )
                        ])
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
                            child: TransactionLine(
                              title: details.$1,
                              value: details.$2,
                              valueColor: details.$1 == 'Payment Status'
                                  ? switch (data.paymentStatus) {
                                      null => null,
                                      BookingPaymentStatus.paid => AppColors.highlightGreen,
                                      BookingPaymentStatus.unpaid => AppColors.highlightRed,
                                      BookingPaymentStatus.refunded => AppColors.highlightYellow,
                                    }
                                  : null,
                            ),
                          ),

                        // MARK: Deliverables Section
                        if (data.bookingType == 'deliverable-based') ...[
                          14.0.height,
                          Container(
                            padding: const EdgeInsets.all(12),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Deliverables",
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.subHeading,
                                height: 1.5,
                              ),
                            ),
                          ),
                          12.0.height,
                          for (BookingDeliverable deliverable in data.deliverables ?? [])
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deliverable ${(data.deliverables ?? []).indexOf(deliverable) + 1}',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.subHeading,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                3.0.height,
                                Text(
                                  deliverable.description ?? '',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.body,
                                  ),
                                ),
                                3.0.height,
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          num.tryParse(deliverable.price ?? '0')
                                              .amountWithCurrency(data.currency ?? ''),
                                          style: context.textTheme.bodySmall?.copyWith(
                                            color: AppColors.primary,
                                            fontFamily: FontFamily.inter,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5,
                                          ),
                                        ),
                                        if (data.pricing != null &&
                                            (userData.primaryCurrency != data.currency)) ...[
                                          Text(
                                            "≈ ${widget.isSent ? deliverable.pricing?.recruiter?.amount?.amountWithCurrency(deliverable.pricing?.recruiter?.currency ?? '') ?? '' : deliverable.pricing?.creator?.amount?.amountWithCurrency(deliverable.pricing?.creator?.currency ?? '') ?? ''}",
                                            style: context.textTheme.bodySmall?.copyWith(
                                              color: AppColors.subHeading,
                                              fontFamily: FontFamily.inter,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                12.0.height
                              ],
                            ),
                          8.0.height,
                        ],
                        8.0.height,

                        // MARK: Amount
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.grey50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TransactionLine(
                                title: 'Amount',
                                valueColor: AppColors.primary,
                                value: num.tryParse(data.finalPrice == null
                                        ? data.offeredPrice ?? '0'
                                        : data.finalPrice ?? '0')
                                    .amountWithCurrency(data.currency ?? ''),
                              ),
                              if (data.pricing != null &&
                                  (userData.primaryCurrency != data.currency)) ...[
                                Text(
                                  "≈ ${widget.isSent ? data.pricing?.recruiter?.amount?.amountWithCurrency(data.pricing?.recruiter?.currency ?? '') ?? '' : data.pricing?.creator?.amount?.amountWithCurrency(data.pricing?.creator?.currency ?? '') ?? ''}",
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.subHeading,
                                    fontFamily: FontFamily.inter,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // MARK: Renegotiations
                        if (data.isRenegotiated == true) ...[
                          24.0.height,
                          Text(
                            'Renegotiations',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.subHeading,
                            ),
                          ),
                          12.0.height,
                          ...(data.renegotiationHistory?.map((renegotiation) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.highlightBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            renegotiation.renegotiatedBy?.name ?? 'Creator Name',
                                            style: context.textTheme.bodySmall
                                                ?.copyWith(color: AppColors.grey50),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.highlightCoral,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              "${num.tryParse(renegotiation.newPrice ?? '0').amountWithCurrency(data.currency ?? '')} ${userData.primaryCurrency != data.currency ? "(${((num.tryParse(renegotiation.newPrice ?? '0') ?? 0) * (data.pricing?.exchangeRate ?? 0)).amountWithCurrency(userData.primaryCurrency ?? '')})" : ""}",
                                              style: context.textTheme.bodySmall?.copyWith(
                                                color: AppColors.grey50,
                                                fontFamily: FontFamily.inter,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      12.0.height,
                                      Text(
                                        'Reason: ${renegotiation.details ?? ''}',
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(color: AppColors.grey100),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList() ??
                              []),
                        ],

                        // MARK: Extension Requests
                        if (data.extensionRequests?.isNotEmpty == true) ...[
                          24.0.height,
                          Text(
                            'Extension Requests',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.subHeading,
                            ),
                          ),
                          12.0.height,
                          ...(data.extensionRequests?.map((extension) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.highlightCoral,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'New Date Extension',
                                            style: context.textTheme.bodySmall
                                                ?.copyWith(color: AppColors.grey50),
                                          ),
                                          Visibility(
                                            visible: (extension.status == 'pending') &&
                                                (extension == data.extensionRequests?.last),
                                            child: InkWell(
                                              onTap: () {
                                                AppBottomSheet.showBottomSheet(
                                                  context,
                                                  widget: ViewExtensionSheet(
                                                    booking: data,
                                                    isLastRequest:
                                                        extension == data.extensionRequests?.last,
                                                    isCreator: !widget.isSent,
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.highlightBlue,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'View Request',
                                                  style: context.textTheme.bodySmall?.copyWith(
                                                    color: AppColors.grey50,
                                                    fontFamily: FontFamily.inter,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      8.0.height,
                                      Text(
                                        'New Date: ${data.bookingType == 'time-based' ? extension.newEndTime?.toBookingDateTime() ?? '' : extension.newEndDate?.toBookingDateTime() ?? ''}',
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(color: AppColors.grey100),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList() ??
                              []),
                        ],
                        48.0.height,
                      ],
                    ),
                  ),
                ),

                // MARK: Buttons
                if ((data.status != BookingStatus.completed) &&
                    (data.status != BookingStatus.cancelled)) ...[
                  // Only Show Buttons if it's not completed or cancelled

                  SafeArea(
                    minimum: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Creator Buttons
                        // Accept and Renegotiate Buttons
                        // Conditions: If the booking is not sent by the user, is not renegotiated, and is not accepted
                        // And current date is before start date (for Deliverable Based)
                        // And current date is before start date (for Time Based). if current date is same as start date, check time also (For Time Based)
                        if (!widget.isSent &&
                            data.isRenegotiated == false &&
                            data.status != BookingStatus.accepted &&
                            (data.bookingType == 'deliverable-based'
                                ? DateTime.now().isBefore(data.startDate ?? DateTime.now())
                                : DateTime.now().isBefore(data.startDate?.toDateTimeFromString(
                                        timeString: data.startTime ?? "00:00:00") ??
                                    DateTime.now()))) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: MainButton(
                                  color: AppColors.btnTertiary,
                                  text: 'Renegotiate',
                                  textColor: AppColors.btnText,
                                  onPressed: () {
                                    if (data.bookingType == 'time-based') {
                                      AppBottomSheet.showBottomSheet(
                                        context,
                                        widget: TimeBasedRenegotiateBookingSheet(
                                          bookingId: widget.bookingId,
                                          currency: data.currency ?? '',
                                          jobDescription: data.jobDescription,
                                          oldPrice: data.offeredPrice,
                                          duration: data.duration,
                                          startDate: data.startDate,
                                        ),
                                      );
                                    } else {
                                      context.push(
                                        DeliverableBasedRenegotiateBookingView(
                                          bookingId: widget.bookingId,
                                          currency: data.currency ?? '',
                                          jobDescription: data.jobDescription,
                                          oldPrice: data.offeredPrice,
                                          duration: data.duration,
                                          startDate: data.startDate,
                                          deliverables: data.deliverables,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              12.0.width,
                              Expanded(
                                child: MainButton(
                                  isLoading: acceptBookingLoading,
                                  text: 'Accept',
                                  onPressed: () {
                                    ref.read(acceptBookingProvider.notifier).acceptBooking(
                                          widget.bookingId ?? '',
                                          recruiterName: data.recruiter?.name ?? '',
                                          bookingDescription: data.jobDescription,
                                        );
                                  },
                                ),
                              ),
                            ],
                          ),
                          12.0.height,
                        ],

                        // Request Extension Button
                        if (!widget.isSent &&
                            data.status == BookingStatus.accepted &&
                            data.paymentStatus == BookingPaymentStatus.paid) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: MainButton(
                                  text: 'Request Extension',
                                  color: AppColors.highlightYellow,
                                  onPressed: () {
                                    AppBottomSheet.showBottomSheet(
                                      context,
                                      widget: RequestExtensionSheet(
                                        booking: data,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          12.0.height,
                        ],

                        // Recruiter Buttons and Common Buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Cancel Booking Button
                            Expanded(
                              child: MainButton(
                                color: AppColors.red50,
                                text: 'Cancel Booking',
                                textColor: AppColors.btnText,
                                onPressed: () {
                                  // Show cancel booking sheet
                                  // If the booking is before 48 hours AFTER start date and the booking is accepted and paid, show a warning about late cancellation fee
                                  AppBottomSheet.showBottomSheet(
                                    context,
                                    widget: CancelBookingSheet(
                                      isCreator: !widget.isSent,
                                      bookingId: widget.bookingId,
                                      before48Hours: data.acceptedAt != null &&
                                          data.paymentStatus == BookingPaymentStatus.paid &&
                                          data.startDate?.toDateTimeFromString(
                                                  timeString: data.startTime ?? "00:00:00") !=
                                              null &&
                                          DateTime.now().isBefore(
                                            data.startDate!
                                                .toDateTimeFromString(
                                                    timeString: data.startTime ?? "00:00:00")
                                                .add(
                                                  const Duration(
                                                    hours: 48,
                                                  ),
                                                ),
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Accept Creators New Price
                            if (data.status == BookingStatus.negotiated &&
                                widget.isSent &&
                                DateTime.now().isBefore(data.startDate ?? DateTime.now())) ...[
                              12.0.width,
                              Expanded(
                                child: MainButton(
                                  isLoading: recruterAcceptNewPriceLoading,
                                  text: 'Accept New Price',
                                  onPressed: () {
                                    ref
                                        .read(recruiterResponseRenegotiateBookingProvider.notifier)
                                        .recruiterResponseRenegotiation(
                                          bookingId: widget.bookingId ?? '',
                                          isAccepted: true,
                                        );
                                  },
                                ),
                              )
                            ],

                            // Payment Button
                            if (data.status == BookingStatus.accepted) ...[
                              12.0.width,
                              if (widget.isSent) ...[
                                Expanded(
                                  child: MainButton(
                                    isLoading: timeBasedMarkAsCompletedLoading ||
                                        deliveryBasedMarkAsCompletedLoading ||
                                        initializePaymentLoading ||
                                        verifyLoading,
                                    text: data.paymentStatus == BookingPaymentStatus.unpaid
                                        ? 'Make Payment'
                                        : 'Mark as Completed',
                                    onPressed: () async {
                                      if (data.paymentStatus == BookingPaymentStatus.unpaid) {
                                        paymentMethod = await AppBottomSheet.showBottomSheet(
                                          context,
                                          widget: MakePaymentOptionsSheet(
                                            amountDue: data.pricing != null
                                                ? (data.pricing?.recruiter?.amount ?? 0)
                                                : num.tryParse(data.finalPrice == null
                                                        ? data.offeredPrice ?? '0'
                                                        : data.finalPrice ?? '0') ??
                                                    0,
                                            bookingId: widget.bookingId ?? '',
                                          ),
                                        );
                                      } else if (data.paymentStatus == BookingPaymentStatus.paid) {
                                        if (data.bookingType == 'time-based') {
                                          bool result = await AppBottomSheet.showBottomSheet(
                                            context,
                                            widget: const MarkCompletedSheet(),
                                          );

                                          if (result) {
                                            ref
                                                .read(timeBasedMarkAsCompletedProvider.notifier)
                                                .markAsCompletedTimeBased(
                                                  bookingId: widget.bookingId ?? '',
                                                );
                                          }
                                        } else if (data.bookingType == 'deliverable-based') {
                                          String? deliverableId =
                                              await AppBottomSheet.showBottomSheet(
                                            context,
                                            widget: MarkDeliveryCompletedSheet(
                                              bookingId: widget.bookingId ?? '',
                                              deliverables: data.deliverables ?? [],
                                            ),
                                          );

                                          if (deliverableId != null) {
                                            ref
                                                .read(deliveryBasedMarkAsCompletedProvider.notifier)
                                                .markAsCompletedDeliveryBased(
                                                  bookingId: widget.bookingId ?? '',
                                                  deliverableId: deliverableId,
                                                  action: 'approve',
                                                );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                )
                              ] else ...[
                                Visibility(
                                  visible: data.paymentStatus == BookingPaymentStatus.paid,
                                  child: Expanded(
                                    child: MainButton(
                                      isLoading: updatingCreatorBookingStatusLoading,
                                      text: "Update Status",
                                      onPressed: () async {
                                        // If Booking is Time Based
                                        if (data.bookingType == 'time-based') {
                                          if (!mounted) return;

                                          String result = await AppBottomSheet.showBottomSheet(
                                            context,
                                            widget: const UpdateDeliverableStatusSheet(
                                              status: "In Progress",
                                            ),
                                          );

                                          if (result.isNotEmpty) {
                                            ref
                                                .read(updateCreatorBookingStatusProvider.notifier)
                                                .updateBookingStatus(
                                                  bookingId: widget.bookingId ?? '',
                                                  status: result.toLowerCase().replaceAll(' ', '_'),
                                                );
                                          }
                                        } else {
                                          if (!mounted) return;

                                          context.push(
                                            UpdateCreatorDeliverableSheet(
                                              bookingId: widget.bookingId ?? '',
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
          error: (error, stackTrace) => Center(child: Text('Error: ${error.toString()}')),
          loading: () => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
                8.0.height,
                const Text('Fetching Booking Details...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
