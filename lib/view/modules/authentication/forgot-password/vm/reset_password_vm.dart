import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/requests/reset_password_req.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ResetPasswordNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> resetPassword(ResetPasswordReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(authRepository).resetPassword(req));

    if (!state.hasError) {}
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final resetPasswordProvider = AutoDisposeAsyncNotifierProvider<ResetPasswordNotifier, String>(
  ResetPasswordNotifier.new,
);
