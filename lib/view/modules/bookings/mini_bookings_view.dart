import 'package:creatify_mobile/view/modules/bookings/received_bookings_view.dart';
import 'package:creatify_mobile/view/modules/bookings/sent_bookings_view.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/bookings_tab.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';

class MiniBookingsView extends StatefulWidget {
  final int? length;
  const MiniBookingsView({
    super.key,
    this.length,
  });

  @override
  State<MiniBookingsView> createState() => _MiniBookingsViewState();
}

class _MiniBookingsViewState extends State<MiniBookingsView> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BookingsTabBar(tabController: tabController),
        16.0.height,
        Expanded(
          child: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SentBookingsView(
                length: widget.length,
              ),
              ReceivedBookingsView(
                length: widget.length,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
