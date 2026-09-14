import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppTabController extends StateNotifier<int> {
  AppTabController() : super(0);

  set index(int value) => state = value;
}

final navBarController = StateNotifierProvider<AppTabController, int>((ref) => AppTabController());
