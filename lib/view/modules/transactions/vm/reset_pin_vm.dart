import 'dart:async';
import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Verify Fund Payment Notifier
class ForgotWalletPinNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> forgotWalletPin() async {
    state = const AsyncValue.loading();

    final userData = ref.watch(userControllerProvider);

    state = await AsyncValue.guard(
        () => ref.read(transactionsRepository).forgotPin(userData.email ?? ''));

    if (!state.hasError) {}
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final forgotWalletPinProvider = AutoDisposeAsyncNotifierProvider<ForgotWalletPinNotifier, String>(
  ForgotWalletPinNotifier.new,
);

//  Resend Forgot Wallet Pin Notifier
class ResendForgotWalletPinNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> resendForgotWalletPin() async {
    state = const AsyncValue.loading();

    final userData = ref.watch(userControllerProvider);

    state = await AsyncValue.guard(
        () => ref.read(transactionsRepository).resendForgotPin(userData.email ?? ''));

    if (!state.hasError) {}
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final resendForgotWalletPinProvider =
    AutoDisposeAsyncNotifierProvider<ResendForgotWalletPinNotifier, String>(
  ResendForgotWalletPinNotifier.new,
);

// Verify Forgot Pin Email Notifier
class VerifyForgotWalletPinNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> verifyWalletPin(String otpCode) async {
    state = const AsyncValue.loading();

    final userData = ref.watch(userControllerProvider);

    state = await AsyncValue.guard(
        () => ref.read(transactionsRepository).verifyPin(userData.email ?? '', otpCode));

    if (!state.hasError) {}
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final verifyForgotWalletPinProvider =
    AutoDisposeAsyncNotifierProvider<VerifyForgotWalletPinNotifier, String>(
  VerifyForgotWalletPinNotifier.new,
);

// Reset Wallet Pin Notifier
class ResetWalletPinNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> resetWalletPin({required String otpCode, required String newPin}) async {
    state = const AsyncValue.loading();

    final userData = ref.watch(userControllerProvider);

    state = await AsyncValue.guard(
        () => ref.read(transactionsRepository).resetPin(userData.email ?? '', otpCode, newPin));

    if (!state.hasError) {}
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final resetWalletPinProvider = AutoDisposeAsyncNotifierProvider<ResetWalletPinNotifier, String>(
  ResetWalletPinNotifier.new,
);
