import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/route/navigation_service.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../widgets/job_post_card.dart';
import '../job_details_view.dart';
import '../vm/job_controller.dart';
import 'package:creatify_mobile/view/modules/home/support_view.dart';

class AppliedJobsTab extends ConsumerStatefulWidget {
  const AppliedJobsTab({super.key});

  @override
  ConsumerState<AppliedJobsTab> createState() => _AppliedJobsTabState();
}

class _AppliedJobsTabState extends ConsumerState<AppliedJobsTab> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Pending', 'Reviewed', 'Shortlisted', 'Closed'];
  final searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobControllerProvider.notifier).fetchAppliedJobs();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobState = ref.watch(jobControllerProvider);

    final filteredAppliedJobs = jobState.appliedJobs.where((job) {
      if (_searchQuery.isNotEmpty) {
        final title = (job.title ?? '').toLowerCase();
        final desc = (job.description ?? '').toLowerCase();
        final cat = (job.category?.name ?? '').toLowerCase();
        if (!title.contains(_searchQuery) && !desc.contains(_searchQuery) && !cat.contains(_searchQuery)) {
          return false;
        }
      }

      if (selectedFilter == 'All') return true;

      final sLower = job.status?.toLowerCase() ?? '';
      final effLower = job.effectiveStatus.toLowerCase();
      final isExpired = job.isExpired || sLower.contains('expired') || sLower == 'closed' || effLower.contains('expired');

      if (selectedFilter == 'Closed') {
        return isExpired || sLower == 'closed' || sLower == 'inactive';
      }

      if (isExpired) {
        return false;
      }

      if (selectedFilter == 'Pending') {
        return sLower == 'pending' || sLower == 'sent' || sLower == 'active' || sLower == 'open' || sLower.isEmpty;
      } else if (selectedFilter == 'Reviewed') {
        return sLower == 'reviewed' || sLower == 'viewed';
      } else if (selectedFilter == 'Shortlisted') {
        return sLower == 'shortlisted';
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          16.0.height,
          // Horizontal Filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => 12.0.width,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => selectedFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey200),
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.body,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          24.0.height,

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SearchTextInputField(
              controller: searchController,
              hintText: 'Search job, role...',
              trailingIcon: _searchQuery.isNotEmpty
                  ? InkWell(
                      onTap: () => searchController.clear(),
                      child: const Icon(Icons.clear, size: 18, color: AppColors.body),
                    )
                  : null,
            ),
          ),

          Expanded(
            child: jobState.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : jobState.appliedJobs.isEmpty
                    ? _buildEmptyState()
                    : filteredAppliedJobs.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search_off_outlined, size: 48, color: AppColors.body),
                                  12.0.height,
                                  const Text('No matching applied jobs found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  8.0.height,
                                  const Text('Try adjusting your search query or filter chips.', style: TextStyle(color: AppColors.body, fontSize: 12), textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 300),
                            itemCount: filteredAppliedJobs.length,
                            separatorBuilder: (_, __) => 16.0.height,
                            itemBuilder: (context, index) {
                              final job = filteredAppliedJobs[index];
                              final displayStatus = job.isExpired ? 'Job Expired' : job.effectiveStatus;
                              return JobPostCard(
                                title: job.title ?? '',
                                description: job.description ?? '',
                                location: job.location ?? '',
                                price: job.price ?? 0,
                                currency: job.currency ?? 'NGN',
                                dateRange: job.formattedDateRange,
                                status: displayStatus,
                                serviceName: job.category?.name,
                                initialFavorite: job.isFavorited ?? false,
                                onTap: () => NavigationService.instance.push(JobDetailView(job: job, status: JobStatus.viewed)),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 300), // Increased to 300
      child: Column(
        children: [
          40.0.height,
          // Illustration Placeholder
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(color: Colors.teal.shade50.withOpacity(0.3), shape: BoxShape.circle),
                ),
                const Icon(Icons.search, size: 80, color: Color(0xFF00796B)),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                    child: const Icon(Icons.person_outline, size: 30, color: Color(0xFF00BFA5)),
                  ),
                ),
              ],
            ),
          ),
          24.0.height,
          const Text('No applications yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          8.0.height,
          const Text(
            'Jobs you apply for will appear here so you can track your progress and get updates.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.body, fontSize: 13, height: 1.5),
          ),
          32.0.height,
          MainButton(
            text: 'Explore Jobs  →',
            onPressed: () {
               ref.read(jobTabIndexProvider.notifier).state = 0; // Navigate to Search tab
            },
          ),
          16.0.height,
          _buildJobAlertButton(),
          32.0.height,
          // Tips Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FDFB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Color(0xFF00BFA5), size: 20),
                    8.0.width,
                    const Text('Tips to get hired', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                16.0.height,
                _buildTipItem('Complete your profile to stand out', 'A complete profile gets more attention.'),
                12.0.height,
                _buildTipItem('Apply early to new postings', 'Early applications have a higher chance of success.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, color: Color(0xFF00BFA5), size: 18),
        12.0.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(subtitle, style: const TextStyle(color: AppColors.body, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobAlertButton() {
    final hasAlerts = SharedPrefManager.jobAlertsEnabled;
    return TextButton(
      onPressed: () {
        final newVal = !hasAlerts;
        SharedPrefManager.jobAlertsEnabled = newVal;
        setState(() {});
        try {
          if (newVal) {
            OneSignal.User.addTagWithKey("job_alerts", "true");
            ToastDialog.showSuccess('Job alerts activated! You will receive notifications when new jobs are posted.', context);
          } else {
            OneSignal.User.removeTag("job_alerts");
            ToastDialog.showSuccess('You will no longer receive notifications for new jobs', context);
          }
        } catch (_) {
          if (newVal) {
            ToastDialog.showSuccess('Job alerts activated!', context);
          } else {
            ToastDialog.showSuccess('You will no longer receive notifications for new jobs', context);
          }
        }
      },
      child: Text(
        hasAlerts ? 'Remove job alerts' : 'Set job alerts',
        style: const TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
