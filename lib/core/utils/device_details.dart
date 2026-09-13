import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// This Method is to get the device details for Security Purposes
Future<List<dynamic>> getDeviceDetails() async {
  String? deviceType;
  String? deviceToken;

  bool? isPlatformAndroid;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    isPlatformAndroid = false;
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    deviceType = iosInfo.utsname.machine;
    deviceToken = iosInfo.identifierForVendor;
  } else if (Platform.isAndroid) {
    isPlatformAndroid = true;
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceType = androidInfo.model;
    deviceToken = androidInfo.id;
  }
  return [deviceType, deviceToken, isPlatformAndroid];
}

class Device {
  static bool get isIpad {
    if (kIsWeb || !Platform.isIOS) return false;

    try {
      final data = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first);
      return data.size.shortestSide > 600;
    } catch (e) {
      // Fallback: if views aren't available, return false
      return false;
    }
  }

  static bool get isIphone => Platform.isIOS && !isIpad;

  /// Alternative method using device_info_plus for more reliable iPad detection
  static Future<bool> isIpadAsync() async {
    if (kIsWeb || !Platform.isIOS) return false;

    try {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      // Check if device model contains "iPad"
      return iosInfo.model.toLowerCase().contains('ipad');
    } catch (e) {
      return false;
    }
  }
}
