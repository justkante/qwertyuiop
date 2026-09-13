import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/get_transactions_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VerifyPaymentNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> verify(String paymentReference, String bookingId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
        () => ref.read(transactionsRepository).verifyPayment(paymentReference));

    if (!state.hasError) {
      ref.invalidate(fetchReceivedBookingsProvider);
      ref.invalidate(fetchSentBookingsProvider);
      ref.invalidate(fetchBookingDetailsProvider(bookingId));
      ref.invalidate(fetchWalletDetailsProvider);
      ref.invalidate(getTransactionsProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final verifyPaymentProvider = AutoDisposeAsyncNotifierProvider<VerifyPaymentNotifier, String>(
  VerifyPaymentNotifier.new,
);
