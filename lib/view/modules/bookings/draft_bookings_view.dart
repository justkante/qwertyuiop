import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/delete_draft_booking_vm.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/draft_bookings_card.dart';
import 'package:creatify_mobile/view/modules/tab-bar/vm/tab_controller.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
import 'package:creatify_mobile/view/widgets/buttons.dart';
import 'package:creatify_mobile/view/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DraftBookingsView extends ConsumerStatefulWidget {
  const DraftBookingsView({super.key});

  @override
  ConsumerState<DraftBookingsView> createState() => _DraftBookingsViewState();
}

class _DraftBookingsViewState extends ConsumerState<DraftBookingsView> {
  final searchController = TextEditingController();
  String _searchQuery = '';
  String bookingId = '';
  String currentFilter = 'All';
  final List<String> filters = ['All', 'Proposals', 'Invites', 'Unsubmitted'];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() => _searchQuery = searchController.text.toLowerCase()));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draftBookings = ref.watch(fetchDraftBookingsProvider);
    final deleting = ref.watch(deleteDraftBookingProvider).isLoading;

    ref.listen(deleteDraftBookingProvider, (_, value) {
      if (value is AsyncData) ToastDialog.showSuccess('Draft deleted', context);
      if (value is AsyncError) ToastDialog.showError(value.error.toString(), context);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Draft Bookings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(16)),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search draft bookings...',
                  hintStyle: context.textTheme.bodySmall?.copyWith(fontSize: 13),
                  icon: const Icon(Icons.search, size: 20, color: AppColors.body),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          12.0.height,
          // Filters
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      child: Text(filter, style: TextStyle(color: isSelected ? Colors.white : AppColors.body, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                );
              },
            ),
          ),
          16.0.height,
          Expanded(
            child: draftBookings.when(
              data: (data) {
                final filtered = data.where((b) => b.creator?.name?.toLowerCase().contains(_searchQuery) ?? false).toList();
                if (filtered.isEmpty) return _buildEmptyState();
                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => 16.0.height,
                  itemBuilder: (context, index) {
                    final booking = filtered[index];
                    return DraftBookingsCard(
                      bookingDetails: booking,
                      isLoading: (booking.id == bookingId) && deleting,
                      onDelete: () {
                        bookingId = booking.id ?? '';
                        ref.read(deleteDraftBookingProvider.notifier).deleteDraftBooking(bookingId);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator.adaptive()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          40.0.height,
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(height: 180, width: 180, decoration: BoxDecoration(color: Colors.teal.shade50.withOpacity(0.3), shape: BoxShape.circle)),
                const Icon(Icons.edit_note, size: 80, color: Color(0xFF00796B)),
              ],
            ),
          ),
          24.0.height,
          const Text('No bookings yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          8.0.height,
          const Text('Your saved booking requests, proposals\nor invites will appear here.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.body, fontSize: 13, height: 1.5)),
          32.0.height,
          MainButton(
            text: '+ Create a new booking',
            onPressed: () {
               ref.read(navBarController.notifier).index = 1; // Go to Discover
               Navigator.pop(context); // Go back to main screen to see the change
            },
          ),
          40.0.height,
          // Tip Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF1FDFB), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [const Icon(Icons.lightbulb_outline, color: Color(0xFF00BFA5), size: 20), 8.0.width, const Text('Tip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]),
                8.0.height,
                const Text('You can save a booking as a draft and come back to it later.', style: TextStyle(color: AppColors.body, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
