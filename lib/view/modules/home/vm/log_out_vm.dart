import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/storage/secure-storage/secure_storage.dart';
import 'package:creatify_mobile/core/utils/constants.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LogOutNotifier extends AutoDisposeAsyncNotifier<String> {
  Future<void> logOut() async {
    state = const AsyncValue.loading();
    try {
      final storage = GetIt.I<SecureStorageBase>();

      // Set Presence to offline before logging out
      await ref.read(authRepository).setPresence(false);

      // Clear Bearer Token from secure storage & reset user state
      await storage.deleteData(PrefKeys.token);
      ref.read(userControllerProvider.notifier).setUser(UserDto());
      ref.read(userControllerProvider.notifier).cleatUserFromStorage();

      state = const AsyncValue.data('Logged out successfully');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  @override
  FutureOr<String> build() {
    return '';
  }
}

final logOutProvider = AutoDisposeAsyncNotifierProvider<LogOutNotifier, String>(
  () => LogOutNotifier(),
);
