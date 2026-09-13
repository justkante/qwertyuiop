import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/data/models/requests/booking_request_req.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReportBookingNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> reportBooking(ReportBookingReq req, {String? reportedReason}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(bookingsRepository).reportBooking(req),
    );

    if (!state.hasError) {
      mixpanel.trackEvent('Booking Reported', properties: {
        'bookingId': req.bookingId,
        'reported_userId': req.reportedUserId,
        'reason': reportedReason,
        'details': req.details,
      });
      ref.invalidate(fetchReceivedBookingsProvider);
      ref.invalidate(fetchSentBookingsProvider);
      ref.invalidate(fetchBookingDetailsProvider(req.bookingId ?? ''));
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final reportBookingProvider = AutoDisposeAsyncNotifierProvider<ReportBookingNotifier, String>(
  ReportBookingNotifier.new,
);
