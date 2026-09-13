import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeleteAccountNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> deleteAccount({String? password}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(authRepository).deleteAccount(
            password: password,
          ),
    );

    if (!state.hasError) {
      mixpanel.trackEvent('Account Deleted');
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final deleteAccountProvider = AutoDisposeAsyncNotifierProvider<DeleteAccountNotifier, String>(
  DeleteAccountNotifier.new,
);
