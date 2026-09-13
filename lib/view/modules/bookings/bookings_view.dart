import 'package:creatify_mobile/view/modules/bookings/received_bookings_view.dart';
import 'package:creatify_mobile/view/modules/bookings/sent_bookings_view.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/bookings_tab.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookingsView extends ConsumerStatefulWidget {
  const BookingsView({super.key});

  @override
  ConsumerState<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends ConsumerState<BookingsView> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookings',
          style: context.textTheme.displayMedium?.copyWith(fontSize: 19),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Manage your bookings and keep track of your appointments with ease",
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          16.0.height,
          BookingsTabBar(tabController: tabController),
          16.0.height,
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                SentBookingsView(),
                ReceivedBookingsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
