import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/data/models/requests/change_password_req.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChangePasswordNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> changePassword(ChangePasswordReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(authRepository).changePassword(req));

    if (!state.hasError) {}
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final changePasswordProvider = AutoDisposeAsyncNotifierProvider<ChangePasswordNotifier, String>(
  ChangePasswordNotifier.new,
);
