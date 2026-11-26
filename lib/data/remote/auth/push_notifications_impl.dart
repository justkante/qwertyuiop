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

    final userId = ref.read(userControllerProvider).id ?? '';

    if (userId.isNotEmpty) {
      log("OneSignal logging in user: $userId");
      OneSignal.login(userId);

      // Add subscription observer to capture playerID as soon as APNs registers
      OneSignal.User.pushSubscription.addObserver((state) {
        final newPlayerId = state.current.id;
        if (newPlayerId != null && newPlayerId.isNotEmpty) {
          log("OneSignal pushSubscription ID ready via observer: $newPlayerId");
          _updateDevicePlatform(userId, newPlayerId);
        }
      });

      final currentId = OneSignal.User.pushSubscription.id;
      if (currentId != null && currentId.isNotEmpty) {
        _updateDevicePlatform(userId, currentId);
      }
    }

    final result = await OneSignal.Notifications.requestPermission(true);
    log("OneSignal permission requested: $result, userID: $userId");
  }

  Future<void> _updateDevicePlatform(String userId, String playerId) async {
    if (userId.isEmpty || playerId.isEmpty) return;

    try {
      final platform = kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : 'ios');

      final networkService = NetworkService();
      await networkService.request(
        '/api/profile/update',
        RequestMethod.post,
        data: {
          'device_platform': platform,
          'onesignal_player_id': playerId,
        },
      );
      log("Device platform updated to $platform for user $userId with playerID $playerId");
    } catch (e) {
      log("Failed to update device platform: $e");
    }
  }

  Future<void> notificationObserver() async {
    OneSignal.Notifications.addPermissionObserver((permission) {
      log("Permission observer $permission");
      if (permission) {
        final userId = ref.watch(userControllerProvider).id ?? '';

        if (userId.isNotEmpty) {
          OneSignal.login(userId);
          final currentId = OneSignal.User.pushSubscription.id;
          if (currentId != null && currentId.isNotEmpty) {
            _updateDevicePlatform(userId, currentId);
          }
        }
      }
    });
  }
}

final oneSignalpushNotificationProvider = Provider<PushNotification>((ref) {
  return PushNotification(ref);
});
