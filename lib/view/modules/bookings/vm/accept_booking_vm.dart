import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AcceptBookingNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> acceptBooking(
    String bookingId, {
    String? recruiterName,
    String? bookingDescription,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(bookingsRepository).acceptBooking(bookingId));

    if (!state.hasError) {
      mixpanel.trackEvent('Booking Accepted', properties: {
        'booking_id': bookingId,
        'recruiter_name': recruiterName ?? 'N/A',
        'booking_description': bookingDescription ?? 'N/A',
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

final acceptBookingProvider = AutoDisposeAsyncNotifierProvider<AcceptBookingNotifier, String>(
  AcceptBookingNotifier.new,
);
