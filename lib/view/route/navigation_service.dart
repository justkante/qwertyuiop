import 'package:flutter/material.dart';

/// A singleton service that handles all navigation in the app
class NavigationService {
  NavigationService._();
  static final NavigationService instance = NavigationService._();

  /// Navigator state key
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current navigator state
  NavigatorState? get currentState => navigatorKey.currentState;

  /// Get the current build context
  BuildContext? get currentContext => currentState?.context;

  /// Push a named route
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) async {
    return currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Push a replacement route
  Future<dynamic> pushReplacement(
    Widget page, {
    bool isDialog = false,
    bool isTransparent = false,
    String? routeName,
  }) async {
    final route = _createRoute(
      page,
      isDialog: isDialog,
      routeName: routeName,
    );
    return currentState?.pushReplacement(route);
  }

  /// Push a route and remove all previous routes
  Future<dynamic> pushAndRemoveUntil(
    Widget page, {
    bool isDialog = false,
    bool isTransparent = false,
    String? routeName,
  }) async {
    final route = _createRoute(
      page,
      isDialog: isDialog,
      routeName: routeName,
    );
    return currentState?.pushAndRemoveUntil(route, (route) => false);
  }

  /// Push a new route
  Future<dynamic> push(
    Widget page, {
    bool isDialog = false,
    bool isTransparent = false,
    String? routeName,
    //PageTransitionType transitionType = PageTransitionType.material,
    PageTransitionType? transitionType,
  }) async {
    final route = _createRoute(
      page,
      isDialog: isDialog,
      routeName: routeName,
      transitionType: transitionType,
    );
    return currentState?.push(route);
  }

  /// Pop to the first route
  void popToFirst() => currentState?.popUntil((route) => route.isFirst);

  /// Pop the current route
  void pop<T>([T? result]) => currentState?.pop(result);

  /// Check if the navigator can pop
  bool get canPop => currentState?.canPop() ?? false;

  /// Create a route based on the parameters
  Route<dynamic> _createRoute(
    Widget page, {
    bool isDialog = false,
    PageTransitionType? transitionType, // Make nullable
    String? routeName,
  }) {
    // If transitionType is null, use material
    switch (transitionType) {
      case PageTransitionType.transparent:
        return TransparentPageRoute(
          builder: (_) => page,
          settings: RouteSettings(name: routeName ?? page.runtimeType.toString()),
        );
      case PageTransitionType.slideFromRight:
        return SlideFromRightPageRoute(
          builder: (_) => page,
          settings: RouteSettings(name: routeName ?? page.runtimeType.toString()),
        );
      case PageTransitionType.slideFromBottom:
        return SlideFromBottomPageRoute(
          builder: (_) => page,
          settings: RouteSettings(name: routeName ?? page.runtimeType.toString()),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => page,
          fullscreenDialog: isDialog,
          settings: RouteSettings(name: routeName ?? page.runtimeType.toString()),
        );
    }
  }
}

/// Extension methods for easier navigation from BuildContext
extension NavigationExtension on BuildContext {
  /// Push replacement route
  Future<dynamic> pushReplacement(
    Widget page, {
    bool isDialog = false,
    bool isTransparent = false,
    String? routeName,
  }) =>
      NavigationService.instance.pushReplacement(
        page,
        isDialog: isDialog,
        isTransparent: isTransparent,
        routeName: routeName,
      );

  /// Push and remove until
  Future<dynamic> pushAndRemoveUntil(
    Widget page, {
    bool isDialog = false,
    bool isTransparent = false,
    String? routeName,
  }) =>
      NavigationService.instance.pushAndRemoveUntil(
        page,
        isDialog: isDialog,
        isTransparent: isTransparent,
        routeName: routeName,
      );

  /// Push a new route
  Future<dynamic> push(
    Widget page, {
    bool isDialog = false,
    PageTransitionType? transitionType = PageTransitionType.material,
    String? routeName,
  }) =>
      NavigationService.instance.push(
        page,
        isDialog: isDialog,
        transitionType: transitionType,
        routeName: routeName,
      );

  /// Pop to first route
  void popToFirst() => NavigationService.instance.popToFirst();

  /// Pop current route
  void pop<T>([T? result]) => NavigationService.instance.pop(result);

  /// Check if can pop
  bool get canPop => NavigationService.instance.canPop;
}

/// A route that creates a transparent page transition
class TransparentPageRoute<T> extends PageRoute<T> {
  TransparentPageRoute({
    required this.builder,
    super.settings,
  }) : super(fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: builder(context),
      ),
    );
  }
}

/// A route that slides in from the right (Cupertino style)
class SlideFromRightPageRoute<T> extends PageRoute<T> {
  SlideFromRightPageRoute({
    required this.builder,
    super.settings,
    this.duration = const Duration(milliseconds: 0),
  }) : super(fullscreenDialog: false);

  final WidgetBuilder builder;
  final Duration duration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: builder(context),
    );
  }
}

/// A route that slides in from the bottom
class SlideFromBottomPageRoute<T> extends PageRoute<T> {
  SlideFromBottomPageRoute({
    required this.builder,
    super.settings,
    this.duration = const Duration(milliseconds: 300),
  }) : super(fullscreenDialog: false);

  final WidgetBuilder builder;
  final Duration duration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: builder(context),
    );
  }
}

enum PageTransitionType {
  material,
  transparent,
  slideFromRight,
  slideFromBottom,
}
