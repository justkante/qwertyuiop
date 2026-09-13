import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsTabBar extends StatelessWidget {
  const NotificationsTabBar({
    super.key,
    required TabController tabController,
  }) : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      width: 260.w,
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(40),
      ),
      child: TabBar(
        controller: _tabController,
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
          Tab(text: 'All'),
          Tab(text: 'Unread'),
          Tab(text: 'Read'),
        ],
      ),
    );
  }
}
