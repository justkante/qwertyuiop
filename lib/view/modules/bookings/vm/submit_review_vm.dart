import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/requests/submit_review_req.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SubmitBookingReviewNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> submitBookingReview(String bookingId, SubmitReviewReq review) async {
    state = const AsyncValue.loading();

    state =
        await AsyncValue.guard(() => ref.read(bookingsRepository).submitReview(bookingId, review));

    if (!state.hasError) {}
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final submitBookingReviewProvider =
    AutoDisposeAsyncNotifierProvider<SubmitBookingReviewNotifier, String>(
  SubmitBookingReviewNotifier.new,
);
