import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/requests/verify_email_req.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VerifyEmailNotifier extends AutoDisposeAsyncNotifier<UserDto> {
  Future<void> verifyEmail(VerifyEmailReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(authRepository).verifyEmail(req));

    if (!state.hasError) {
      SharedPrefManager.email = req.email ?? '';
      ref.read(userControllerProvider.notifier).setUser(state.value ?? UserDto());
    }
  }

  @override
  FutureOr<UserDto> build() {
    return UserDto();
  }
}

final verifyEmailProvider = AutoDisposeAsyncNotifierProvider<VerifyEmailNotifier, UserDto>(
  VerifyEmailNotifier.new,
);

// Resend Verify Email
class ResendVerifyEmailNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> resendVerifyEmail({required String email}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
        () => ref.read(authRepository).resendVerificationEmail(email: email));

    if (!state.hasError) {}
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final resendVerifyEmailProvider =
    AutoDisposeAsyncNotifierProvider<ResendVerifyEmailNotifier, String>(
  ResendVerifyEmailNotifier.new,
);
