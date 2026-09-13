// Sign In Auth
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/env/env.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:creatify_mobile/data/remote/auth/push_notifications_impl.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GoogleAuthNotifier extends StateNotifier<AsyncValue<String>> {
  GoogleAuthNotifier() : super(const AsyncValue.data(''));

  final _googleSignIn = GoogleSignIn.instance;

  bool _isGoogleSignInInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(
        clientId: Platform.isIOS ? Env.googleIosClientId : Env.googleAndroidClientId,
        serverClientId: Platform.isAndroid ? Env.googleWebClientId : null,
      );
      log('Google Sign-In initialized successfully.');

      _isGoogleSignInInitialized = true;
    } catch (e) {
      log('Failed to initialize Google Sign-In: $e');
      throw e.toString();
    }
  }

  Future<void> googleAuth() async {
    state = const AsyncValue.loading();

    try {
      if (!_isGoogleSignInInitialized) {
        await _initializeGoogleSignIn();
      }

      final googleAccount = await _googleSignIn.authorizationClient.authorizeScopes(['email']);

      state = AsyncValue.data(googleAccount.accessToken);
    } catch (e, stackTrace) {
      log('Google Sign-In Auth Error: ${e.toString()}');
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final googleAuthProvider = StateNotifierProvider<GoogleAuthNotifier, AsyncValue<String>>((ref) {
  return GoogleAuthNotifier();
});

// Server Google Sign In
class GoogleSignInNotifier extends AutoDisposeAsyncNotifier<UserDto> {
  Future<void> googleSignIn(String token) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() => ref.read(authRepository).googleSignIn(token));

    if (!state.hasError) {
      // Track Login Event
      mixpanel.trackEvent('User Logged In (Google)');

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

final googleSignInProvider = AutoDisposeAsyncNotifierProvider<GoogleSignInNotifier, UserDto>(
  GoogleSignInNotifier.new,
);
