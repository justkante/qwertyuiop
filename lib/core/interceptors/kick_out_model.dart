import 'dart:developer';

import 'package:creatify_mobile/core/di/injector.dart';
import 'package:creatify_mobile/core/storage/secure-storage/secure_storage.dart';
import 'package:creatify_mobile/core/utils/constants.dart';
import 'package:creatify_mobile/view/modules/authentication/login_view.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:flutter/foundation.dart';

class KickOutListener {
  KickOutListener();

  kickOut() async {
    // Clear the Auth Token
    var storage = inject.get<SecureStorageBase>();
    await storage.deleteData(PrefKeys.token);

    // Take them back to the Sign In Screen
    if (kDebugMode) {
      log("User KICKED OUT!!!");
    }

    NavigationService.instance.currentState?.popUntil((route) => route.isFirst);
    NavigationService.instance.currentContext?.pushAndRemoveUntil(const LoginView());
  }
}
