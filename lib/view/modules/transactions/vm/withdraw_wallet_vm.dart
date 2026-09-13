import 'dart:async';
import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/data/models/requests/withdraw_req.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/get_transactions_vm.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Verify Fund Payment Notifier
class WithdrawWalletNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> withdrawWalletPayment(WithdrawReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(transactionsRepository).withdrawFromWallet(req));

    if (!state.hasError) {
      mixpanel.trackEvent('Wallet Withdrawal Completed', properties: {
        'amount': req.amount,
        'Bank Code': req.bankCode,
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

final withdrawWalletProvider = AutoDisposeAsyncNotifierProvider<WithdrawWalletNotifier, String>(
  WithdrawWalletNotifier.new,
);
