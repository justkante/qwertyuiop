import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Set to `true` from [HomeView] after the tour dialog is accepted.
/// [TabBarSection] listens and starts the showcase sequence.
final startMainTourProvider = StateProvider<bool>((ref) => false);

/// Set to a tab index (0-4) to trigger that tab's showcase.
/// -1 means no pending tour. [TabBarSection] listens and fires the right keys.
final startTabTourProvider = StateProvider<int>((ref) => -1);
