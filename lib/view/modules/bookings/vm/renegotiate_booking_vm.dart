import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/requests/renegotiate_booking_req.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RenegotiateBookingNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> renegotiateBooking({
    required RenegotiateBookingReq req,
    required String bookingId,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(bookingsRepository).renegotiateBooking(
            req: req,
            bookingId: bookingId,
          ),
    );

    if (!state.hasError) {
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

final renegotiateBookingProvider =
    AutoDisposeAsyncNotifierProvider<RenegotiateBookingNotifier, String>(
  RenegotiateBookingNotifier.new,
);
