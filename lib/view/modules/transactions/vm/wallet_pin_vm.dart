import 'dart:async';
import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/requests/change_wallet_pin_req.dart';
import 'package:creatify_mobile/data/models/requests/create_wallet_pin_req.dart';
import 'package:creatify_mobile/view/modules/transactions/vm/transactions_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Verify Fund Payment Notifier
class CreateWalletPinNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> createWalletPin(CreateWalletPinReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(transactionsRepository).createWalletPin(req));

    if (!state.hasError) {
      ref.invalidate(fetchWalletDetailsProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final createWalletPinProvider = AutoDisposeAsyncNotifierProvider<CreateWalletPinNotifier, String>(
  CreateWalletPinNotifier.new,
);

// Change Wallet Pin Notifier
class ChangeWalletPinNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> changeWalletPin(ChangeWalletPinReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(transactionsRepository).changeWalletPin(req));

    if (!state.hasError) {
      ref.invalidate(fetchWalletDetailsProvider);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final changeWalletPinProvider = AutoDisposeAsyncNotifierProvider<ChangeWalletPinNotifier, String>(
  ChangeWalletPinNotifier.new,
);
