import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/data/models/requests/book_creator_req.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeliveryBasedCreatorBookingNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> bookCreator(BookCreatorReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(bookingsRepository).bookCreator(req));

    if (!state.hasError) {
      mixpanel.trackEvent(
          '${req.bookingType == 'time-based' ? 'Time-Based' : 'Delivery-Based'} Booking Created',
          properties: {
            'creator_name': req.creatorName,
            'creator_id': req.creatorId,
            'category_booked': req.creatorCategory,
            'category_id': req.creatorCategoryId,
            'job_description': req.jobDescription,
            'work_mode': req.workMode,
            'location': req.location ?? 'N/A',
            'total_price': req.price,
            'start_date': req.startDate?.toFormattedDateWithYear(),
          });

      ref.invalidate(fetchReceivedBookingsProvider);
      ref.invalidate(fetchSentBookingsProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final deliveryBasedCreatorBookingProvider =
    AutoDisposeAsyncNotifierProvider<DeliveryBasedCreatorBookingNotifier, String>(
  DeliveryBasedCreatorBookingNotifier.new,
);
