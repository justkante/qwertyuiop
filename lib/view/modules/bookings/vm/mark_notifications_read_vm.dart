import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MarkNotificationsAsReadNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> markNotificationAsRead({
    String? notificationId,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(bookingsRepository).markNotificationAsRead(notificationId ?? ''),
    );

    if (!state.hasError) {
      ref.invalidate(fetchNotificationsProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final markNotificationsAsReadProvider =
    AutoDisposeAsyncNotifierProvider<MarkNotificationsAsReadNotifier, String>(
  MarkNotificationsAsReadNotifier.new,
);
