import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/tour/guarded_showcase.dart';
import 'package:creatify_mobile/view/utils/tour/tour_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreatorProfileTabBar extends StatelessWidget {
  const CreatorProfileTabBar({
    super.key,
    required TabController tabController,
  }) : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        labelColor: Colors.black,
        unselectedLabelColor: AppColors.body,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => Colors.transparent,
        ),
        tabs: [
          GuardedShowcase(
            showcaseKey: TourKeys.creatorPortfolio,
            description: 'Preview real creator work — photos, videos, and designs. ',
            child: const Tab(text: 'Portfolio'),
          ),
          GuardedShowcase(
            showcaseKey: TourKeys.creatorServicesPricing,
            description: 'View the creator\'s rates and services.',
            child: const Tab(text: 'Rates Card'),
          ),
        ],
      ),
    );
  }
}
