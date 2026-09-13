import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Holds the referral code extracted from a pending deep link.
/// Set by [AppLinksDeepLink] and consumed by [SearchTalentsView].
final pendingDeepLinkProvider = StateProvider<String?>((ref) => null);
