import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UpdateBookingStatusNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref
          .read(bookingsRepository)
          .updateTimeBasedBookingStatus(bookingId: bookingId, status: status),
    );

    if (!state.hasError) {
      ref.invalidate(fetchReceivedBookingsProvider);
      ref.invalidate(fetchSentBookingsProvider);
      ref.invalidate(fetchBookingDetailsProvider(bookingId));
      ref.invalidate(fetchBookingDeliverablesProvider(bookingId));
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final updateCreatorBookingStatusProvider =
    AutoDisposeAsyncNotifierProvider<UpdateBookingStatusNotifier, String>(
  UpdateBookingStatusNotifier.new,
);

// Deliverable Based View Model
class UpdateDeliverableBookingStatusNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> updateDeliverableBookingStatus({
    required String bookingId,
    required String deliverableId,
    required String status,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(bookingsRepository).updateDeliverableBasedBookingStatus(
            bookingId: bookingId,
            deliverableId: deliverableId,
            status: status,
          ),
    );
    if (!state.hasError) {
      ref.invalidate(fetchReceivedBookingsProvider);
      ref.invalidate(fetchSentBookingsProvider);
      ref.invalidate(fetchBookingDetailsProvider(bookingId));
      ref.invalidate(fetchBookingDeliverablesProvider(bookingId));
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final updateCreatorDeliverableStatusProvider =
    AutoDisposeAsyncNotifierProvider<UpdateDeliverableBookingStatusNotifier, String>(
  UpdateDeliverableBookingStatusNotifier.new,
);
