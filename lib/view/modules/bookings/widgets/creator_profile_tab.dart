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
      padding: EdgeInsets.zero,
      width: 270.w,
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
