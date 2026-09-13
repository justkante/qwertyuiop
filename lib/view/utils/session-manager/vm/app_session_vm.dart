// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/view/route/current_user_notifier.dart';
import 'package:creatify_mobile/view/utils/session-manager/session_config.dart';
import 'package:creatify_mobile/view/utils/session-manager/session_timeout_manager.dart';

final appSessionProvider = Provider<SessionConfig>((ref) {
  final sessionConfig = SessionConfig(
    invalidateSessionForAppLostFocus: const Duration(minutes: 5),
    invalidateSessionForUserInactivity: const Duration(minutes: kDebugMode ? 30 : 5),
  );

  sessionConfig.stream.listen((SessionTimeoutState timeoutEvent) async {
    if (timeoutEvent == SessionTimeoutState.userInactivityTimeout) {
      // handle user  inactive timeout
      log("Inactive AuthState: -----> user inactivity on the app");

      if (SharedPrefManager.isLoggedIn == true) {
        /// stop listening, as user will already be in auth page

        ref.read(sessionStateProvider).add(SessionState.stopListening);
        ref.read(userStateProvider.notifier).logOutUser();
        SharedPrefManager.clear();
      } else {
        return;
      }
    } else if (timeoutEvent == SessionTimeoutState.appFocusTimeout) {
      // handle user  app lost focus timeout

      log("App lost Focus: -----> App focus time out");
      if (SharedPrefManager.isLoggedIn == true) {
        // stop listening, as user will already be in auth page
        ref.read(sessionStateProvider).add(SessionState.stopListening);
        ref.read(userStateProvider.notifier).logOutUser();
        SharedPrefManager.clear();

        log("User logged: -----> Session state disabled");
      } else {
        return;
      }
    }
  });

  return sessionConfig;
});

final sessionStateProvider = Provider((ref) {
  return StreamController<SessionState>();
});
