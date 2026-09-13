import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimeBasedMarkAsCompletedNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> markAsCompletedTimeBased({
    required String bookingId,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(bookingsRepository).approveTimeBasedMarkCompleted(bookingId),
    );

    if (!state.hasError) {
      mixpanel.trackEvent(
        'Approved Time Based Mark as Completed',
        properties: {
          'booking_id': bookingId,
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

final timeBasedMarkAsCompletedProvider =
    AutoDisposeAsyncNotifierProvider<TimeBasedMarkAsCompletedNotifier, String>(
  TimeBasedMarkAsCompletedNotifier.new,
);

class DeliveryBasedMarkAsCompletedNotifier extends AutoDisposeAsyncNotifier<(bool, bool)> {
  Future<void> markAsCompletedDeliveryBased({
    required String bookingId,
    required String deliverableId,
    required String action,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () async {
        final result = await ref.read(bookingsRepository).approveDeliverableBasedMarkCompleted(
              bookingId: bookingId,
              deliverableId: deliverableId,
              action: action,
            );
        return (result, action == 'approve');
      },
    );

    if (!state.hasError) {
      mixpanel.trackEvent(
        'Responded to Delivery Based Mark as Completed',
        properties: {
          'booking_id': bookingId,
          'deliverable_id': deliverableId,
          'action': action,
        },
      );

      ref.invalidate(fetchReceivedBookingsProvider);
      ref.invalidate(fetchSentBookingsProvider);
      ref.invalidate(fetchBookingDetailsProvider(bookingId));
    }
  }

  @override
  FutureOr<(bool, bool)> build() {
    return (false, false);
  }
}

final deliveryBasedMarkAsCompletedProvider =
    AutoDisposeAsyncNotifierProvider<DeliveryBasedMarkAsCompletedNotifier, (bool, bool)>(
  DeliveryBasedMarkAsCompletedNotifier.new,
);
