import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/requests/verify_email_req.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ForgotPasswordEmailNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> verifyForgotEmail({required String email}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(authRepository).forgotPassword(email: email));

    if (!state.hasError) {}
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final forgotPasswordEmailProvider =
    AutoDisposeAsyncNotifierProvider<ForgotPasswordEmailNotifier, String>(
  ForgotPasswordEmailNotifier.new,
);

// Verify Forgot Password Otp
class VerifyForgotEmailNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> verifyForgotEmail(VerifyEmailReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(authRepository).verifyPasswordResetOtp(req));

    if (!state.hasError) {
      // SharedPrefManager.email = req.email ?? '';
    }
  }

  @override
  FutureOr<String> build() {
    return "";
  }
}

final verifyForgotEmailProvider =
    AutoDisposeAsyncNotifierProvider<VerifyForgotEmailNotifier, String>(
  VerifyForgotEmailNotifier.new,
);

// Resend Verify Email
class ResendResetPasswordCodeNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> resendResetPasswordCode({required String email}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
        () => ref.read(authRepository).resendResetPasswordCode(email: email));

    if (!state.hasError) {}
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final resendForgotPasswordEmailProvider =
    AutoDisposeAsyncNotifierProvider<ResendResetPasswordCodeNotifier, String>(
  ResendResetPasswordCodeNotifier.new,
);
