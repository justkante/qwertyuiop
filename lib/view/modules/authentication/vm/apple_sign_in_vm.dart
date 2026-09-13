import 'dart:async';
import 'dart:developer';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/requests/apple_sign_in_req.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:creatify_mobile/data/remote/auth/push_notifications_impl.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthNotifier extends StateNotifier<AsyncValue<AppleSignInReq>> {
  AppleAuthNotifier() : super(AsyncValue.data(AppleSignInReq()));

  Future<void> appleAuth() async {
    state = const AsyncValue.loading();

    try {
      final credentials = await SignInWithApple.getAppleIDCredential(
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.mobile.creatify',
          redirectUri: Uri.parse('https://creatify.app/signin-with-apple'),
        ),
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      state = AsyncValue.data(
        AppleSignInReq(
          email: credentials.email,
          name: "${credentials.givenName} ${credentials.familyName}",
          identityToken: credentials.identityToken,
          authCode: credentials.authorizationCode,
          userId: credentials.userIdentifier,
        ),
      );
    } catch (e, stackTrace) {
      log('Apple Auth Error: ${e.toString()}');
      log(stackTrace.toString());
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final appleAuthProvider =
    StateNotifierProvider<AppleAuthNotifier, AsyncValue<AppleSignInReq>>((ref) {
  return AppleAuthNotifier();
});

// Server Apple Sign In
class AppleSignInNotifier extends AutoDisposeAsyncNotifier<UserDto> {
  Future<void> appleSignIn(AppleSignInReq req) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(authRepository).appleSignIn(req));

    if (!state.hasError) {
      // Track Login Event
      mixpanel.trackEvent('User Logged In (Apple)');

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
      ref.read(oneSignalpushNotificationProvider).init();
    }
  }

  @override
  FutureOr<UserDto> build() {
    return UserDto();
  }
}

final appleSignInProvider = AutoDisposeAsyncNotifierProvider<AppleSignInNotifier, UserDto>(
  AppleSignInNotifier.new,
);
