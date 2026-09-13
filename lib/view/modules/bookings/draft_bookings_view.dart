import 'package:creatify_mobile/view/modules/bookings/vm/bookings_providers.dart';
import 'package:creatify_mobile/view/modules/bookings/vm/delete_draft_booking_vm.dart';
import 'package:creatify_mobile/view/modules/bookings/widgets/draft_bookings_card.dart';
import 'package:creatify_mobile/view/modules/onboarding/widgets/search_input_field.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/theme/theme_extensions.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';
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

  void _onSearchChanged() {
    setState(() {
      _searchQuery = searchController.text.toLowerCase();
    });
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draftBookings = ref.watch(fetchDraftBookingsProvider);

    final deleting = ref.watch(deleteDraftBookingProvider).isLoading;

    ref.listen(deleteDraftBookingProvider, (_, value) {
      if (value is AsyncData) {
        ToastDialog.showSuccess('Draft Booking has been successfully deleted', context);
      }
      if (value is AsyncError) {
        ToastDialog.showError(value.error.toString(), context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Draft Bookings',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.subHeading,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            SearchTextInputField(
              controller: searchController,
              hintText: 'Search Name...',
            ),
            21.0.height,
            draftBookings.when(
              data: (data) {
                final filteredFavorites = data
                    .where((booking) =>
                        booking.creator?.name?.toLowerCase().contains(_searchQuery) ?? false)
                    .toList();

                if (filteredFavorites.isEmpty) {
                  return Center(
                    child: Text(
                      'No draft bookings found.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.subHeading,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredFavorites.length,
                  separatorBuilder: (context, index) => 16.0.height,
                  itemBuilder: (context, index) {
                    final booking = filteredFavorites[index];
                    return DraftBookingsCard(
                      bookingDetails: booking,
                      isLoading: (booking.id == bookingId) && deleting,
                      onDelete: () {
                        bookingId = booking.id ?? '';

                        ref
                            .read(deleteDraftBookingProvider.notifier)
                            .deleteDraftBooking(booking.id ?? '');
                      },
                    );
                  },
                );
              },
              error: (error, stackTrace) {
                return Center(
                  child: Text(
                    error.toString(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.highlightRed,
                    ),
                  ),
                );
              },
              loading: () => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    24.0.height,
                    const Text('Loading Draft Bookings...'),
                    8.0.height,
                    const CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            24.0.height,
          ],
        ),
      ),
    );
  }
}
