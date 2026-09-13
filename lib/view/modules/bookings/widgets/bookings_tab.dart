import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/linear_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookingsTabBar extends ConsumerStatefulWidget {
  const BookingsTabBar({
    super.key,
    required TabController tabController,
  }) : _tabController = tabController;

  final TabController _tabController;

  @override
  ConsumerState<BookingsTabBar> createState() => _BookingsTabBarState();
}

class _BookingsTabBarState extends ConsumerState<BookingsTabBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.zero,
          width: 300.w,
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(40),
          ),
          child: TabBar(
            controller: widget._tabController,
            physics: const NeverScrollableScrollPhysics(),
            labelStyle: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            unselectedLabelStyle: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.btnText,
            ),
            indicatorPadding: const EdgeInsets.all(8),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.white,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => Colors.transparent,
            ),
            tabs: const [
              Tab(text: 'Sent Bookings'),
              Tab(text: 'Received Bookings'),
            ],
            onTap: (value) {
              if (value == 0) {
                ref.invalidate(fetchSentBookingsProvider);
              } else {
                ref.invalidate(fetchReceivedBookingsProvider);
              }
            },
          ),
        ),
        if (ref.watch(fetchSentBookingsProvider).isLoading ||
            ref.watch(fetchReceivedBookingsProvider).isLoading) ...[
          8.0.height,
          LineLoadingIndicator(
              loading: ref.watch(fetchSentBookingsProvider).isLoading ||
                  ref.watch(fetchReceivedBookingsProvider).isLoading),
        ],
      ],
    );
  }
}
