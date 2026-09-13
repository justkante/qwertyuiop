import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/requests/signin_req.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:creatify_mobile/data/remote/auth/push_notifications_impl.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/search-talents/login_sheet.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginNotifier extends AutoDisposeAsyncNotifier<UserDto> {
  Future<void> login(SignInReq req, {bool rememberMe = true}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(authRepository).signIn(req));

    if (!state.hasError) {
      // Track Login Event
      mixpanel.trackEvent('User Logged In');

      // Identify User
      mixpanel.identify(state.value?.id ?? '');

      // Set User Properties
      mixpanel.setUserProperties({
        '\$name': state.value?.name ?? '',
        '\$email': state.value?.email ?? '',
        'login_method': state.value?.authStrategy ?? '',
        'account_created': state.value?.createdAt?.toFormattedDateWithYear() ?? '',
      });

      // Other User Properties
      SharedPrefManager.email = rememberMe ? (req.email ?? '') : '';
      SharedPrefManager.userId = state.value?.id ?? '';
      ref.read(userControllerProvider.notifier).setUser(state.value ?? UserDto());
      ref.read(oneSignalpushNotificationProvider).init();
      SharedPrefManager.countryUpdatedAt =
          state.value?.countryUpdatedAt?.toIso8601String() ?? DateTime.now().toIso8601String();

      // Store if biometrics should be offered
      if (rememberMe && !SharedPrefManager.hasBiometrics) {
        SharedPrefManager.isNewLogin = true;
      } else {
        SharedPrefManager.isNewLogin = false;
      }

      if (fromLoginSheet.value) {
        ref.read(navBarController.notifier).index = 1;
        fromLoginSheet.value = false;
      }
      ref.invalidate(fetchStatesProvider);
    }
  }

  @override
  FutureOr<UserDto> build() {
    return UserDto();
  }
}

final loginProvider = AutoDisposeAsyncNotifierProvider<LoginNotifier, UserDto>(
  LoginNotifier.new,
);
