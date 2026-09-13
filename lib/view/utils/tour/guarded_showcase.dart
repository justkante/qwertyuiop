import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

/// A drop-in replacement for [Showcase] that renders [child] unwrapped when no
/// [ShowcaseView] scope is registered for the current context.
///
/// The three IndexedStack content tabs — Home, Search and Wallet — host their
/// guided tours through the single `tab-bar` scope owned by `TabBarSection`,
/// rather than each registering their own scope (they are all mounted at once
/// inside an `IndexedStack`, and `showcaseview` resolves a [Showcase] against
/// the current scope, so per-screen scopes would collide).
///
/// When any of these screens is pushed as a standalone route — e.g. the guest
/// deep-link, login and onboarding paths that push `SearchTalentsView`
/// directly — there is no `tab-bar` scope, and a bare [Showcase] throws in its
/// `initState`:
///
///   "No ShowcaseView is registered. Make sure ShowcaseView is registered
///    before using Showcase widget"
///
/// This backstop detects that exact condition and skips the showcase, so the
/// screen renders without a tour instead of crashing.
class GuardedShowcase extends StatelessWidget {
  const GuardedShowcase({
    super.key,
    required this.showcaseKey,
    required this.description,
    required this.child,
    this.targetBorderRadius,
  });

  /// The [GlobalKey] the tour engine uses to locate this target. It is attached
  /// to the inner [Showcase] (not to this widget) so the guard can toggle the
  /// wrapper without reparenting the key.
  final GlobalKey showcaseKey;
  final String description;
  final BorderRadius? targetBorderRadius;
  final Widget child;

  /// Whether a usable [ShowcaseView] scope is registered for the current scope.
  ///
  /// Mirrors the resolution a [Showcase] performs in its own `initState`: both
  /// resolve against `currentScope`, so this returns `false` in precisely the
  /// cases where a bare [Showcase] would throw.
  static bool _scopeRegistered() {
    try {
      ShowcaseView.get();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_scopeRegistered()) return child;
    return Showcase(
      key: showcaseKey,
      description: description,
      targetBorderRadius: targetBorderRadius,
      child: child,
    );
  }
}
