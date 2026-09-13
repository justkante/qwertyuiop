import 'dart:async';
import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/data/models/responses/fund_wallet_dto.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/get_transactions_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Fund Wallet Notifier
class FundWalletNotifier extends AutoDisposeAsyncNotifier<FundWalletDto> {
  Future<void> fundWallet(num amount) async {
    state = const AsyncValue.loading();

    state =
        await AsyncValue.guard(() => ref.read(transactionsRepository).fundWalletWithCard(amount));

    if (!state.hasError) {
      mixpanel.trackEvent('Wallet Funding Initiated', properties: {
        'amount': amount,
        'payment_reference': state.value?.reference,
      });
    }
  }

  @override
  FutureOr<FundWalletDto> build() {
    return FundWalletDto();
  }
}

final fundWalletProvider = AutoDisposeAsyncNotifierProvider<FundWalletNotifier, FundWalletDto>(
  FundWalletNotifier.new,
);

// Verify Fund Payment Notifier
class VerifyFundingNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> verifyFundingPayment(String paymentReference) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
        () => ref.read(transactionsRepository).verifyWalletFunding(paymentReference));

    if (!state.hasError) {
      mixpanel.trackEvent('Wallet Funding Completed', properties: {
        'payment_reference': paymentReference,
      });

      ref.invalidate(fetchWalletDetailsProvider);
      ref.invalidate(getTransactionsProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final verifyWalletFundingProvider = AutoDisposeAsyncNotifierProvider<VerifyFundingNotifier, String>(
  VerifyFundingNotifier.new,
);
