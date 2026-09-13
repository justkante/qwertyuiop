import 'dart:async';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/requests/signup_req.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/showcase-talents/vm/creator_providers.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SignUpNotifier extends AutoDisposeAsyncNotifier<UserDto> {
  Future<void> signUp(SignUpReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(authRepository).signUp(req));

    if (!state.hasError) {
      // Track Login Event
      mixpanel.trackEvent('User Signed Up');

      // Identify User
      mixpanel.identify(state.value?.id ?? '');

      // Set User Properties
      mixpanel.setUserProperties({
        '\$name': state.value?.name ?? '',
        '\$email': state.value?.email ?? '',
        'login_method': state.value?.authStrategy ?? '',
        'account_created': state.value?.createdAt?.toFormattedDateWithYear() ?? '',
      });

      SharedPrefManager.userId = state.value?.id ?? '';
      ref.read(userControllerProvider.notifier).setUser(state.value ?? UserDto());
      SharedPrefManager.countryUpdatedAt =
          state.value?.countryUpdatedAt?.toIso8601String() ?? DateTime.now().toIso8601String();
      ref.invalidate(fetchStatesProvider);
    }
  }

  @override
  FutureOr<UserDto> build() {
    return UserDto();
  }
}

final signUpProvider = AutoDisposeAsyncNotifierProvider<SignUpNotifier, UserDto>(
  SignUpNotifier.new,
);
