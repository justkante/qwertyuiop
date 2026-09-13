import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/data/models/requests/cancel_booking_req.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CancelBookingNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> cancelBooking({
    required CancelBookingReq req,
    required bool before48Hours,
    required String bookingId,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(bookingsRepository).cancelBooking(
            req: req,
            bookingId: bookingId,
          ),
    );

    if (!state.hasError) {
      mixpanel.trackEvent('Booking Cancelled', properties: {
        'booking_id': bookingId,
        'cancellation_window': before48Hours ? '<48h' : '>48h',
        'cancellation_reason': req.reason,
        'cancellation_note': req.details ?? 'N/A',
      });

      ref.invalidate(fetchReceivedBookingsProvider);
      ref.invalidate(fetchSentBookingsProvider);
      ref.invalidate(fetchBookingDetailsProvider(bookingId));
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final cancelBookingProvider = AutoDisposeAsyncNotifierProvider<CancelBookingNotifier, String>(
  CancelBookingNotifier.new,
);
