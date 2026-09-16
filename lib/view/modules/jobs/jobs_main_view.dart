import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'tabs/job_search_tab.dart';
import 'tabs/applied_jobs_tab.dart';
import 'tabs/my_listings_tab.dart';

class JobsMainView extends ConsumerStatefulWidget {
  final int initialIndex;
  const JobsMainView({super.key, this.initialIndex = 0});

  @override
  ConsumerState<JobsMainView> createState() => _JobsMainViewState();
}

class _JobsMainViewState extends ConsumerState<JobsMainView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Jobs',
          style: context.textTheme.displayMedium?.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          16.0.height,
          // Custom TabBar Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.black,
                unselectedLabelColor: AppColors.body,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Job Search'),
                  Tab(text: 'Applied'),
                  Tab(text: 'My Listing'),
                ],
              ),
            ),
          ),
          16.0.height,
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                JobSearchTab(),
                AppliedJobsTab(),
                MyListingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
