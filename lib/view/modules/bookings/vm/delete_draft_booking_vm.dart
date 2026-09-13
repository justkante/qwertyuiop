import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeleteDraftBooking extends AutoDisposeAsyncNotifier<String> {
  Future<void> deleteDraftBooking(String draftId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(bookingsRepository).deleteDraftBooking(draftId));

    if (!state.hasError) {
      mixpanel.trackEvent('Draft Booking Deleted', properties: {
        'Draft Booking ID': draftId,
      });

      ref.invalidate(fetchDraftBookingsProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final deleteDraftBookingProvider = AutoDisposeAsyncNotifierProvider<DeleteDraftBooking, String>(
  DeleteDraftBooking.new,
);
