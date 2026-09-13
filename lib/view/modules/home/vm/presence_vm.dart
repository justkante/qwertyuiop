import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PresenceNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> setPresence(bool isOnline) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(authRepository).setPresence(isOnline),
    );
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final presenceProvider = AutoDisposeAsyncNotifierProvider<PresenceNotifier, String>(
  () => PresenceNotifier(),
);
