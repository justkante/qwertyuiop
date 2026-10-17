import 'dart:developer';

import 'package:creatify_mobile/view/modules/bookings/booking_details_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_dialog.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';

class BookingAlertPopup extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  const BookingAlertPopup({super.key, required this.bookingData});

  static void show(BuildContext context, Map<String, dynamic> bookingData) {
    AppDialog.showAppDialog(
      context,
      widget: BookingAlertPopup(bookingData: bookingData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = bookingData['title']?.toString() ?? bookingData['job_description']?.toString() ?? bookingData['message']?.toString() ?? 'New Booking Request';
    final price = bookingData['price']?.toString() ?? bookingData['total_price']?.toString() ?? '';
    final bookingId = bookingData['id']?.toString() ?? bookingData['booking_id']?.toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        24.0.height,
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.highlightCoral50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.bookmark_added, color: AppColors.highlightCoral, size: 36),
        ),
        16.0.height,
        Text(
          'New Booking Request! 🎉',
          style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        8.0.height,
        Text(
          title,
          style: context.textTheme.bodyMedium?.copyWith(color: AppColors.subHeading),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        if (price.isNotEmpty) ...[
          8.0.height,
          Text(
            'Amount: $price',
            style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
        24.0.height,
        Row(
          children: [
            Expanded(
              child: MainButton(
                text: 'Dismiss',
                color: AppColors.grey100,
                textColor: AppColors.heading,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (bookingId != null && bookingId.isNotEmpty) ...[
              12.0.width,
              Expanded(
                child: MainButton(
                  text: 'View Booking',
                  color: AppColors.primary,
                  onPressed: () {
                    Navigator.pop(context);
                    NavigationService.instance.push(BookingDetailsView(bookingId: bookingId));
                  },
                ),
              ),
            ],
          ],
        ),
        12.0.height,
      ],
    );
  }
}

/// Helper manager to safely show booking popups from Pusher or OneSignal push notifications
class BookingAlertManager {
  static String? _lastShownBookingId;
  static DateTime? _lastShownTime;
  static Map<String, dynamic>? _pendingData;

  /// Main entry point to display the Booking Alert Popup safely from anywhere
  static void show(BuildContext? context, Map<String, dynamic> data) {
    final ctx = context ?? NavigationService.instance.currentContext;
    log('🚨 BookingAlertManager.show called with data: $data, ctx: $ctx, mounted: ${ctx?.mounted}');
    if (ctx == null || !ctx.mounted) {
      log('❌ BookingAlertManager: context is null or not mounted! Storing as pending.');
      _pendingData = data;
      return;
    }

    final bookingId = data['id']?.toString() ??
        data['booking_id']?.toString() ??
        data['bookingId']?.toString();

    // Prevent duplicate popups within 5 seconds for the same booking
    final now = DateTime.now();
    if (_lastShownBookingId != null &&
        _lastShownBookingId == bookingId &&
        bookingId != null &&
        bookingId.isNotEmpty &&
        _lastShownTime != null &&
        now.difference(_lastShownTime!).inSeconds < 5) {
      return;
    }

    if (bookingId != null && bookingId.isNotEmpty) {
      _lastShownBookingId = bookingId;
      _lastShownTime = now;
    }

    BookingAlertPopup.show(ctx, data);
  }

  /// Check and show any pending alert if context becomes available
  static void checkPending() {
    if (_pendingData != null) {
      final data = _pendingData!;
      _pendingData = null;
      Future.delayed(const Duration(milliseconds: 500), () {
        show(null, data);
      });
    }
  }

  /// Handles incoming OneSignal Push Notifications (Foreground or Clicked)
  static void handlePushNotification({
    Map<String, dynamic>? additionalData,
    String? title,
    String? body,
  }) {
    final data = <String, dynamic>{};

    if (additionalData != null) {
      data.addAll(additionalData);
    }

    if (title != null && title.isNotEmpty) data['title'] = title;
    if (body != null && body.isNotEmpty && !data.containsKey('title')) {
      data['title'] = body;
    }

    final type = data['type']?.toString().toLowerCase() ?? '';
    final isBookingEvent = type.contains('booking') ||
        (title != null && title.toLowerCase().contains('booking')) ||
        (body != null && body.toLowerCase().contains('booking')) ||
        data.containsKey('booking_id') ||
        data.containsKey('bookingId') ||
        data.containsKey('id') ||
        data.isNotEmpty;

    if (isBookingEvent) {
      show(null, data);
    }
  }
}
