import 'package:creatify_mobile/core/services/tour_service.dart';
import 'package:creatify_mobile/view/modules/bookings/bookings_view.dart';
import 'package:creatify_mobile/view/modules/chats/chats_view.dart';
import 'package:creatify_mobile/view/modules/home/home_view.dart';
import 'package:creatify_mobile/view/modules/jobs/jobs_main_view.dart';
import 'package:creatify_mobile/view/modules/search-talents/search_talents_view.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/view/modules/tab-bar/widgets/app_tab.dart';
import 'package:creatify_mobile/view/modules/transactions/transactions_view.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';
import 'package:creatify_mobile/view/utils/tour/tour_providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

class TabBarSection extends ConsumerStatefulWidget {
  const TabBarSection({
    super.key,
    this.showOnboardingSheet = false,
  });

  final bool showOnboardingSheet;

  @override
  ConsumerState<TabBarSection> createState() => _TabarViewState();
}

class _TabarViewState extends ConsumerState<TabBarSection> {
  late final String _scope = 'tab-bar-${UniqueKey()}';
  static const _navTour = 'nav';
  static const _contentTour = 'content';

  late final ShowcaseView _showcaseView;
  String? _activeTour;

  void _onTourFinish() {
    final tour = _activeTour;
    _activeTour = null;
    switch (tour) {
      case _navTour:
        _onNavTourFinish();
        break;
      case _contentTour:
        _onContentTourFinish();
        break;
    }
  }

  void _onNavTourFinish() {
    TourService.markScreenDone(TourService.mainTabs);
    ref.read(startTabTourProvider.notifier).state = 0;
  }

  void _onContentTourFinish() {
    final tabIndex = ref.read(navBarController);
    switch (tabIndex) {
      case 0:
        TourService.markScreenDone(TourService.homeTab);
        break;
      case 1:
        TourService.markScreenDone(TourService.searchTab);
        break;
      case 5:
        TourService.markScreenDone(TourService.walletTab);
        break;
    }
  }

  List<GlobalKey> _keysForTab(int index) {
    switch (index) {
      case 0:
        return [TourKeys.homeCreatorCard, TourKeys.homeSearchTalentCard];
      case 1:
        return [TourKeys.discoverScreen, TourKeys.searchSearchBar, TourKeys.searchFilterIcon];
      case 5:
        return [TourKeys.walletBalance, TourKeys.walletPayout];
      default:
        return [];
    }
  }

  String? _screenKeyForTab(int index) {
    switch (index) {
      case 0:
        return TourService.homeTab;
      case 1:
        return TourService.searchTab;
      case 5:
        return TourService.walletTab;
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(
      scope: _scope,
      onFinish: _onTourFinish,
    );
  }

  @override
  void dispose() {
    try {
      _showcaseView.unregister();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(startMainTourProvider, (_, shouldStart) {
      if (shouldStart) {
        ref.read(startMainTourProvider.notifier).state = false;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _activeTour = _navTour;
            _showcaseView.startShowCase([
              TourKeys.navHome,
              TourKeys.navSearch,
              TourKeys.navBookings,
              TourKeys.navMessages,
              TourKeys.navWallet,
            ]);
          }
        });
      }
    });

    ref.listen(startTabTourProvider, (_, tabIndex) {
      if (tabIndex < 0) return;
      ref.read(startTabTourProvider.notifier).state = -1;
      final screenKey = _screenKeyForTab(tabIndex);
      if (screenKey == null || !TourService.shouldShowScreenTour(screenKey)) return;
      final keys = _keysForTab(tabIndex);
      if (keys.isEmpty) return;
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _activeTour = _contentTour;
          _showcaseView.startShowCase(keys);
        }
      });
    });

    return Scaffold(
      body: IndexedStack(
        index: ref.watch(navBarController),
        children: [
          HomeView(
            showOnboardingSheet: widget.showOnboardingSheet,
          ),
          const SearchTalentsView(),
          const JobsMainView(), // Slot 2: New Marketplace
          const BookingsView(), // Slot 3: Restored original multi-tab BookingsView
          const ChatsView(),    // Slot 4: Original Chats
          const TransactionsView(), // Slot 5: Original Wallet
        ],
      ),
      bottomNavigationBar: const AppTabBar(),
      extendBody: true,
    );
  }
}
