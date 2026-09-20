import 'package:creatify_mobile/data/models/responses/booking_item_dto.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/bookings_card.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/app_images.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/view/modules/jobs/vm/job_controller.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';

class SentBookingsView extends ConsumerStatefulWidget {
  const SentBookingsView({super.key});

  @override
  ConsumerState<SentBookingsView> createState() => _SentBookingsViewState();
}

class _SentBookingsViewState extends ConsumerState<SentBookingsView> {
  final searchController = TextEditingController();
  String searchQuery = '';
  BookingStatus selectedStatus = BookingStatus.pending; // Default or maybe 'All' logic
  String currentFilter = 'All';

  final List<String> filters = ['All', 'Pending', 'Accepted', 'Renegotiated', 'Completed'];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() => searchQuery = searchController.text.toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fetchSentBookingsProvider);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sentBookingsAsync = ref.watch(fetchSentBookingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator.adaptive(
        onRefresh: () async => ref.invalidate(fetchSentBookingsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 150),
          child: Column(
            children: [
              16.0.height,
              // Status Cards
              sentBookingsAsync.when(
                data: (bookings) => _buildStatusOverview(bookings),
                loading: () => const _StatusOverviewPlaceholder(),
                error: (_, __) => const _StatusOverviewPlaceholder(),
              ),
              24.0.height,

              // Filter Chips
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => 12.0.width,
                  itemBuilder: (context, index) {
                    final filter = filters[index];
                    final isSelected = currentFilter == filter;
                    return GestureDetector(
                      onTap: () => setState(() => currentFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1B3131) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? const Color(0xFF1B3131) : AppColors.grey200),
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.body,
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
              16.0.height,

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Name, Role...',
                    hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 13),
                    icon: const Icon(Icons.search, size: 20, color: AppColors.body),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              24.0.height,

              sentBookingsAsync.when(
                data: (bookings) {
                  final filtered = bookings.where((b) {
                    final matchesSearch = b.creator?.name?.toLowerCase().contains(searchQuery) ?? false;
                    final matchesStatus = currentFilter == 'All' || b.status?.name.toLowerCase() == currentFilter.toLowerCase();
                    return matchesSearch && matchesStatus;
                  }).toList();

                  if (filtered.isEmpty) return _buildEmptyState();

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => 16.0.height,
                    itemBuilder: (context, index) => BookingsCard(
                      bookingDetails: filtered[index],
                      isSent: true,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                error: (e, s) => Center(child: Text(e.toString())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOverview(List<BookingItemDto> bookings) {
    final pending = bookings.where((b) => b.status == BookingStatus.pending).length;
    final accepted = bookings.where((b) => b.status == BookingStatus.accepted).length;
    final completed = bookings.where((b) => b.status == BookingStatus.completed).length;

    return Row(
      children: [
        _buildStatusCard('Pending', pending, const Color(0xFFFEF6EF), const Color(0xFFF4A261), Icons.access_time),
        12.0.width,
        _buildStatusCard('Accepted', accepted, const Color(0xFFE8F5E9), const Color(0xFF2E7D32), Icons.check_circle_outline),
        12.0.width,
        _buildStatusCard('Completed', completed, const Color(0xFFE3F2FD), const Color(0xFF2196F3), Icons.calendar_today_outlined),
      ],
    );
  }

  Widget _buildStatusCard(String label, int count, Color bgColor, Color iconColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            12.0.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.body)),
                Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3131))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        40.0.height,
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(color: Colors.teal.shade50.withOpacity(0.3), shape: BoxShape.circle),
              ),
              const Icon(Icons.calendar_today_outlined, size: 80, color: Color(0xFF00796B)),
            ],
          ),
        ),
        24.0.height,
        const Text('No bookings yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        8.0.height,
        const Text(
          'When you send or receive bookings, they\'ll appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.body, fontSize: 13, height: 1.5),
        ),
        32.0.height,
        MainButton(
          text: 'Find creators',
          onPressed: () {
             ref.read(navBarController.notifier).index = 1; // Search Talents
          },
        ),
        16.0.height,
        MainButton(
          text: 'Explore jobs',
          color: Colors.white,
          textColor: const Color(0xFF00796B),
          onPressed: () {
             ref.read(jobTabIndexProvider.notifier).state = 0;
             ref.read(navBarController.notifier).index = 2; // Jobs tab
          },
        ),
      ],
    );
  }
}

class _StatusOverviewPlaceholder extends StatelessWidget {
  const _StatusOverviewPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) => Expanded(
        child: Container(
          height: 60,
          margin: EdgeInsets.only(right: index == 2 ? 0 : 12),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      )),
    );
  }
}
