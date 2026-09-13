import 'dart:developer';

import 'package:creatify_mobile/core/deeplinking/app_links.dart';
import 'package:creatify_mobile/core/deeplinking/deeplink_provider.dart';
import 'package:creatify_mobile/core/http/dio_http_service.dart';
import 'package:creatify_mobile/core/services/mixpanel_service.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/data/models/responses/user_dto.dart';
import 'package:creatify_mobile/data/remote/chat/pusher_service.dart';
import 'package:creatify_mobile/view/modules/authentication/login_view.dart';
import 'package:creatify_mobile/view/modules/home/vm/user_controller.dart';
import 'package:creatify_mobile/view/modules/onboarding/onboarding_view.dart';
import 'package:creatify_mobile/view/modules/search-talents/search_talents_view.dart';
import 'package:creatify_mobile/view/modules/tab-bar/tab_bar_view.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/view/theme/app_theme.dart';
import 'package:creatify_mobile/view/utils/session-manager/session_timeout_manager.dart';
import 'package:creatify_mobile/view/utils/session-manager/vm/app_session_vm.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerStatefulWidget {
  final String env;
  const MyApp({
    super.key,
    required this.env,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  bool isBackground = false;
  // Prevents _navigateForDeepLink() from firing twice for the same deep link
  // (e.g. once from _handleDeepLink and once from the isLoadingUser listener).
  bool _navigatingForDeepLink = false;
  // Timestamp of the last accepted deep link. Used to debounce the cold-start
  // echo where uriLinkStream re-emits the same URI that getInitialLink() just
  // returned (a known app_links behaviour on some platforms).
  int _lastDeepLinkMs = 0;

  // App Links
  /// Initializes the deep link handler for the application.
  ///
  /// This line instantiates a singleton instance of [AppLinksDeepLink] and immediately
  /// calls its [onInit] method using the cascade operator (..). The double period (..)
  /// allows chaining method calls on the same object without reassigning it, making the
  /// initialization more concise and readable.
  ///
  /// The cascade operator (..) is useful here because:
  /// - It eliminates the need for a separate line to call [onInit]
  /// - It returns the object itself rather than the return value of [onInit]
  /// - It keeps initialization logic together in a single statement
  final AppLinksDeepLink _appLinksDeepLink = AppLinksDeepLink.instance..onInit();

  /// Preload authentication token from secure storage and cache it in the interceptor
  /// This prevents race condition where API calls happen before token is loaded
  Future<void> _preloadAuthToken() async {
    try {
      // Get the network service singleton and initialize token in interceptor
      final networkService = NetworkService();
      await networkService.tokenInterceptor.initToken();

      log('Auth token initialized in interceptor');
    } catch (e) {
      log('Error preloading auth token: $e');
    }
  }

  getUserFromStorage() async {
    await _preloadAuthToken();
    ref.read(userControllerProvider.notifier).getUserFromStorage();
  }

  @override
  void initState() {
    super.initState();
    getUserFromStorage();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMixpanel();
      _appLinksDeepLink.onDeepLink = _handleDeepLink;
      _appLinksDeepLink.initDeepLinks();
    });
  }

  /// Called by [AppLinksDeepLink] whenever a deep link is received.
  ///
  /// Handles two URI formats:
  ///  - Universal Link:  https://creatifyapp.com/profile/[CODE]
  ///  - Custom scheme:   creatify://profile/[CODE]  (simulator / local testing)
  void _handleDeepLink(Uri uri) {
    String? profileId;

    if (uri.scheme == 'https' && uri.host == 'creatifyapp.com') {
      // https://creatifyapp.com/profile/CODE
      final segments = uri.pathSegments;
      if (segments.length >= 2 && segments[0] == 'profile') {
        profileId = segments[1];
      }
    } else if (uri.scheme == 'creatify' && uri.host == 'profile') {
      // creatify://profile/CODE
      profileId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    }

    if (profileId == null || profileId.isEmpty) return;

    // Debounce: on cold start, uriLinkStream can echo the same URI that
    // getInitialLink() already returned (within milliseconds). Drop any
    // duplicate that arrives within 500 ms.
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastDeepLinkMs < 500) return;
    _lastDeepLinkMs = now;

    // New link — reset the guard so navigation fires exactly once for it.
    _navigatingForDeepLink = false;
    ref.read(pendingDeepLinkProvider.notifier).state = profileId;

    final isLoading = ref.read(isLoadingUserProvider);
    if (!isLoading) _navigateForDeepLink();
    // If user is still loading from storage, the ref.listen in build() handles it.
  }

  /// Switches to the Search Talents tab (logged-in) or pushes the view (guest).
  /// The [_navigatingForDeepLink] flag ensures this runs at most once per link.
  void _navigateForDeepLink() {
    if (_navigatingForDeepLink) return;
    _navigatingForDeepLink = true;

    final user = ref.read(userControllerProvider);
    if (user.id != null) {
      ref.read(navBarController.notifier).index = 1;
    } else {
      NavigationService.instance.push(const SearchTalentsView());
    }
  }

  /// Initialize Mixpanel analytics
  void _initializeMixpanel() async {
    try {
      Map<String, dynamic> superProperties = {
        'platform': 'Mobile',
        'environment': widget.env == "prod" ? 'Production' : 'Staging',
      };

      await MixpanelService.instance.initialize(superProperties: superProperties);
      log('Mixpanel initialized in app');

      MixpanelService.instance.trackEvent('App Launched');
    } catch (e) {
      log('Failed to initialize Mixpanel in app: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        log('App Detached'.toUpperCase());
      case AppLifecycleState.resumed:
        isResume();
        log('App Resumed'.toUpperCase());
        // Ensure Pusher reconnects if needed
        _ensurePusherReconnection();
      case AppLifecycleState.inactive:
        appState();
        log('App Inactive'.toUpperCase());
      case AppLifecycleState.hidden:
        log('App Hidden'.toUpperCase());
      case AppLifecycleState.paused:
        log('App Paused'.toUpperCase());
    }
  }

  /// Ensure Pusher service reconnects after app resumes
  void _ensurePusherReconnection() {
    try {
      final pusherService = PusherService.instance;
      if (!pusherService.isConnected && pusherService.isInitialized) {
        log('App resumed: Attempting Pusher reconnection...');
        pusherService.reconnect();
      }
    } catch (e) {
      log('Error ensuring Pusher reconnection: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void appState() {
    setState(() => isBackground = true);
  }

  void isResume() {
    setState(() => isBackground = false);
  }

  Widget _getHomeScreen(UserDto user, bool isLoadingUser) {
    if (SharedPrefManager.isFirstLaunch) {
      return const OnboardingView();
    }

    // Show loading while user is being fetched from storage
    if (isLoadingUser) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      );
    }

    log("User ID: ${user.id}");

    if (user.id == null) {
      return const LoginView();
    }

    // Handle Abandoned State: Redirect incomplete creators to onboarding
    final bool isCreator = user.roles?.contains('creator') ?? false;
    final bool isIncomplete = user.countryCode == null || user.profileId == null;

    if (isCreator && isIncomplete) {
      log("Redirecting incomplete creator to onboarding");
      return const OnboardingView();
    }

    return const TabBarSection();
  }

  @override
  Widget build(BuildContext context) {
    final appSession = ref.watch(appSessionProvider);

    // User from Storage - use watch to rebuild when user changes
    final user = ref.watch(userControllerProvider);
    final isLoadingUser = ref.watch(isLoadingUserProvider);

    // When the user finishes loading from storage and a deep link is pending,
    // perform the navigation that _handleDeepLink deferred.
    ref.listen(isLoadingUserProvider, (prev, isLoading) {
      if (prev == true && isLoading == false) {
        final pendingCode = ref.read(pendingDeepLinkProvider);
        if (pendingCode != null) _navigateForDeepLink();
      }
    });

    // Use actual screen dimensions for iPad compatibility mode
    final screenSize = MediaQuery.of(context).size;
    final designSize = Size(
      375,
      screenSize.height > 0 ? screenSize.height : 812,
    );

    return GestureDetector(
      onTap: () => WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(),
      child: CustomBanner(
        visible: widget.env == "dev",
        message: 'STAGING',
        child: ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: ((context, child) {
            return SessionTimeoutManager(
              sessionConfig: appSession,
              sessionStateStream: ref.watch(sessionStateProvider).stream,
              child: MaterialApp(
                title: "Creatify",
                navigatorKey: NavigationService.instance.navigatorKey,
                debugShowCheckedModeBanner: false,
                theme: themeData(),
                key: navigatorKey,
                home: _getHomeScreen(user, isLoadingUser),
                builder: (context, child) {
                  return MediaQuery(
                    data:
                        MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.98)),
                    child: child!,
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

class CustomBanner extends StatelessWidget {
  const CustomBanner({
    super.key,
    required this.visible,
    required this.message,
    required this.child,
  });

  final bool visible;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return child;
    }

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.topCenter,
      children: <Widget>[
        child,
        CustomPaint(
          painter: BannerPainter(
            message: message,
            textDirection: TextDirection.rtl,
            layoutDirection: TextDirection.rtl,
            location: BannerLocation.topStart,
            color: AppColors.highlightCoral,
          ),
        ),
      ],
    );
  }
}
