import 'dart:developer';
import 'dart:io';

import 'package:creatify_mobile/core/env/env.dart';
import 'package:creatify_mobile/core/http/dio_http_service.dart';
import 'package:creatify_mobile/core/http/http_service.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class PushNotification {
  final Ref ref;

  PushNotification(this.ref) {
    notificationObserver();
  }

  Future<void> init() async {
    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    }

    OneSignal.initialize(Env.oneSignalAppId);

    final result = await OneSignal.Notifications.requestPermission(true);

    final userId = ref.watch(userControllerProvider).id ?? '';

    if (result) {
      log("Permission granted: $result , userID: $userId");
      // Log the user in on Onesignal
      OneSignal.login(userId);
      _updateDevicePlatform(userId);
    }
  }

  Future<void> _updateDevicePlatform(String userId) async {
    if (userId.isEmpty) return;

    try {
      final platform = kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios');

      // Get OneSignal Player ID (Subscription ID in v5)
      final playerID = OneSignal.User.pushSubscription.id;

      final networkService = NetworkService();
      await networkService.request(
        '/api/profile/update',
        RequestMethod.post,
        data: {
          'device_platform': platform,
          'onesignal_player_id': playerID,
        },
      );
      log("Device platform updated to $platform for user $userId with playerID $playerID");
    } catch (e) {
      log("Failed to update device platform: $e");
    }
  }

  Future<void> notificationObserver() async {
    OneSignal.Notifications.addPermissionObserver((permission) {
      log("Permission observer $permission");
      if (permission) {
        final userId = ref.watch(userControllerProvider).id ?? '';

        OneSignal.login(userId);
        _updateDevicePlatform(userId);
      }
    });
  }
}

final oneSignalpushNotificationProvider = Provider<PushNotification>((ref) {
  return PushNotification(ref);
});
