import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/data/models/responses/make_payment_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/get_transactions_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InitializePaymentNotifier extends AutoDisposeAsyncNotifier<MakePaymentDto> {
  Future<void> initializePayment(String bookingId, String paymentMethod) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
        () => ref.read(transactionsRepository).initializePayment(bookingId, paymentMethod));

    if (!state.hasError &&
        (state.value?.authorizationUrl == null || state.value?.paymentReference == null)) {
      mixpanel.trackEvent('Booking Payment ${paymentMethod.toUpperCase()}');

      ref.invalidate(fetchReceivedBookingsProvider);
      ref.invalidate(fetchSentBookingsProvider);
      ref.invalidate(fetchBookingDetailsProvider(bookingId));
      ref.invalidate(fetchWalletDetailsProvider);
      ref.invalidate(getTransactionsProvider);
    }
  }

  @override
  FutureOr<MakePaymentDto> build() {
    return MakePaymentDto();
  }
}

final initializePaymentProvider =
    AutoDisposeAsyncNotifierProvider<InitializePaymentNotifier, MakePaymentDto>(
  InitializePaymentNotifier.new,
);
