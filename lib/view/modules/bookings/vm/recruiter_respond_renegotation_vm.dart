import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RecruiterResponseRenegotiateBookingNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> recruiterResponseRenegotiation({
    required String bookingId,
    required bool isAccepted,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(bookingsRepository).recruiterRespondToRenegotiation(
            isAccepted: isAccepted,
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

final recruiterResponseRenegotiateBookingProvider =
    AutoDisposeAsyncNotifierProvider<RecruiterResponseRenegotiateBookingNotifier, String>(
  RecruiterResponseRenegotiateBookingNotifier.new,
);
