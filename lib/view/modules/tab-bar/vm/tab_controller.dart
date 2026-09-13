import 'package:hooks_riverpod/hooks_riverpod.dart';

class TabController extends StateNotifier<int> {
  TabController() : super(0);

  set index(int value) => state = value;
}

final navBarController = StateNotifierProvider<TabController, int>((ref) => TabController());
