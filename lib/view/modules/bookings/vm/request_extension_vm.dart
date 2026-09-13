import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreatorRequestExtensionNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> creatorRequestExtension({
    required bool isTimeBased,
    required String bookingId,
    required int durationDays,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(bookingsRepository).requestBookingExtension(
            isTimeBased: isTimeBased,
            bookingId: bookingId,
            requestedDays: durationDays,
          ),
    );

    if (!state.hasError) {
      mixpanel.trackEvent(
        'Requested Booking Extension',
        properties: {
          'booking_id': bookingId,
          'is_time_based': isTimeBased,
          'duration_days': durationDays,
        },
      );

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

final creatorRequestExtensionProvider =
    AutoDisposeAsyncNotifierProvider<CreatorRequestExtensionNotifier, String>(
  CreatorRequestExtensionNotifier.new,
);

// Recruiter Respond to Request Extension Notifier
class RecruiterRespondExtensionNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> recruiterRespondExtension({
    required String extensionId,
    required bool isAccepted,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref
          .read(bookingsRepository)
          .recruiterRespondToExtension(extensionId: extensionId, isAccepted: isAccepted),
    );

    if (!state.hasError) {
      mixpanel.trackEvent(
        'Responded to Booking Extension Request',
        properties: {
          'extension_id': extensionId,
          'is_accepted': isAccepted,
        },
      );

      ref.invalidate(fetchReceivedBookingsProvider);
      ref.invalidate(fetchSentBookingsProvider);
      ref.invalidate(fetchBookingDetailsProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final recruiterRespondExtensionProvider =
    AutoDisposeAsyncNotifierProvider<RecruiterRespondExtensionNotifier, String>(
  RecruiterRespondExtensionNotifier.new,
);
