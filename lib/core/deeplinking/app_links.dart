import 'dart:async';
import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';

class AppLinksDeepLink {
  AppLinksDeepLink._privateConstructor();

  static final AppLinksDeepLink _instance = AppLinksDeepLink._privateConstructor();

  static AppLinksDeepLink get instance => _instance;

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  /// Called when a deep link URI is received (cold start or warm/background).
  Function(Uri)? onDeepLink;

  void onInit() {
    _appLinks = AppLinks();
    log('AppLinksDeepLink initialized');
  }

  Future<void> initDeepLinks() async {
    // Cancel any existing subscription before starting a new one
    await _linkSubscription?.cancel();
    _linkSubscription = null;

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialLink();
    if (appLink != null) {
      log('Deep link (cold start): $appLink');
      onDeepLink?.call(appLink);
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        log('Deep link (warm): $uri');
        onDeepLink?.call(uri);
      },
      onError: (err) {
        debugPrint('====>>> Deep link error: $err');
      },
      onDone: () {
        _linkSubscription?.cancel();
      },
    );
  }
}
